const mongoose = require('mongoose');

const supplierSchema = mongoose.Schema({
    company: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Company',
        required: true
    },
    name: { type: String, required: true },
    contactPerson: { type: String },
    phone: { type: String },
    email: { type: String },
    address: { type: String },
    categories: [{ type: String }], // What do they provide?
    isActive: { type: Boolean, default: true }
}, {
    timestamps: true
});

const Supplier = mongoose.model('Supplier', supplierSchema);
module.exports = Supplier;
