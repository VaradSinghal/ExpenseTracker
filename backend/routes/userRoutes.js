const express = require('express');
const router = express.Router();
const { authenticateUser } = require('../middleware/authMiddleware');
const { setBankBalance, getUserInfo } = require('../controllers/userController');

router.put('/set-bank-balance', authenticateUser, setBankBalance);
router.get('/user-info', authenticateUser, getUserInfo);

module.exports = router;