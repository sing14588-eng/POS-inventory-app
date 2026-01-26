const User = require('../models/User');
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

        res.json({
            _id: user._id,
            name: user.name,
            email: user.email,
            roles: user.roles, // Changed from role
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
    const users = [
        { name: 'Sales User', email: 'sales@test.com', password: '123', roles: ['sales'] },
        { name: 'Picker User', email: 'picker@test.com', password: '123', roles: ['picker'] },
        { name: 'Accountant User', email: 'acc@test.com', password: '123', roles: ['accountant'] },
        { name: 'Warehouse User', email: 'ware@test.com', password: '123', roles: ['warehouse'] },
        { name: 'Super Admin', email: 'admin@test.com', password: '123', roles: ['admin', 'sales', 'warehouse', 'accountant', 'picker'] },
    ];

    try {
        await User.deleteMany(); // Clear existing

        // Loop to trigger pre-save hook for hashing
        for (const user of users) {
            await User.create(user);
        }

        res.json(users);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { loginUser, seedUsers };
