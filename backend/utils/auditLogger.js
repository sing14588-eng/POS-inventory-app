const AuditLog = require('../models/AuditLog');

const logAction = async (req, { action, details, itemType, itemId }) => {
    try {
        await AuditLog.create({
            company: req.user.company,
            branch: req.user.branch,
            user: req.user._id,
            action,
            details,
            itemType,
            itemId,
            ipAddress: req.ip
        });
    } catch (error) {
        console.error('Audit Log Error:', error);
        // We don't want to throw error and stop the main process just because logging failed
    }
};

module.exports = { logAction };
