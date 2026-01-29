const AuditLog = require('../models/AuditLog');

// @desc    Get activity logs
// @route   GET /api/audit
// @access  Private (Admin / Super Admin)
const getAuditLogs = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 50;
        const skip = (page - 1) * limit;

        const query = {};

        // If not super admin, restrict to own company
        if (req.user.roles.includes('superadmin')) {
            if (req.query.companyId) query.company = req.query.companyId;
        } else {
            query.company = req.companyId;
        }

        // Search logic (optional)
        if (req.query.search) {
            query.$or = [
                { action: { $regex: req.query.search, $options: 'i' } },
                { description: { $regex: req.query.search, $options: 'i' } }
            ];
        }

        if (req.query.targetBranchId) query.branch = req.query.targetBranchId;
        if (req.query.targetUserId) query.user = req.query.targetUserId;
        if (req.query.actionType) query.actionType = req.query.actionType;

        const total = await AuditLog.countDocuments(query);
        const logs = await AuditLog.find(query)
            .populate('user', 'name email')
            .populate('branch', 'name')
            .populate('company', 'name shopId') // Added for Super Admin visibility
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);

        res.json({
            logs,
            page,
            pages: Math.ceil(total / limit),
            total
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getAuditLogs };
