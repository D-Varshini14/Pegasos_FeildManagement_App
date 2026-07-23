const db = require('../config/database');

const getUserProfile = (req, res) => {
    const userId = req.user.userId;

    const query = `
    SELECT u.*, 
           COUNT(t.id) as total_tasks,
           COUNT(CASE WHEN t.status = 'completed' THEN 1 END) as completed_tasks,
           AVG(CASE WHEN t.avg_time_per_visit IS NOT NULL THEN t.avg_time_per_visit END) as avg_time,
           AVG(t.customer_feedback) as avg_feedback
    FROM users u
    LEFT JOIN tasks t ON u.id = t.assigned_to AND MONTH(t.created_at) = MONTH(NOW())
    WHERE u.id = ?
    GROUP BY u.id
  `;

    db.execute(query, [userId], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        const user = results[0];
        const completionRate = user.total_tasks > 0 ? (user.completed_tasks / user.total_tasks) * 100 : 0;

        res.json({
            ...user,
            monthly_tasks_completed: user.completed_tasks || 0,
            avg_time_per_visit: Math.round(user.avg_time || 32),
            target_completion: Math.round(completionRate),
            customer_feedback: parseFloat((user.avg_feedback || 4.8).toFixed(1))
        });
    });
};

const updateProfile = (req, res) => {
    const userId = req.user.userId;
    const { name, email, phone } = req.body;

    const query = 'UPDATE users SET name = ?, email = ?, phone = ? WHERE id = ?';

    db.execute(query, [name, email, phone, userId], (err, result) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }
        res.json({ message: 'Profile updated successfully' });
    });
};

module.exports = { getUserProfile, updateProfile };