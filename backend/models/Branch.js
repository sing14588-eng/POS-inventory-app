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
    isActive: { type: Boolean, default: true }
}, {
    timestamps: true
});

const Branch = mongoose.model('Branch', branchSchema);
module.exports = Branch;
