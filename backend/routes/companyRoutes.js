const express = require('express');
const router = express.Router();
const {
    getCompanies,
    createCompany,
    updateCompany,
    updateOwnCompany,
    getGlobalStats,
    updateCompanyStatus,
    resetCompanyAdminPassword
} = require('../controllers/companyController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/stats', protect, authorize('super_admin'), getGlobalStats);

router.route('/')
    .get(protect, authorize('super_admin'), getCompanies)
    .post(protect, authorize('super_admin'), createCompany);

router.put('/me', protect, authorize('admin'), updateOwnCompany);
router.put('/:id/status', protect, authorize('super_admin'), updateCompanyStatus);
router.put('/:id/reset-password', protect, authorize('super_admin'), resetCompanyAdminPassword);

router.route('/:id')
    .put(protect, authorize('super_admin'), updateCompany);

module.exports = router;
