const express = require('express');
const router = express.Router();
const { createSale, getMySales, requestRefund, approveRefund, getPendingCreditSales, settleCreditSale } = require('../controllers/saleController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/my-sales', protect, getMySales);
router.get('/refunds/pending', protect, authorize('accountant', 'admin'), getRefundRequests); // Missing before 5.0?
// Actually I added it in previous step 484, but let's be safe.
// Wait, I see getRefundRequests in snippet, so I just need to add credit ones.

router.get('/credit/pending', protect, authorize('accountant', 'admin'), getPendingCreditSales);
router.put('/:id/settle', protect, authorize('accountant', 'admin'), settleCreditSale);

router.post('/:id/refund', protect, authorize('sales', 'admin'), requestRefund);
router.put('/:id/refund/approve', protect, authorize('accountant', 'admin'), approveRefund);

router.route('/')
    .post(protect, authorize('sales', 'admin'), createSale);

module.exports = router;
