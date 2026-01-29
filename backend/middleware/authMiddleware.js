const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
    let token;

    if (
        req.headers.authorization &&
        req.headers.authorization.startsWith('Bearer')
    ) {
        try {
            console.log(`[AuthMW] Auth Header: ${req.headers.authorization}`);
            token = req.headers.authorization.split(' ')[1].trim();
            console.log(`[AuthMW] Extracted Token: "${token}"`);

            const decoded = jwt.verify(token, process.env.JWT_SECRET);

            req.user = await User.findById(decoded.id).select('-password');
            req.activeRole = decoded.activeRole; // Attach active role from token

            if (!req.user) {
                console.log(`[AuthMW] User NOT FOUND for token`);
                return res.status(401).json({ message: 'User not found' });
            }

            if (!req.user.isActive) {
                console.log(`[AuthMW] Account deactivated: ${req.user.email}`);
                return res.status(401).json({ message: 'User account is deactivated' });
            }

            // Attach company and branch context
            req.companyId = req.user.company;
            req.branchId = req.user.branch;

            next();
        } catch (error) {
            console.error(`[AuthMW ERROR] ${error.stack || error.message}`);
            res.status(401).json({ message: 'Not authorized, token failed' });
        }
    }

    if (!token) {
        res.status(401).json({ message: 'Not authorized, no token' });
    }
};

const authorize = (...requiredRoles) => {
    return (req, res, next) => {
        // Bypass for Super Admin (checks actual user roles, not just active context)
        if (req.user && req.user.roles && req.user.roles.includes('super_admin')) {
            return next();
        }

        if (!req.activeRole) {
            return res.status(403).json({ message: 'No active role context found' });
        }

        if (!requiredRoles.includes(req.activeRole)) {
            return res.status(403).json({
                message: `Your active role (${req.activeRole}) is not authorized. Required: ${requiredRoles.join(', ')}`
            });
        }
        next();
    };
};

module.exports = { protect, authorize };
