const AuditLog = require('../models/AuditLog');

// @desc    Get activity logs
// @route   GET /api/audit
// @access  Private (Admin)
const getAuditLogs = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = 50;
        const skip = (page - 1) * limit;

        const query = { company: req.companyId };
        // Optional: Filter by branch or user
        if (req.query.branchId) query.branch = req.query.branchId;
        if (req.query.userId) query.user = req.query.userId;

        const total = await AuditLog.countDocuments(query);
        const logs = await AuditLog.find(query)
            .populate('user', 'name email')
            .populate('branch', 'name')
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
