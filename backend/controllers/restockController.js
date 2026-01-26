const RestockRequest = require('../models/RestockRequest');
const Product = require('../models/Product');

// @desc    Create a restock request
// @route   POST /api/restock
// @access  Private (Sales)
const createRestockRequest = async (req, res) => {
    const { productId } = req.body;

    try {
        const product = await Product.findById(productId);
        if (!product) {
            return res.status(404).json({ message: 'Product not found' });
        }

        const request = await RestockRequest.create({
            product: productId,
            requestedBy: req.user._id,
        });

        res.status(201).json(request);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Get all pending restock requests
// @route   GET /api/restock
// @access  Private (Warehouse, Admin)
const getRestockRequests = async (req, res) => {
    try {
        const requests = await RestockRequest.find({ status: 'pending' })
            .populate('product', 'name category currentStock')
            .populate('requestedBy', 'name');
        res.json(requests);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Mark restock request as fulfilled
// @route   PUT /api/restock/:id/fulfill
// @access  Private (Warehouse)
const fulfillRestockRequest = async (req, res) => {
    try {
        const request = await RestockRequest.findById(req.params.id);
        if (!request) {
            return res.status(404).json({ message: 'Request not found' });
        }

        request.status = 'fulfilled';
        await request.save();

        res.json(request);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { createRestockRequest, getRestockRequests, fulfillRestockRequest };
