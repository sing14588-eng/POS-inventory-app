const mongoose = require('mongoose');

const productSchema = mongoose.Schema({
    name: { type: String, required: true },
    category: { type: String, required: true, enum: ['Balloon', 'Cushion'] },
    size: { type: String, required: true, enum: ['Small', 'Medium', 'Large'] },
    fruitQuantity: { type: Number, default: 0 }, // If applicable
    unitType: { type: String, required: true, enum: ['PIECE', 'WEIGHT'] },
    currentStock: { type: Number, required: true, default: 0 },
    shelfLocation: { type: String, required: true }, // e.g., A-1
    price: { type: Number, required: true, default: 0 }, // Added price for POS calculation
    barcode: { type: String, unique: true, sparse: true },
    company: { type: mongoose.Schema.Types.ObjectId, ref: 'Company', required: true },
    branch: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch' },
}, {
    timestamps: true,
});

const Product = mongoose.model('Product', productSchema);

module.exports = Product;
