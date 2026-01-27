const mongoose = require('mongoose');

const notificationSchema = mongoose.Schema({
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
        ref: 'User'
    }, // If specific to one user
    roles: [{ type: String }], // If sent to all users with a role
    title: { type: String, required: true },
    message: { type: String, required: true },
    type: { type: String, enum: ['INFO', 'WARNING', 'SUCCESS', 'ERROR'], default: 'INFO' },
    isRead: { type: Boolean, default: false },
    data: { type: Map, of: String } // For deep linking in app
}, {
    timestamps: true
});

const Notification = mongoose.model('Notification', notificationSchema);
module.exports = Notification;
