const express = require('express');
const router = express.Router();
const { getDailyReport } = require('../controllers/reportController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/daily', protect, authorize('accountant', 'admin'), getDailyReport);

module.exports = router;
