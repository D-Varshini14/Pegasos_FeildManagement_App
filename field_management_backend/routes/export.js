const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { Parser } = require('json2csv');

// Helper to check permissions
const isAuthorized = (req) => {
  return req.user.role === 'admin' || req.user.role === 'manager';
};

// GET /api/export/:entity
router.get('/:entity', authenticateToken, async (req, res) => {
  if (!isAuthorized(req)) {
    return res.status(403).json({ success: false, message: 'Access denied. Managers and Admins only.' });
  }

  const { entity } = req.params;
  let query = '';
  let params = [];
  let prefix = '';

  try {
    switch (entity) {
      case 'visits':
        query = `
          SELECT t.*, u.name as executive_name, u.employee_id 
          FROM tasks t
          JOIN users u ON t.assigned_to = u.id
          WHERE t.type IN ('site_evaluation', 'meeting')
        `;
        if (req.user.role === 'manager') {
          query += ` AND u.manager_id = ?`;
          params.push(req.user.userId);
        }
        query += ` ORDER BY t.created_at DESC`;
        prefix = 'visits';
        break;

      case 'tasks':
        query = `
          SELECT t.*, u.name as executive_name, u.employee_id 
          FROM tasks t
          JOIN users u ON t.assigned_to = u.id
        `;
        if (req.user.role === 'manager') {
          query += ` WHERE u.manager_id = ?`;
          params.push(req.user.userId);
        }
        query += ` ORDER BY t.created_at DESC`;
        prefix = 'tasks';
        break;

      case 'leads':
        query = `
          SELECT l.*, u.name as executive_name, u.employee_id 
          FROM leads l
          JOIN users u ON l.assigned_to = u.id
        `;
        if (req.user.role === 'manager') {
          query += ` WHERE u.manager_id = ?`;
          params.push(req.user.userId);
        }
        query += ` ORDER BY l.created_at DESC`;
        prefix = 'leads';
        break;

      case 'expenses':
        query = `
          SELECT e.id as expense_id, e.status as expense_status, e.total_amount_request, e.amount_in_progress, e.amount_claimed, e.created_at as expense_date,
                 f.id as form_id, f.category, f.amount as item_amount, f.description,
                 u.name as executive_name, u.employee_id
          FROM expenses e
          JOIN users u ON e.user_id = u.id
          LEFT JOIN expense_forms f ON e.id = f.expense_id
        `;
        if (req.user.role === 'manager') {
          query += ` WHERE u.manager_id = ?`;
          params.push(req.user.userId);
        }
        query += ` ORDER BY e.created_at DESC`;
        prefix = 'expenses';
        break;

      default:
        return res.status(400).json({ success: false, message: 'Invalid entity to export' });
    }

    const [rows] = await db.query(query, params);

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'No data found to export' });
    }

    // Convert JSON to CSV
    const json2csvParser = new Parser();
    const csv = json2csvParser.parse(rows);

    res.header('Content-Type', 'text/csv');
    res.attachment(`${prefix}_export_${new Date().toISOString().slice(0, 10)}.csv`);
    return res.send(csv);

  } catch (error) {
    console.error('Export error:', error);
    res.status(500).json({ success: false, message: 'Failed to generate export file' });
  }
});

module.exports = router;
