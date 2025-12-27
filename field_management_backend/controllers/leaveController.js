const db = require('../config/database');

const applyLeave = (req, res) => {
    const userId = req.user.userId;
    const { leaveType, fromDate, toDate, notes } = req.body;

    const query = `
    INSERT INTO leaves (user_id, leave_type, from_date, to_date, notes, status, created_at)
    VALUES (?, ?, ?, ?, ?, 'pending', NOW())
  `;

    db.execute(query, [userId, leaveType, fromDate, toDate, notes], (err, result) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }
        res.json({ message: 'Leave application submitted successfully', leaveId: result.insertId });
    });
};

const getLeaves = (req, res) => {
    const userId = req.user.userId;

    const query = 'SELECT * FROM leaves WHERE user_id = ? ORDER BY created_at DESC';

    db.execute(query, [userId], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }
        res.json(results);
    });
};

module.exports = { applyLeave, getLeaves };