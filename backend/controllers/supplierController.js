const Supplier = require('../models/Supplier');

// @desc    Get all suppliers
// @route   GET /api/suppliers
// @access  Private (Warehouse, Admin)
const getSuppliers = async (req, res) => {
    try {
        const suppliers = await Supplier.find({ company: req.companyId });
        res.json(suppliers);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create a supplier
// @route   POST /api/suppliers
// @access  Private (Warehouse, Admin)
const createSupplier = async (req, res) => {
    try {
        const { name, contactPerson, phone, email, address, categories } = req.body;
        const supplier = await Supplier.create({
            company: req.companyId,
            name,
            contactPerson,
            phone,
            email,
            address,
            categories
        });
        res.status(201).json(supplier);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getSuppliers, createSupplier };
