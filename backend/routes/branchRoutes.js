const express = require('express');
const router = express.Router();
const { getBranches, createBranch, updateBranch } = require('../controllers/branchController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.route('/')
    .get(protect, authorize('admin'), getBranches)
    .post(protect, authorize('admin'), createBranch);

router.route('/:id')
    .put(protect, authorize('admin'), updateBranch);

module.exports = router;
