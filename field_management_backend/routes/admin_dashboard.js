const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken, requireAdmin, requireAdminOrManager } = require('../middleware/auth');

// ---- GET ADMIN DASHBOARD STATS ----
router.get('/stats', authenticateToken, requireAdminOrManager, async (req, res) => {
    try {
        const isManager = req.user.role === 'manager';
        const managerId = req.user.userId;

        let perfQuery = `
            SELECT 
                u.id, 
                u.name, 
                u.employee_id,
                COUNT(t.id) as total_tasks,
                COALESCE(SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END), 0) as completed_tasks,
                COALESCE(SUM(CASE WHEN t.status = 'missed' THEN 1 ELSE 0 END), 0) as missed_tasks,
                CASE 
                    WHEN COUNT(t.id) > 0 THEN (COALESCE(SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END), 0) / COUNT(t.id)) * 100 
                    ELSE 0 
                END as success_rate
            FROM users u
            LEFT JOIN tasks t ON u.id = t.assigned_to AND t.is_deleted = FALSE
            WHERE u.role = 'field_executive'
        `;
        const perfParams = [];
        if (isManager) {
            perfQuery += ` AND u.manager_id = ?`;
            perfParams.push(managerId);
        }
        perfQuery += ` GROUP BY u.id ORDER BY success_rate DESC`;
        const [performance] = await db.execute(perfQuery, perfParams);

        // 2. Recent missed tasks summary
        let missedQuery = `
            SELECT t.*, u.name as executive_name
            FROM tasks t
            JOIN users u ON t.assigned_to = u.id
            WHERE t.status = 'missed' AND t.is_deleted = FALSE
        `;
        const missedParams = [];
        if (isManager) {
            missedQuery += ` AND u.manager_id = ?`;
            missedParams.push(managerId);
        }
        missedQuery += ` ORDER BY t.updated_at DESC LIMIT 10`;
        const [recentMissed] = await db.execute(missedQuery, missedParams);

        // 3. Leads overview
        let leadsQuery = `
            SELECT 
                status, 
                COUNT(*) as count
            FROM leads
            WHERE is_deleted = FALSE
        `;
        const leadsParams = [];
        if (isManager) {
            leadsQuery += ` AND assigned_to IN (SELECT id FROM users WHERE manager_id = ?)`;
            leadsParams.push(managerId);
        }
        leadsQuery += ` GROUP BY status`;
        const [leadsStats] = await db.execute(leadsQuery, leadsParams);

        // 4. Visit activity (last 7 days)
        let visitQuery = `
            SELECT 
                DATE(t.created_at) as date,
                COUNT(*) as count
            FROM tasks t
            WHERE t.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
        `;
        const visitParams = [];
        if (isManager) {
            visitQuery += ` AND t.assigned_to IN (SELECT id FROM users WHERE manager_id = ?)`;
            visitParams.push(managerId);
        }
        visitQuery += ` GROUP BY DATE(t.created_at) ORDER BY date ASC`;
        const [visitActivity] = await db.execute(visitQuery, visitParams);

        return res.json({
            success: true,
            data: {
                performance,
                recentMissed,
                leadsStats,
                visitActivity
            }
        });
    } catch (error) {
        console.error('Admin stats error:', error);
        return res.status(500).json({ success: false, message: 'Failed to fetch admin statistics' });
    }
});

// ---- GET EXECUTIVE TRACKING (REAL-TIME-ISH) ----
router.get('/executive-tracking', authenticateToken, requireAdminOrManager, async (req, res) => {
    try {
        const isManager = req.user.role === 'manager';
        let query = `
            SELECT 
                u.id, 
                u.name, 
                u.employee_id,
                v.checkin_time,
                v.checkin_address,
                v.title as last_visit_title,
                v.status as last_visit_status
            FROM users u
            LEFT JOIN (
                SELECT * FROM tasks WHERE id IN (SELECT MAX(id) FROM tasks GROUP BY assigned_to)
            ) v ON u.id = v.assigned_to
            WHERE u.role = 'field_executive'
        `;
        const params = [];
        if (isManager) {
            query += ` AND u.manager_id = ?`;
            params.push(req.user.userId);
        }
        
        const [tracking] = await db.execute(query, params);

        return res.json({ success: true, data: tracking });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch tracking data' });
    }
});

// ---- GET TASKS FOR A SPECIFIC EXECUTIVE ----
router.get('/executive-tasks/:executiveId', authenticateToken, requireAdminOrManager, async (req, res) => {
    try {
        const { executiveId } = req.params;
        const { status } = req.query;

        // If manager, verify this executive belongs to them
        if (req.user.role === 'manager') {
            const [check] = await db.execute('SELECT manager_id FROM users WHERE id = ?', [executiveId]);
            if (check.length === 0 || check[0].manager_id !== req.user.userId) {
                return res.status(403).json({ success: false, message: 'Access denied to this executive data' });
            }
        }

        let query = `
            SELECT t.*, u.name AS executive_name, u.employee_id,
                   c.name AS client_display_name, c.phone AS client_phone, c.email AS client_email
            FROM tasks t
            LEFT JOIN users u ON t.assigned_to = u.id
            LEFT JOIN clients c ON t.client_id = c.id
            WHERE t.assigned_to = ? AND t.is_deleted = FALSE
        `;
        const params = [executiveId];

        if (status) {
            query += ' AND t.status = ?';
            params.push(status);
        }

        query += ' ORDER BY t.scheduled_time DESC';

        const [tasks] = await db.execute(query, params);

        // Also get summary counts
        const [counts] = await db.execute(`
            SELECT 
                COUNT(*) as total,
                COALESCE(SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END), 0) as completed,
                COALESCE(SUM(CASE WHEN status = 'pending' OR status = 'in_progress' THEN 1 ELSE 0 END), 0) as pending,
                COALESCE(SUM(CASE WHEN status = 'missed' THEN 1 ELSE 0 END), 0) as missed
            FROM tasks
            WHERE assigned_to = ? AND is_deleted = FALSE
        `, [executiveId]);

        return res.json({
            success: true,
            data: tasks,
            summary: {
                total: parseInt(counts[0]?.total) || 0,
                completed: parseInt(counts[0]?.completed) || 0,
                pending: parseInt(counts[0]?.pending) || 0,
                missed: parseInt(counts[0]?.missed) || 0
            }
        });
    } catch (error) {
        console.error('Executive tasks error:', error);
        return res.status(500).json({ success: false, message: 'Failed to fetch executive tasks' });
    }
});

// ---- ADMIN/MANAGER: UPDATE TASK DETAILS ----
router.put('/tasks/:taskId', authenticateToken, requireAdminOrManager, async (req, res) => {
    try {
        const { taskId } = req.params;
        
        // If manager, check if task belongs to their FE
        if (req.user.role === 'manager') {
            const [taskCheck] = await db.execute(`
                SELECT t.id FROM tasks t
                JOIN users u ON t.assigned_to = u.id
                WHERE t.id = ? AND u.manager_id = ?
            `, [taskId, req.user.userId]);
            if (taskCheck.length === 0) {
                return res.status(403).json({ success: false, message: 'Access denied or task not found' });
            }
        }
        const { title, description, status, notes, scheduled_time, location, client_name } = req.body;

        // Build dynamic update query
        const fields = [];
        const values = [];

        if (title !== undefined) { fields.push('title = ?'); values.push(title); }
        if (description !== undefined) { fields.push('description = ?'); values.push(description); }
        if (status !== undefined) {
            const validStatuses = ['pending', 'in_progress', 'completed', 'missed'];
            if (!validStatuses.includes(status)) {
                return res.status(400).json({ success: false, message: 'Invalid status' });
            }
            fields.push('status = ?');
            values.push(status);
        }
        if (notes !== undefined) { fields.push('notes = ?'); values.push(notes); }
        if (scheduled_time !== undefined) { fields.push('scheduled_time = ?'); values.push(scheduled_time); }
        if (location !== undefined) { fields.push('location = ?'); values.push(location); }
        if (client_name !== undefined) { fields.push('client_name = ?'); values.push(client_name); }

        if (fields.length === 0) {
            return res.status(400).json({ success: false, message: 'No fields to update' });
        }

        fields.push('updated_at = UTC_TIMESTAMP()');
        values.push(taskId);

        const [result] = await db.execute(
            `UPDATE tasks SET ${fields.join(', ')} WHERE id = ? AND is_deleted = FALSE`,
            values
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Task not found' });
        }

        // Fetch updated task to return
        const [updated] = await db.execute(
            `SELECT t.*, u.name AS executive_name, u.employee_id
             FROM tasks t LEFT JOIN users u ON t.assigned_to = u.id
             WHERE t.id = ?`,
            [taskId]
        );

        // Notify the executive about the update
        if (updated.length > 0 && updated[0].assigned_to) {
            try {
                await db.execute(
                    'INSERT INTO notifications (user_id, title, message, type, action_url) VALUES (?, ?, ?, ?, ?)',
                    [
                        updated[0].assigned_to,
                        'Task Updated by Admin',
                        `Your task "${updated[0].title}" has been updated by the admin.`,
                        'task_update',
                        `/tasks/${taskId}`
                    ]
                );
            } catch (notifErr) {
                console.error('Failed to create notification:', notifErr.message);
            }
        }

        return res.json({
            success: true,
            message: 'Task updated successfully',
            data: updated.length > 0 ? updated[0] : null
        });
    } catch (error) {
        console.error('Admin update task error:', error);
        return res.status(500).json({ success: false, message: 'Failed to update task' });
    }
});

module.exports = router;
