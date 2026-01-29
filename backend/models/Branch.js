const mongoose = require('mongoose');

const branchSchema = mongoose.Schema({
    company: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Company',
        required: true
    },
    name: { type: String, required: true },
    address: { type: String },
    phone: { type: String },
    manager: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    status: { type: Boolean, default: true },
    isActive: { type: Boolean, default: true } // Keeping isActive for compatibility if already used
}, {
    timestamps: true
});

const Branch = mongoose.model('Branch', branchSchema);
module.exports = Branch;
