const Branch = require('../models/Branch');

// @desc    Get all branches for a company
// @route   GET /api/branches
// @access  Private (Admin)
const getBranches = async (req, res) => {
    try {
        const branches = await Branch.find({ company: req.companyId });
        res.json(branches);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create a branch
// @route   POST /api/branches
// @access  Private (Admin)
const createBranch = async (req, res) => {
    try {
        const { name, address, phone } = req.body;
        const branch = await Branch.create({
            company: req.companyId,
            name,
            address,
            phone
        });
        res.status(201).json(branch);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update a branch
// @route   PUT /api/branches/:id
// @access  Private (Admin)
const updateBranch = async (req, res) => {
    try {
        const branch = await Branch.findById(req.params.id);
        if (branch) {
            branch.name = req.body.name || branch.name;
            branch.address = req.body.address || branch.address;
            branch.phone = req.body.phone || branch.phone;
            if (req.body.isActive !== undefined) branch.isActive = req.body.isActive;

            const updatedBranch = await branch.save();
            res.json(updatedBranch);
        } else {
            res.status(404).json({ message: 'Branch not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getBranches, createBranch, updateBranch };
