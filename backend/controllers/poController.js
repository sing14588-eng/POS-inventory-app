const PurchaseOrder = require('../models/PurchaseOrder');
const Product = require('../models/Product');
const { logAction } = require('../utils/auditLogger');

// @desc    Get all POs
// @route   GET /api/pos
const getPOs = async (req, res) => {
    try {
        const pos = await PurchaseOrder.find({ company: req.companyId, branch: req.branchId })
            .populate('supplier', 'name')
            .sort({ createdAt: -1 });
        res.json(pos);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create PO
// @route   POST /api/pos
const createPO = async (req, res) => {
    try {
        const { supplier, items, totalCost, notes } = req.body;
        const po = await PurchaseOrder.create({
            company: req.companyId,
            branch: req.branchId,
            supplier,
            items,
            totalCost,
            notes
        });
        res.status(201).json(po);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update PO status (and check-in stock)
// @route   PUT /api/pos/:id
const updatePOStatus = async (req, res) => {
    try {
        const po = await PurchaseOrder.findById(req.params.id);
        if (!po) return res.status(404).json({ message: 'PO not found' });

        const { status } = req.body;

        // If transitioning to 'received', update products
        if (status === 'received' && po.status !== 'received') {
            for (const item of po.items) {
                await Product.findByIdAndUpdate(item.product, {
                    $inc: { currentStock: item.quantity }
                });
            }
            po.receivedDate = Date.now();

            await logAction(req, {
                action: 'PO_RECEIVED',
                details: `Received PO from supplier. Stock updated for ${po.items.length} items.`,
                itemType: 'PurchaseOrder',
                itemId: po._id
            });
        }

        po.status = status;
        await po.save();
        res.json(po);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getPOs, createPO, updatePOStatus };
