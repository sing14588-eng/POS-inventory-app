const express = require('express');
const router = express.Router();
const { getPendingOrders, markOrderPrepared } = require('../controllers/pickerController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/orders', protect, authorize('picker', 'admin'), getPendingOrders);
router.put('/orders/:id/prepare', protect, authorize('picker', 'admin'), markOrderPrepared);

module.exports = router;
