const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
    let token;

    if (
        req.headers.authorization &&
        req.headers.authorization.startsWith('Bearer')
    ) {
        try {
            token = req.headers.authorization.split(' ')[1];

            const decoded = jwt.verify(token, process.env.JWT_SECRET);

            req.user = await User.findById(decoded.id).select('-password');

            if (!req.user) {
                return res.status(401).json({ message: 'User not found' });
            }

            if (!req.user.isActive) {
                return res.status(401).json({ message: 'User account is deactivated' });
            }

            // Attach company and branch context
            req.companyId = req.user.company;
            req.branchId = req.user.branch;

            next();
        } catch (error) {
            console.error(error);
            res.status(401).json({ message: 'Not authorized, token failed' });
        }
    }

    if (!token) {
        res.status(401).json({ message: 'Not authorized, no token' });
    }
};

const authorize = (...requiredRoles) => {
    return (req, res, next) => {
        if (!req.user || !req.user.roles) {
            return res.status(403).json({ message: 'Access denied' });
        }

        // Super Admin bypass
        if (req.user.roles.includes('super_admin')) {
            return next();
        }

        const hasRole = req.user.roles.some(role => requiredRoles.includes(role));
        if (!hasRole) {
            return res.status(403).json({
                message: `Your roles are not authorized to access this route`
            });
        }
        next();
    };
};

module.exports = { protect, authorize };
