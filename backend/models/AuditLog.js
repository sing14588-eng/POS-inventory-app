const mongoose = require('mongoose');

const auditLogSchema = mongoose.Schema({
    company: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Company',
        required: true
    },
    branch: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Branch'
    },
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    action: { type: String, required: true }, // e.g., 'SALE_CREATED', 'STOCK_UPDATED'
    details: { type: String }, // JSON string or text summary
    itemType: { type: String }, // e.g., 'Product', 'Sale'
    itemId: { type: String },
    ipAddress: { type: String }
}, {
    timestamps: true
});

const AuditLog = mongoose.model('AuditLog', auditLogSchema);
module.exports = AuditLog;
