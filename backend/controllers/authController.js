const User = require('../models/User');
const Company = require('../models/Company');
const jwt = require('jsonwebtoken');

const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '30d',
    });
};

// @desc    Auth user & get token
// @route   POST /api/auth/login
// @access  Public
const loginUser = async (req, res) => {
    const { email, password } = req.body;

    const user = await User.findOne({ email });

    if (user && (await user.matchPassword(password))) {
        if (!user.isActive) {
            return res.status(403).json({ message: 'Account is suspended. Contact Admin.' });
        }

        const populatedUser = await User.findById(user._id).populate('company').populate('branch');

        res.json({
            _id: user._id,
            name: user.name,
            email: user.email,
            roles: user.roles,
            company: populatedUser.company ? populatedUser.company : null,
            branch: populatedUser.branch ? populatedUser.branch : null,
            token: generateToken(user._id),
        });
    } else {
        res.status(401).json({ message: 'Invalid email or password' });
    }
};

// @desc    Seed users
// @route   POST /api/auth/seed
// @access  Public (for initial setup)
const seedUsers = async (req, res) => {
    try {
        await Company.deleteMany();
        await User.deleteMany();

        const company = await Company.create({
            name: 'Default POS Shop',
            email: 'main@pos.com',
            plan: 'premium'
        });

        const users = [
            { name: 'Sales User', email: 'sales@test.com', password: '123', roles: ['sales'], company: company._id },
            { name: 'Warehouse User', email: 'ware@test.com', password: '123', roles: ['warehouse'], company: company._id },
            { name: 'Accountant User', email: 'acc@test.com', password: '123', roles: ['accountant'], company: company._id },
            { name: 'Admin User', email: 'admin@test.com', password: '123', roles: ['admin'], company: company._id },
            { name: 'Super Admin', email: 'super@test.com', password: '123', roles: ['super_admin'] }, // No company for super admin
        ];

        for (const user of users) {
            await User.create(user);
        }

        res.json({ message: 'Seeded successfully', company, userCount: users.length });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { loginUser, seedUsers };
