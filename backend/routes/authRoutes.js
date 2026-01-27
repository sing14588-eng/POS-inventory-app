const express = require('express');
const router = express.Router();
const { loginUser, seedUsers } = require('../controllers/authController');

router.post('/login', loginUser);
router.post('/seed', seedUsers);
router.get('/seed', seedUsers);

module.exports = router;
