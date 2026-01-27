const mongoose = require('mongoose');

const saleSchema = mongoose.Schema({
    items: [{
        product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
        productName: { type: String, required: true }, // Store name in case product is deleted
        quantity: { type: Number, required: true },
        unitType: { type: String, required: true },
        pricePerUnit: { type: Number, required: true },
        total: { type: Number, required: true },
    }],
    totalAmount: { type: Number, required: true },
    vatAmount: { type: Number, required: true },
    isCredit: { type: Boolean, default: false, required: true },
    status: { type: String, default: 'Completed', enum: ['Completed', 'Pending'] }, // potentially for preparation
    refundStatus: {
        type: String,
        enum: ['none', 'requested', 'approved'],
        default: 'none'
    },
    refundReason: String,
    creditSettled: { type: Boolean, default: true },
    salesRep: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    company: { type: mongoose.Schema.Types.ObjectId, ref: 'Company', required: true },
    branch: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch' },
}, {
    timestamps: true,
});

const Sale = mongoose.model('Sale', saleSchema);

module.exports = Sale;
