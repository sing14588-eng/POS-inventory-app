const express = require('express');
const router = express.Router();
const { getCompanies, createCompany, updateCompany } = require('../controllers/companyController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.route('/')
    .get(protect, authorize('super_admin'), getCompanies)
    .post(protect, authorize('super_admin'), createCompany);

router.route('/:id')
    .put(protect, authorize('super_admin'), updateCompany);

module.exports = router;
