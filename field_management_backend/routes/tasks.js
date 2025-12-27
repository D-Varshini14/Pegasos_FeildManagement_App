const express = require('express');
const { getTasks, updateTaskStatus, createTask } = require('../controllers/taskController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

router.get('/', authenticateToken, getTasks);
router.put('/:taskId/status', authenticateToken, updateTaskStatus);
router.post('/', authenticateToken, createTask);

module.exports = router;