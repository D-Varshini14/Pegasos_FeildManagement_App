const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

// POST /api/activities/log
// Log a sign-in or sign-out activity
router.post('/log', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id || req.user.userId;
        const { type, location } = req.body;
        const { timestamp, date, day } = req.body;

        if (!type || !['sign_in', 'sign_out'].includes(type)) {
            return res.status(400).json({ success: false, message: 'Invalid activity type' });
        }

        const query = `
            INSERT INTO activities (user_id, type, timestamp, date, day, location) 
            VALUES (?, ?, ?, ?, ?, ?)
        `;
        
        await db.execute(query, [userId, type, timestamp, date, day, location || 'Location not available']);

        res.status(201).json({ success: true, message: 'Activity logged successfully' });
    } catch (error) {
        console.error('Error logging activity:', error);
        res.status(500).json({ success: false, message: 'Internal server error' });
    }
});

// GET /api/activities
// Get all activities for the logged-in user, auto-deleting records older than 31 days
router.get('/', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id || req.user.userId;

        // Auto-delete records older than 31 days
        await db.execute('DELETE FROM activities WHERE created_at < NOW() - INTERVAL 31 DAY');

        const [activities] = await db.execute(
            'SELECT * FROM activities WHERE user_id = ? ORDER BY timestamp DESC',
            [userId]
        );

        res.status(200).json({ success: true, data: activities });
    } catch (error) {
        console.error('Error fetching activities:', error);
        res.status(500).json({ success: false, message: 'Internal server error' });
    }
});

module.exports = router;
