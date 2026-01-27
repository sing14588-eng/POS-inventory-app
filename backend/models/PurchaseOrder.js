const mongoose = require('mongoose');

const purchaseOrderSchema = mongoose.Schema({
    company: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Company',
        required: true
    },
    branch: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Branch',
        required: true
    },
    supplier: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Supplier',
        required: true
    },
    items: [{
        product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
        quantity: { type: Number, required: true },
        costPrice: { type: Number, required: true }
    }],
    totalCost: { type: Number, required: true },
    status: {
        type: String,
        enum: ['pending', 'ordered', 'received', 'cancelled'],
        default: 'pending'
    },
    receivedDate: { type: Date },
    notes: { type: String }
}, {
    timestamps: true
});

const PurchaseOrder = mongoose.model('PurchaseOrder', purchaseOrderSchema);
module.exports = PurchaseOrder;
