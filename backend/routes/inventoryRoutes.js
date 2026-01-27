const express = require('express');
const router = express.Router();
const { getSuppliers, createSupplier } = require('../controllers/supplierController');
const { getPOs, createPO, updatePOStatus } = require('../controllers/poController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.route('/suppliers')
    .get(protect, getSuppliers)
    .post(protect, authorize('warehouse', 'admin'), createSupplier);

router.route('/')
    .get(protect, getPOs)
    .post(protect, authorize('warehouse', 'admin'), createPO);

router.route('/:id')
    .put(protect, authorize('warehouse', 'admin'), updatePOStatus);

module.exports = router;
