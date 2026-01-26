const express = require('express');
const router = express.Router();
const { getUsers, createUser, updateUser } = require('../controllers/userController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.route('/')
    .get(protect, authorize('admin'), getUsers)
    .post(protect, authorize('admin'), createUser);

router.route('/:id')
    .put(protect, authorize('admin'), updateUser);

module.exports = router;
