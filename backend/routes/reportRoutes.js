const express = require('express');
const router = express.Router();
const { getDailyReport, getGlobalStats } = require('../controllers/reportController');
const { getAnalytics } = require('../controllers/analyticsController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/daily', protect, authorize('accountant', 'admin'), getDailyReport);
router.get('/analytics', protect, authorize('accountant', 'admin'), getAnalytics);
router.get('/global', protect, authorize('super_admin'), getGlobalStats);

module.exports = router;
