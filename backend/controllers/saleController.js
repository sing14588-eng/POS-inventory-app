const Sale = require('../models/Sale');
const Product = require('../models/Product');
const { logAction } = require('../utils/auditLogger');
const { sendNotification } = require('../utils/notificationService');

// @desc    Create a new sale
// @route   POST /api/sales
// @access  Private (Sales)
const createSale = async (req, res) => {
    const { items, isCredit } = req.body;

    if (!items || items.length === 0) {
        return res.status(400).json({ message: 'No items in sale' });
    }

    try {
        let totalAmount = 0;
        const processedItems = [];

        // 1. Validate Stock & Calculate Total
        for (const item of items) {
            const product = await Product.findById(item.product);

            if (!product) {
                return res.status(404).json({ message: `Product not found: ${item.productName}` });
            }

            if (product.currentStock < item.quantity) {
                return res.status(400).json({
                    message: `Insufficient stock for ${product.name}. Available: ${product.currentStock}`
                });
            }

            // Calculate item total (price * quantity)
            // Assuming simplified logic where price is passed or fetched. 
            // It's safer to fetch price from DB to avoid client manipulation, but for MVP we might trust or re-fetch.
            // Let's re-fetch price for security.
            const itemTotal = product.price * item.quantity;
            totalAmount += itemTotal;

            processedItems.push({
                product: product._id,
                productName: product.name,
                quantity: item.quantity,
                unitType: product.unitType,
                pricePerUnit: product.price,
                total: itemTotal
            });
        }

        const vatAmount = totalAmount * 0.15;
        const grandTotal = totalAmount + vatAmount;

        // 2. Create Sale Record
        const sale = new Sale({
            items: processedItems,
            totalAmount: grandTotal, // storing inclusive of VAT or exclusive? User said VAT = 15% of total sale. Let's assume Total + VAT.
            vatAmount,
            isCredit,
            salesRep: req.user._id,
            company: req.companyId,
            branch: req.branchId,
            status: 'Pending', // Pending preparation
            isPrepared: false,
        });

        const createdSale = await sale.save();

        await logAction(req, {
            action: 'SALE_CREATED',
            details: `New sale created. Total: ${grandTotal}`,
            itemType: 'Sale',
            itemId: createdSale._id
        });

        // 3. Update Stock & Check for Low Stock
        for (const item of processedItems) {
            const updatedProduct = await Product.findByIdAndUpdate(item.product, {
                $inc: { currentStock: -item.quantity }
            }, { new: true });

            if (updatedProduct.currentStock < 10) {
                await sendNotification({
                    company: req.companyId,
                    branch: req.branchId,
                    roles: ['admin', 'warehouse'],
                    title: 'Low Stock Tip',
                    message: `${updatedProduct.name} is now down to ${updatedProduct.currentStock}`,
                    type: 'WARNING',
                    data: { productId: updatedProduct._id.toString() }
                });
            }
        }

        res.status(201).json(createdSale);

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get logged in user's sales
// @route   GET /api/sales/my-sales
// @access  Private (Sales, Admin)
const getMySales = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const skip = (page - 1) * limit;

        const total = await Sale.countDocuments({ salesRep: req.user._id, company: req.companyId });
        const sales = await Sale.find({ salesRep: req.user._id, company: req.companyId })
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);

        res.json({
            sales,
            page,
            pages: Math.ceil(total / limit),
            total
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Request a refund
// @route   POST /api/sales/:id/refund
// @access  Private (Sales)
const requestRefund = async (req, res) => {
    try {
        const sale = await Sale.findById(req.params.id);
        if (!sale) return res.status(404).json({ message: 'Sale not found' });

        sale.refundStatus = 'requested';
        sale.refundReason = req.body.reason || 'Customer Return';
        await sale.save();

        await logAction(req, {
            action: 'REFUND_REQUESTED',
            details: `Refund requested for sale ${sale._id}. Reason: ${sale.refundReason}`,
            itemType: 'Sale',
            itemId: sale._id
        });

        await sendNotification({
            company: req.companyId,
            branch: req.branchId,
            roles: ['admin', 'accountant'],
            title: 'Refund Request',
            message: `A refund of ${sale.totalAmount} has been requested for sale #${sale._id.toString().slice(-6)}`,
            type: 'INFO',
            data: { saleId: sale._id.toString() }
        });

        res.json(sale);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Approve a refund
// @route   PUT /api/sales/:id/refund/approve
// @access  Private (Accountant, Admin)
const approveRefund = async (req, res) => {
    try {
        const sale = await Sale.findById(req.params.id);
        if (!sale) return res.status(404).json({ message: 'Sale not found' });

        sale.refundStatus = 'approved';
        await sale.save();

        // In a real app, we would reverse stock changes or create a negative transaction here.
        // For MVP, just marking status is enough.

        res.json(sale);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get all pending refund requests
// @route   GET /api/sales/refunds/pending
// @access  Private (Accountant, Admin)
const getRefundRequests = async (req, res) => {
    try {
        const sales = await Sale.find({ refundStatus: 'requested', company: req.companyId })
            .sort({ updatedAt: -1 });
        res.json(sales);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { createSale, getMySales, requestRefund, approveRefund, getRefundRequests };
