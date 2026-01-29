const express = require('express');
const router = express.Router();
const { getDailyReport, getGlobalStats, getShopAdminStats } = require('../controllers/reportController');
const { getAnalytics } = require('../controllers/analyticsController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/daily', protect, authorize('accountant', 'shop_admin'), getDailyReport);
router.get('/admin-stats', protect, authorize('accountant', 'shop_admin'), getShopAdminStats);
router.get('/analytics', protect, authorize('accountant', 'shop_admin'), getAnalytics);
router.get('/global', protect, authorize('super_admin'), getGlobalStats);

module.exports = router;
