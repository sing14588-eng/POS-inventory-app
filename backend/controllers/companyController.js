const { sendEmail } = require('../utils/emailService');
const { credentialsTemplate } = require('../utils/emailTemplates');

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

// @desc    Get global statistics
// @route   GET /api/companies/stats
// @access  Private (Super Admin)
const getGlobalStats = async (req, res) => {
    try {
        const totalShops = await Company.countDocuments();
        const activeShops = await Company.countDocuments({ isActive: true });
        const deactivatedShops = await Company.countDocuments({ isActive: false });

        // Mocking total sales for now as it would require aggregating from Sales model
        // In a real scenario: const totalSales = await Sale.aggregate([{ $group: { _id: null, total: { $sum: "$totalAmount" } } }]);
        const totalSales = 0;

        res.json({
            totalShops,
            activeShops,
            deactivatedShops,
            totalSales: totalSales[0]?.total || 0,
            systemStatus: 'OPERATIONAL'
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create a company with full starter team
// @route   POST /api/companies
// @access  Private (Super Admin)
const createCompany = async (req, res) => {
    try {
        // Helper: Generate Unique Shop ID
        const generateShopId = async () => {
            let id;
            let exists = true;
            while (exists) {
                id = Math.floor(1000 + Math.random() * 9000).toString();
                const count = await Company.countDocuments({ shopId: id });
                if (count === 0) exists = false;
            }
            return id;
        };

        const shopId = await generateShopId();
        const usernamePrefix = name.replace(/\s+/g, '').substring(0, 8).toLowerCase();

        // 1. Create Company
        const company = await Company.create({
            name,
            email,
            plan,
            shopId,
            address,
            phone,
            logoUrl,
            primaryColor,
            secondaryColor,
            currencySymbol
        });

        // 2. Create Default Branch (Main Headquarters)
        const branch = await Branch.create({
            name: 'Main Headquarters',
            company: company._id,
            address: address || 'Main Store Location',
            phone: phone || 'Company Phone'
        });

        // Helper: Generate Secure Random Credentials matching spec: shopName + systemID
        const generateCreds = (role) => {
            const suffix = Math.floor(100 + Math.random() * 899);
            const username = `${usernamePrefix}${shopId}${suffix}`;

            const characters = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
            let password = '';
            for (let i = 0; i < 10; i++) {
                password += characters.charAt(Math.floor(Math.random() * characters.length));
            }
            return { username, password };
        };

        const adminCreds = generateCreds('admin');
        const salesCreds = generateCreds('sales');
        const warehouseCreds = generateCreds('warehouse');

        // 3. Create Team (Admin, Sales, Warehouse)
        const users = [
            {
                name: `${name} Admin`,
                username: adminCreds.username,
                email: email,
                password: adminCreds.password,
                roles: ['admin'],
                company: company._id,
                branch: branch._id,
                passwordChanged: false
            },
            {
                name: `${name} Sales`,
                username: salesCreds.username,
                password: salesCreds.password,
                roles: ['sales'],
                company: company._id,
                branch: branch._id,
                passwordChanged: false
            },
            {
                name: `${name} Warehouse`,
                username: warehouseCreds.username,
                password: warehouseCreds.password,
                roles: ['warehouse'],
                company: company._id,
                branch: branch._id,
                passwordChanged: false
            }
        ];

        for (const userData of users) {
            await User.create(userData);
        }

        // Send credentials to admin email
        try {
            const emailHtml = credentialsTemplate(name, shopId, {
                admin: adminCreds,
                sales: salesCreds,
                warehouse: warehouseCreds
            }, logoUrl);

            await sendEmail({
                to: email,
                subject: `Welcome to FlowPOS - Credentials for ${name}`,
                html: emailHtml
            });
        } catch (emailError) {
            console.error('Failed to send credentials email:', emailError);
            // We don't fail the request if email fails, but we log it
        }

        res.status(201).json({
            company,
            branch,
            teamCredentials: {
                admin: adminCreds,
                sales: salesCreds,
                warehouse: warehouseCreds
            }
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update company status/plan
// @route   PUT /api/companies/:id
// @access  Private (Super Admin)
// @desc    Update company status (Super Admin)
// @route   PUT /api/companies/:id/status
// @access  Private (Super Admin)
const updateCompanyStatus = async (req, res) => {
    try {
        const company = await Company.findById(req.params.id);
        if (!company) return res.status(404).json({ message: 'Company not found' });

        company.isActive = req.body.isActive;
        await company.save();

        // Log action
        const AuditLog = require('../models/AuditLog');
        await AuditLog.create({
            user: req.user._id,
            company: company._id,
            action: company.isActive ? 'ACTIVATE_SHOP' : 'DEACTIVATE_SHOP',
            description: `${company.isActive ? 'Activated' : 'Deactivated'} shop: ${company.name}`,
        });

        res.json({ message: `Shop ${company.isActive ? 'activated' : 'deactivated'} successfully`, isActive: company.isActive });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update company (Super Admin)
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

// @desc    Update OWN company branding (Admin)
// @route   PUT /api/companies/me
// @access  Private (Admin)
const updateOwnCompany = async (req, res) => {
    try {
        const company = await Company.findById(req.companyId);

        if (company) {
            company.name = req.body.name ?? company.name;
            company.logoUrl = req.body.logoUrl ?? company.logoUrl;
            company.primaryColor = req.body.primaryColor ?? company.primaryColor;
            company.secondaryColor = req.body.secondaryColor ?? company.secondaryColor;
            company.currencySymbol = req.body.currencySymbol ?? company.currencySymbol;
            company.address = req.body.address ?? company.address;
            company.phone = req.body.phone ?? company.phone;

            const updatedCompany = await company.save();
            res.json(updatedCompany);
        } else {
            res.status(404).json({ message: 'Company not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Reset shop admin password
// @route   PUT /api/companies/:id/reset-password
// @access  Private (Super Admin)
const resetCompanyAdminPassword = async (req, res) => {
    try {
        const company = await Company.findById(req.params.id);
        if (!company) return res.status(404).json({ message: 'Company not found' });

        // Find the admin user of this company
        const admin = await User.findOne({ company: company._id, roles: 'admin' });
        if (!admin) return res.status(404).json({ message: 'Admin user not found for this shop' });

        const tempPassword = Math.random().toString(36).slice(-8);
        admin.password = tempPassword;
        admin.passwordChanged = false;
        await admin.save();

        // Send email
        const { sendEmail } = require('../utils/emailService');
        await sendEmail({
            to: admin.email,
            subject: `Password Reset for ${company.name}`,
            text: `Your admin password has been reset by the Super Admin. \n\nNew Password: ${tempPassword}\n\nPlease login and change it immediately.`
        });

        // Log this action
        const AuditLog = require('../models/AuditLog');
        await AuditLog.create({
            user: req.user._id,
            company: company._id,
            action: 'RESET_ADMIN_PASSWORD',
            description: `Reset admin password for shop: ${company.name}`,
        });

        res.json({ message: 'Admin password reset successful. New password sent to email.' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    getCompanies,
    getCompany,
    createCompany,
    updateCompany,
    getGlobalStats,
    updateCompanyStatus,
    resetCompanyAdminPassword
};
