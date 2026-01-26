const express = require('express');
const router = express.Router();
const { createRestockRequest, getRestockRequests, fulfillRestockRequest } = require('../controllers/restockController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.route('/')
    .post(protect, createRestockRequest)
    .get(protect, authorize('warehouse', 'admin'), getRestockRequests);

router.put('/:id/fulfill', protect, authorize('warehouse', 'admin'), fulfillRestockRequest);

module.exports = router;
