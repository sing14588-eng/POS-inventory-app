const Sale = require('../models/Sale');

// @desc    Get pending orders for picker
// @route   GET /api/picker/orders
// @access  Private (Picker)
const getPendingOrders = async (req, res) => {
    try {
        // Fetch sales that are not yet prepared.
        // Assuming "Today's orders" means all pending, or we can filter by date if needed.
        // User said "View today's orders". 
        const startOfDay = new Date();
        startOfDay.setHours(0, 0, 0, 0);

        const endOfDay = new Date();
        endOfDay.setHours(23, 59, 59, 999);

        const orders = await Sale.find({
            createdAt: { $gte: startOfDay, $lte: endOfDay },
            isPrepared: false
        }).populate('items.product', 'shelfLocation'); // helpful for picker to see location

        res.json(orders);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Mark order as prepared
// @route   PUT /api/picker/orders/:id/prepare
// @access  Private (Picker)
const markOrderPrepared = async (req, res) => {
    try {
        const sale = await Sale.findById(req.params.id);

        if (sale) {
            sale.isPrepared = true;
            sale.status = 'Completed'; // Or keep as pending if payment separate? User flow implies "Prepared" is key step for Picker.
            sale.preparedBy = req.user._id;

            const updatedSale = await sale.save();
            res.json(updatedSale);
        } else {
            res.status(404).json({ message: 'Order not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getPendingOrders, markOrderPrepared };
