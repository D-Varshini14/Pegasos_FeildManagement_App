const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken, requireAdminOrManager } = require('../middleware/auth');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure uploads directory exists
const uploadDir = path.join(__dirname, '..', 'uploads', 'expenses');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'expense-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

// ==========================================
// 1. EXPENSES (Parent / Claims)
// ==========================================

// Get all expenses for the logged-in user (or all if admin/manager views specific user)
router.get('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.query.user_id; // optional
    const fetchAll = req.query.all === 'true'; // Used by admin/manager to see all

    let query = `
       SELECT e.*, u.name as user_name, u.employee_id
       FROM expenses e 
       JOIN users u ON e.user_id = u.id 
    `;
    let params = [];

    if (fetchAll) {
      if (req.user.role === 'field_executive') {
        return res.status(403).json({ success: false, message: 'Access denied' });
      }
      if (req.user.role === 'manager') {
        query += ` WHERE u.manager_id = ? `;
        params.push(req.user.userId);
      }
      query += ` ORDER BY e.created_at DESC`;
    } else {
      const targetUserId = userId || req.user.userId;
      if (targetUserId != req.user.userId && req.user.role === 'field_executive') {
        return res.status(403).json({ success: false, message: 'Access denied' });
      }
      query += ` WHERE e.user_id = ? ORDER BY e.created_at DESC`;
      params.push(targetUserId);
    }

    const [expenses] = await db.query(query, params);
    res.json({ success: true, data: expenses });
  } catch (error) {
    console.error('Error fetching expenses:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Get a specific expense with its forms
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const expenseId = req.params.id;
    
    const [expenses] = await db.query('SELECT * FROM expenses WHERE id = ?', [expenseId]);
    if (expenses.length === 0) return res.status(404).json({ success: false, message: 'Expense not found' });
    
    const expense = expenses[0];

    // Check permissions
    if (expense.user_id !== req.user.userId && req.user.role === 'field_executive') {
      return res.status(403).json({ success: false, message: 'Access denied' });
    }

    // Fetch forms
    const [forms] = await db.query('SELECT * FROM expense_forms WHERE expense_id = ?', [expenseId]);
    
    // Fetch attachments for forms
    for (let form of forms) {
      const [attachments] = await db.query('SELECT * FROM expense_attachments WHERE expense_form_id = ?', [form.id]);
      form.attachments = attachments;
    }

    expense.forms = forms;
    res.json({ success: true, data: expense });
  } catch (error) {
    console.error('Error fetching expense details:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Create a new expense claim
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { title } = req.body;
    
    const [result] = await db.query(
      `INSERT INTO expenses (user_id, title, total_amount_request, amount_in_progress, amount_claimed, amount_pending, status) 
       VALUES (?, ?, 0, 0, 0, 0, 'Pending')`,
      [req.user.userId, title || 'Expense Claim']
    );

    res.status(201).json({ success: true, message: 'Expense created successfully', id: result.insertId });
  } catch (error) {
    console.error('Error creating expense:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Approve/Reject an expense
router.put('/:id/status', authenticateToken, requireAdminOrManager, async (req, res) => {
  try {
    const { status, amount_claimed } = req.body; // status: 'Approved' or 'Rejected'
    const expenseId = req.params.id;

    if (!['Approved', 'Rejected'].includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    // Update expense
    await db.query(
      `UPDATE expenses SET status = ?, amount_claimed = ?, amount_pending = total_amount_request - ? WHERE id = ?`,
      [status, amount_claimed || 0, amount_claimed || 0, expenseId]
    );

    // Also update all forms within this expense to the same status
    await db.query('UPDATE expense_forms SET status = ? WHERE expense_id = ?', [status, expenseId]);

    res.json({ success: true, message: `Expense marked as ${status}` });
  } catch (error) {
    console.error('Error updating expense status:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});


// Delete an expense claim
router.delete('/:id', authenticateToken, async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const expenseId = req.params.id;

    // Check expense
    const [expenses] = await connection.query('SELECT * FROM expenses WHERE id = ?', [expenseId]);
    if (expenses.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Expense not found' });
    }

    const expense = expenses[0];

    // Check permissions
    if (expense.user_id !== req.user.userId && req.user.role === 'field_executive') {
      await connection.rollback();
      return res.status(403).json({ success: false, message: 'Access denied' });
    }

    // Delete the expense (forms and attachments should be cascaded, or we delete them)
    // Assuming cascading is set up, or at least delete the main expense
    await connection.query('DELETE FROM expense_forms WHERE expense_id = ?', [expenseId]);
    await connection.query('DELETE FROM expenses WHERE id = ?', [expenseId]);

    await connection.commit();
    res.json({ success: true, message: 'Expense deleted successfully' });
  } catch (error) {
    await connection.rollback();
    console.error('Error deleting expense:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  } finally {
    connection.release();
  }
});

// ==========================================
// 2. EXPENSE FORMS (Child items / Receipts)
// ==========================================

// Create an expense form item inside an expense claim
router.post('/forms', authenticateToken, upload.array('attachments', 5), async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { expense_id, category, amount, description } = req.body;

    if (!expense_id || !category || !amount) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    // Verify expense belongs to user
    const [expenses] = await connection.query('SELECT * FROM expenses WHERE id = ? AND user_id = ?', [expense_id, req.user.userId]);
    if (expenses.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Expense not found or unauthorized' });
    }

    // Insert form
    const [formResult] = await connection.query(
      'INSERT INTO expense_forms (expense_id, category, amount, description) VALUES (?, ?, ?, ?)',
      [expense_id, category, amount, description || '']
    );

    const formId = formResult.insertId;

    // Handle attachments
    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        const filePath = `/uploads/expenses/${file.filename}`;
        await connection.query(
          'INSERT INTO expense_attachments (expense_form_id, file_name, file_path) VALUES (?, ?, ?)',
          [formId, file.originalname, filePath]
        );
      }
    }

    // Update parent expense totals
    await connection.query(
      'UPDATE expenses SET amount_in_progress = amount_in_progress + ?, total_amount_request = total_amount_request + ? WHERE id = ?',
      [amount, amount, expense_id]
    );

    await connection.commit();
    res.status(201).json({ success: true, message: 'Expense item added successfully' });
  } catch (error) {
    await connection.rollback();
    console.error('Error adding expense form:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  } finally {
    connection.release();
  }
});

// Delete an expense form
router.delete('/forms/:id', authenticateToken, async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();
    const formId = req.params.id;

    // Fetch form
    const [forms] = await connection.query(
      'SELECT f.*, e.user_id FROM expense_forms f JOIN expenses e ON f.expense_id = e.id WHERE f.id = ?', 
      [formId]
    );

    if (forms.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Form not found' });
    }

    const form = forms[0];

    // Check auth
    if (form.user_id !== req.user.userId) {
      await connection.rollback();
      return res.status(403).json({ success: false, message: 'Access denied' });
    }

    // Deduct amount from parent
    await connection.query(
      'UPDATE expenses SET amount_in_progress = amount_in_progress - ?, total_amount_request = total_amount_request - ? WHERE id = ?',
      [form.amount, form.amount, form.expense_id]
    );

    // Delete form (attachments are cascaded in DB)
    await connection.query('DELETE FROM expense_forms WHERE id = ?', [formId]);

    await connection.commit();
    res.json({ success: true, message: 'Expense item deleted' });
  } catch (error) {
    await connection.rollback();
    console.error('Error deleting form:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  } finally {
    connection.release();
  }
});

module.exports = router;
