const Company = require('../models/Company');
const User = require('../models/User');

// @desc    Get all companies
// @route   GET /api/companies
// @access  Private (Super Admin)
const getCompanies = async (req, res) => {
    try {
        const companies = await Company.find({});
        res.json(companies);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create a company
// @route   POST /api/companies
// @access  Private (Super Admin)
const createCompany = async (req, res) => {
    try {
        const { name, email, plan, address, phone, logoUrl, primaryColor, secondaryColor, currencySymbol } = req.body;

        if (!name || !email || !logoUrl || !primaryColor || !currencySymbol) {
            return res.status(400).json({ message: 'Please provide all required branding fields (Logo, Color, Currency)' });
        }

        const company = await Company.create({
            name,
            email,
            plan,
            address,
            phone,
            logoUrl,
            primaryColor,
            secondaryColor,
            currencySymbol
        });

        res.status(201).json(company);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update company status/plan
// @route   PUT /api/companies/:id
// @access  Private (Super Admin)
const updateCompany = async (req, res) => {
    try {
        const company = await Company.findById(req.params.id);

        if (company) {
            company.isActive = req.body.isActive ?? company.isActive;
            company.plan = req.body.plan ?? company.plan;
            company.name = req.body.name ?? company.name;
            company.logoUrl = req.body.logoUrl ?? company.logoUrl;
            company.primaryColor = req.body.primaryColor ?? company.primaryColor;
            company.secondaryColor = req.body.secondaryColor ?? company.secondaryColor;
            company.currencySymbol = req.body.currencySymbol ?? company.currencySymbol;

            const updatedCompany = await company.save();
            res.json(updatedCompany);
        } else {
            res.status(404).json({ message: 'Company not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getCompanies, createCompany, updateCompany };
