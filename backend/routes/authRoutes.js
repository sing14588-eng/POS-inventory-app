const express = require('express');
const router = express.Router();
const { loginUser, seedUsers, getMe, switchRole } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

router.post('/login', loginUser);
router.post('/switch-role', protect, switchRole);
router.get('/me', protect, getMe);
router.post('/seed', seedUsers);
router.get('/seed', seedUsers);

module.exports = router;
