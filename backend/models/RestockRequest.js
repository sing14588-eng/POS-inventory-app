const mongoose = require('mongoose');

const restockRequestSchema = mongoose.Schema({
    product: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Product',
        required: true,
    },
    requestedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    status: {
        type: String,
        enum: ['pending', 'fulfilled'],
        default: 'pending',
    },
}, {
    timestamps: true,
});

module.exports = mongoose.model('RestockRequest', restockRequestSchema);
