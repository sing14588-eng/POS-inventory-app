const mongoose = require('mongoose');

const companySchema = mongoose.Schema({
    name: { type: String, required: true },
    address: { type: String },
    phone: { type: String },
    email: { type: String, unique: true },
    isActive: { type: Boolean, default: true },
    plan: {
        type: String,
        enum: ['basic', 'premium', 'enterprise'],
        default: 'basic'
    },
    logoUrl: { type: String, default: '' },
    primaryColor: { type: String, default: '#000000' }, // Default to Black/Theme primary
    secondaryColor: { type: String, default: '#666666' },
    currencySymbol: { type: String, default: '$' },
    receiptHeader: { type: String, default: '' },
    receiptFooter: { type: String, default: 'Thank you for your business!' },
}, {
    timestamps: true,
});

const Company = mongoose.model('Company', companySchema);

module.exports = Company;
