const db = require('../config/database');
const moment = require('moment');

const getTasks = (req, res) => {
    const userId = req.user.userId;
    const query = `
    SELECT t.*, u.name as assigned_to_name 
    FROM tasks t 
    LEFT JOIN users u ON t.assigned_to = u.id 
    WHERE t.assigned_to = ? 
    ORDER BY t.scheduled_time ASC
  `;

    db.execute(query, [userId], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }
        res.json(results);
    });
};

const updateTaskStatus = (req, res) => {
    const { taskId } = req.params;
    const { status, notes } = req.body;

    const query = 'UPDATE tasks SET status = ?, notes = ?, updated_at = NOW() WHERE id = ?';

    db.execute(query, [status, notes, taskId], (err, result) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }
        res.json({ message: 'Task updated successfully' });
    });
};

const createTask = (req, res) => {
    const { title, description, assignedTo, location, scheduledTime, type } = req.body;

    const query = `
    INSERT INTO tasks (title, description, assigned_to, location, scheduled_time, type, status, created_at)
    VALUES (?, ?, ?, ?, ?, ?, 'pending', NOW())
  `;

    db.execute(query, [title, description, assignedTo, location, scheduledTime, type], (err, result) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }
        res.json({ message: 'Task created successfully', taskId: result.insertId });
    });
};

module.exports = { getTasks, updateTaskStatus, createTask };