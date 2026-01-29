const User = require('../models/User');
const Company = require('../models/Company');
const jwt = require('jsonwebtoken');
const { sendEmail } = require('../utils/emailService');

const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '30d',
    });
};

// @desc    Auth user & get token
// @route   POST /api/auth/login
// @access  Public
const loginUser = async (req, res) => {
    try {
        const { email, username, password } = req.body;
        const loginId = email || username; // Support both field names from frontend
        console.log(`[Auth] Login attempt for: ${loginId}`);

        // Find user by email OR username
        const user = await User.findOne({
            $or: [
                { email: loginId },
                { username: loginId }
            ]
        });

        if (!user) {
            console.log(`[Auth] User NOT FOUND: ${loginId}`);
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        console.log(`[Auth] User found: ${user.email || user.username}. Verifying password...`);
        const isMatch = await user.matchPassword(password);

        if (isMatch) {
            console.log(`[Auth] Password matched for: ${loginId}`);

            // 1. Check if User belongs to a deactivated Company
            if (user.company) {
                const company = await Company.findById(user.company);
                if (company && !company.isActive) {
                    console.log(`[Auth] Shop deactivated: ${company.name}`);
                    return res.status(403).json({
                        message: 'Your account is deactivated. Please contact support.'
                    });
                }
            }

            // 2. Check individual user activation (for Super Admins or Staff)
            if (!user.isActive) {
                console.log(`[Auth] User account suspended: ${loginId}`);
                return res.status(403).json({ message: 'User account suspended. Contact Admin.' });
            }

            // Send welcome email to Super Admin if it's their first login with the new email
            if (user.roles.includes('super_admin') && user.email === 'singsongadisu@gmail.com' && !user.welcomeEmailSent) {
                try {
                    const { welcomeTemplate } = require('../utils/emailTemplates');

                    // Use a hosted URL to ensure visibility and prevent attachment bar
                    const logoUrl = 'https://api.bnox.online/uploads/logo-hub.png';

                    await sendEmail({
                        to: user.email,
                        subject: 'FlowPos | Secure Access Identified',
                        html: welcomeTemplate(user.name, user.email, logoUrl)
                    });
                    user.welcomeEmailSent = true;
                    await user.save();
                } catch (emailError) {
                    console.error('Error sending welcome email:', emailError);
                }
            }

            console.log(`[Auth] Populating company/branch for: ${email}`);
            const populatedUser = await User.findById(user._id).populate('company').populate('branch');

            console.log(`[Auth] Login successful: ${email}`);
            res.json({
                _id: user._id,
                name: user.name,
                email: user.email,
                roles: user.roles,
                company: populatedUser.company ? populatedUser.company : null,
                branch: populatedUser.branch ? populatedUser.branch : null,
                passwordChanged: user.passwordChanged,
                token: generateToken(user._id),
                onboardingCompleted: user.onboardingCompleted
            });
        } else {
            console.log(`[Auth] Password MISMATCH for: ${email}`);
            res.status(401).json({ message: 'Invalid email or password' });
        }
    } catch (error) {
        console.error(`[Auth ERROR] ${error.stack}`);
        res.status(500).json({ message: 'Internal Server Error during login' });
    }
};

// @desc    Get current user profile
// @route   GET /api/auth/me
// @access  Private
const getMe = async (req, res) => {
    try {
        const user = await User.findById(req.user._id).populate('company').populate('branch');
        if (user) {
            res.json({
                _id: user._id,
                name: user.name,
                email: user.email,
                roles: user.roles,
                company: user.company,
                branch: user.branch,
                onboardingCompleted: user.onboardingCompleted,
                passwordChanged: user.passwordChanged
            });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
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
            { name: 'Sales User', email: 'sales@test.com', password: '123456', roles: ['sales'], company: company._id },
            { name: 'Warehouse User', email: 'ware@test.com', password: '123456', roles: ['warehouse'], company: company._id },
            { name: 'Accountant User', email: 'acc@test.com', password: '123456', roles: ['accountant'], company: company._id },
            { name: 'Admin User', email: 'admin@test.com', password: '123456', roles: ['admin'], company: company._id },
            { name: 'Super Admin', email: 'super@test.com', password: '123456', roles: ['super_admin'] }, // No company for super admin
        ];

        for (const user of users) {
            await User.create(user);
        }

        res.json({ message: 'Seeded successfully', company, userCount: users.length });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { loginUser, seedUsers, getMe };
