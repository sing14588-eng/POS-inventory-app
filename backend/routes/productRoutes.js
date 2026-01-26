const express = require('express');
const router = express.Router();
const { getProducts, createProduct, updateProduct } = require('../controllers/productController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.route('/')
    .get(protect, authorize('sales', 'warehouse', 'admin'), getProducts)
    .post(protect, authorize('warehouse', 'admin'), createProduct);

router.route('/:id')
    .put(protect, authorize('warehouse', 'admin'), updateProduct);

module.exports = router;
