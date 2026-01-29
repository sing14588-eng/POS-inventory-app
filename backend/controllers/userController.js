const User = require('../models/User');

// @desc    Get all users
// @route   GET /api/users
// @access  Private (Admin)
const getUsers = async (req, res) => {
    try {
        let query = { company: req.companyId };

        if (req.query.branch) {
            query.branch = req.query.branch;
        }

        // Super Admin sees all
        if (req.user.role === 'super_admin') {
            query = {};
        }

        const users = await User.find(query).select('-password');
        res.json(users);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const createUser = async (req, res) => {
    const { name, email, username, password, roles, branch } = req.body;

    try {
        // Check if user already exists by email OR username
        const userExists = await User.findOne({ $or: [{ email: email || 'never' }, { username: username || 'never' }] });
        if (userExists) {
            return res.status(400).json({ message: 'User already exists' });
        }

        const user = await User.create({
            name,
            email,
            username,
            password,
            roles: (roles && roles.length > 0) ? roles : ['sales'], // Default to sales if empty
            branch,
            company: req.companyId,
            passwordChanged: false // Force change on first login as per spec
        });

        if (user) {
            res.status(201).json({
                _id: user._id,
                name: user.name,
                email: user.email,
                username: user.username,
                roles: user.roles, // Return roles array
                branch: user.branch,
                // Include password in response for creating staff (shown once)
                password: password
            });
        } else {
            res.status(400).json({ message: 'Invalid user data' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateUser = async (req, res) => {
    try {
        const user = await User.findById(req.params.id);

        if (user) {
            user.name = req.body.name || user.name;
            user.email = req.body.email || user.email;
            user.username = req.body.username || user.username;
            if (req.body.roles) user.roles = req.body.roles; // Update roles array
            if (req.body.branch !== undefined) user.branch = req.body.branch;
            if (req.body.isActive !== undefined) user.isActive = req.body.isActive;

            if (req.body.password) {
                user.password = req.body.password;
                user.passwordChanged = false;
            }

            const updatedUser = await user.save();

            res.json({
                _id: updatedUser._id,
                name: updatedUser.name,
                email: updatedUser.email,
                username: updatedUser.username,
                roles: updatedUser.roles,
                branch: updatedUser.branch,
                isActive: updatedUser.isActive,
            });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const changePassword = async (req, res) => {
    try {
        const { currentPassword, newPassword } = req.body;
        const user = await User.findById(req.user._id);

        if (user && (await user.matchPassword(currentPassword))) {
            user.password = newPassword;
            user.passwordChanged = true;
            await user.save();
            res.json({ message: 'Password changed successfully' });
        } else {
            res.status(401).json({ message: 'Invalid current password' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const resetUserPassword = async (req, res) => {
    try {
        const user = await User.findById(req.params.id);

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        if (req.user.role !== 'super_admin' && user.company.toString() !== req.companyId.toString()) {
            return res.status(403).json({ message: 'Not authorized to reset this user' });
        }

        const tempPassword = 'reset' + Math.floor(Math.random() * 899 + 100);
        user.password = tempPassword;
        user.passwordChanged = false;
        await user.save();

        res.json({
            message: 'Password reset successful',
            newPassword: tempPassword,
            email: user.email,
            username: user.username
        });
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
            res.json({ message: 'Onboarding marked as completed' });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getUsers, createUser, updateUser, changePassword, resetUserPassword, completeOnboarding };
