//const db = require('../config/database');
//const moment = require('moment');
//
//const getTasks = (req, res) => {
//    const userId = req.user.userId;
//    const fetchAll = req.query.all === 'true';
//
//    let query = `
//      SELECT t.*, u.name as assigned_to_name
//      FROM tasks t
//      LEFT JOIN users u ON t.assigned_to = u.id
//    `;
//    let params = [];
//
//    if (fetchAll) {
//      if (req.user.role === 'field_executive') {
//        return res.status(403).json({ error: 'Access denied' });
//      }
//      if (req.user.role === 'manager') {
//        query += ` WHERE u.manager_id = ? `;
//        params.push(req.user.userId);
//      }
//      query += ` ORDER BY t.scheduled_time ASC`;
//    } else {
//      query += ` WHERE t.assigned_to = ? ORDER BY t.scheduled_time ASC`;
//      params.push(userId);
//    }
//
//    db.execute(query, params, (err, results) => {
//        if (err) {
//            return res.status(500).json({ error: 'Database error' });
//        }
//        res.json(results);
//    });
//};
//
//const updateTaskStatus = (req, res) => {
//    const { taskId } = req.params;
//    const { status, notes } = req.body;
//
//    const query = 'UPDATE tasks SET status = ?, notes = ?, updated_at = NOW() WHERE id = ?';
//
//    db.execute(query, [status, notes, taskId], (err, result) => {
//        if (err) {
//            return res.status(500).json({ error: 'Database error' });
//        }
//        res.json({ message: 'Task updated successfully' });
//    });
//};
//
//const createTask = (req, res) => {
//    const { title, description, assignedTo, location, scheduledTime, type } = req.body;
//
//    const query = `
//    INSERT INTO tasks (title, description, assigned_to, location, scheduled_time, type, status, created_at)
//    VALUES (?, ?, ?, ?, ?, ?, 'pending', NOW())
//  `;
//
//    db.execute(query, [title, description, assignedTo, location, scheduledTime, type], (err, result) => {
//        if (err) {
//            return res.status(500).json({ error: 'Database error' });
//        }
//        res.json({ message: 'Task created successfully', taskId: result.insertId });
//    });
//};
//
//module.exports = { getTasks, updateTaskStatus, createTask };



const db = require('../config/database');

const getTasks = (req, res) => {
    const userId = req.user.userId;
    const fetchAll = req.query.all === 'true';

    let query = `
        SELECT t.*, u.name AS assigned_to_name
        FROM tasks t
        LEFT JOIN users u ON t.assigned_to = u.id
    `;

    let params = [];

    if (fetchAll) {
        if (req.user.role === 'field_executive') {
            return res.status(403).json({
                success: false,
                message: 'Access denied'
            });
        }

        if (req.user.role === 'manager') {
            query += ` WHERE u.manager_id = ?`;
            params.push(userId);
        }

        query += ` ORDER BY t.scheduled_time ASC`;
    } else {
        query += ` WHERE t.assigned_to = ? ORDER BY t.scheduled_time ASC`;
        params.push(userId);
    }

    db.execute(query, params, (err, results) => {
        if (err) {
            console.error("Get Tasks Error:", err);

            return res.status(500).json({
                success: false,
                message: err.message
            });
        }

        res.json(results);
    });
};

const updateTaskStatus = (req, res) => {
    const { taskId } = req.params;
    const { status, notes } = req.body;

    const query = `
        UPDATE tasks
        SET status = ?, notes = ?, updated_at = NOW()
        WHERE id = ?
    `;

    db.execute(query, [status, notes, taskId], (err) => {
        if (err) {
            console.error("Update Task Error:", err);

            return res.status(500).json({
                success: false,
                message: err.message
            });
        }

        res.json({
            success: true,
            message: "Task updated successfully"
        });
    });
};

const createTask = (req, res) => {

    console.log("========== CREATE TASK ==========");
    console.log("User:", req.user);
    console.log("Request Body:", req.body);

    const {
        title,
        description,
        assignedTo,
        location,
        scheduledTime,
        type
    } = req.body;

    // Validate required fields
    if (!title) {
        return res.status(400).json({
            success: false,
            message: "Title is required"
        });
    }

    if (!type) {
        return res.status(400).json({
            success: false,
            message: "Type is required"
        });
    }

    const validTypes = [
        "site_evaluation",
        "document_collection",
        "follow_up",
        "meeting"
    ];

    if (!validTypes.includes(type)) {
        return res.status(400).json({
            success: false,
            message: `Invalid task type. Allowed values: ${validTypes.join(", ")}`
        });
    }

    const query = `
        INSERT INTO tasks (
            title,
            description,
            assigned_to,
            location,
            scheduled_time,
            type,
            status,
            created_at
        )
        VALUES (?, ?, ?, ?, ?, ?, 'pending', NOW())
    `;

    const values = [
        title,
        description || null,
        assignedTo || null,
        location || null,
        scheduledTime || null,
        type
    ];

    console.log("SQL Values:", values);

    db.execute(query, values, (err, result) => {

        if (err) {
            console.error("========== MYSQL ERROR ==========");
            console.error(err);

            return res.status(500).json({
                success: false,
                message: err.message,
                code: err.code,
                sqlState: err.sqlState
            });
        }

        console.log("Task Created Successfully:", result.insertId);

        res.status(201).json({
            success: true,
            message: "Task created successfully",
            taskId: result.insertId
        });
    });
};

module.exports = {
    getTasks,
    updateTaskStatus,
    createTask
};