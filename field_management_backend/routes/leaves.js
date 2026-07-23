const express = require('express');
const { applyLeave, getLeaves } = require('../controllers/leaveController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

router.post('/', authenticateToken, applyLeave);
router.get('/', authenticateToken, getLeaves);

module.exports = router;