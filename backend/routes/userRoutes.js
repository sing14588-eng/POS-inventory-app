const express = require('express');
const router = express.Router();
const { getUsers, createUser, updateUser, changePassword, completeOnboarding } = require('../controllers/userController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.route('/')
    .get(protect, authorize('admin', 'super_admin'), getUsers)
    .post(protect, authorize('admin'), createUser);

router.put('/change-password', protect, changePassword);
router.put('/onboarding-complete', protect, completeOnboarding);

router.route('/:id')
    .put(protect, authorize('admin'), updateUser);

module.exports = router;
