const Product = require('../models/Product');

// @desc    Get all products
// @route   GET /api/products
// @access  Private (Sales, Warehouse)
const getProducts = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 100;
        const skip = (page - 1) * limit;

        const { barcode } = req.query;
        let query = {};
        if (barcode) {
            query.barcode = barcode;
        }

        const total = await Product.countDocuments(query);
        const products = await Product.find(query)
            .skip(skip)
            .limit(limit);

        res.json({
            products,
            page,
            pages: Math.ceil(total / limit),
            total
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create a product
// @route   POST /api/products
// @access  Private (Warehouse)
const createProduct = async (req, res) => {
    const { name, category, size, fruitQuantity, unitType, currentStock, shelfLocation, price, barcode } = req.body;

    // Basic Validation
    if (!name || !category || !size || !unitType || !currentStock || !shelfLocation || !price) {
        return res.status(400).json({ message: 'Please fill all required fields' });
    }

    try {
        const product = new Product({
            name,
            category,
            size,
            fruitQuantity,
            unitType,
            currentStock,
            shelfLocation,
            currentStock,
            shelfLocation,
            price,
            barcode
        });

        const createdProduct = await product.save();
        res.status(201).json(createdProduct);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update product stock/location
// @route   PUT /api/products/:id
// @access  Private (Warehouse)
const updateProduct = async (req, res) => {
    const { currentStock, shelfLocation } = req.body;

    try {
        const product = await Product.findById(req.params.id);

        if (product) {
            product.currentStock = currentStock ?? product.currentStock;
            product.shelfLocation = shelfLocation ?? product.shelfLocation;

            const updatedProduct = await product.save();
            res.json(updatedProduct);
        } else {
            res.status(404).json({ message: 'Product not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getProducts, createProduct, updateProduct };
