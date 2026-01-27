const User = require('../models/User');

// @desc    Get all users
// @route   GET /api/users
// @access  Private (Admin)
const getUsers = async (req, res) => {
    try {
        let query = { company: req.companyId };

        // Super Admin sees all
        if (req.user.roles.includes('super_admin')) {
            query = {};
        }

        const users = await User.find(query).select('-password');
        res.json(users);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Create new user
// @route   POST /api/users
// @access  Private (Admin)
const createUser = async (req, res) => {
    const { name, email, password, roles } = req.body;

    try {
        const userExists = await User.findOne({ email });
        if (userExists) {
            return res.status(400).json({ message: 'User already exists' });
        }

        const user = await User.create({
            name,
            email,
            password,
            roles: roles || ['sales'], // Default to sales if not provided
            company: req.companyId
        });

        if (user) {
            res.status(201).json({
                _id: user._id,
                name: user.name,
                email: user.email,
                roles: user.roles,
            });
        } else {
            res.status(400).json({ message: 'Invalid user data' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Update user (active status, roles, password reset)
// @route   PUT /api/users/:id
// @access  Private (Admin)
const updateUser = async (req, res) => {
    try {
        const user = await User.findById(req.params.id);

        if (user) {
            user.name = req.body.name || user.name;
            user.email = req.body.email || user.email;
            if (req.body.roles) user.roles = req.body.roles;
            if (req.body.isActive !== undefined) user.isActive = req.body.isActive;

            // Password reset if provided
            if (req.body.password) {
                user.password = req.body.password;
            }

            const updatedUser = await user.save();

            res.json({
                _id: updatedUser._id,
                name: updatedUser.name,
                email: updatedUser.email,
                roles: updatedUser.roles,
                isActive: updatedUser.isActive,
            });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const completeOnboarding = async (req, res) => {
    try {
        const user = await User.findById(req.user._id);
        if (user) {
            user.onboardingCompleted = true;
            await user.save();
            res.json({ message: 'Onboarding marked as complete' });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getUsers, createUser, updateUser, changePassword, completeOnboarding };
