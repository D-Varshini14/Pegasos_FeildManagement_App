// ============================================================
// MIDDLEWARE: Authentication & Role-Based Access Control
// Req #2: Admin Panel vs Executive Panel separation
// ============================================================

const jwt = require('jsonwebtoken');

// ---- Authenticate any logged-in user ----
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({
            success: false,
            message: 'Access token required. Please login.'
        });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({
                success: false,
                message: 'Invalid or expired token. Please login again.'
            });
        }
        req.user = user;
        next();
    });
};

// ---- Admin only routes ----
const requireAdmin = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    if (req.user.role !== 'admin') {
        return res.status(403).json({
            success: false,
            message: 'Access denied. Admin privileges required.'
        });
    }
    next();
};

// ---- Field Executive only routes ----
const requireExecutive = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    if (req.user.role !== 'field_executive') {
        return res.status(403).json({
            success: false,
            message: 'Access denied. Field executive access only.'
        });
    }
    next();
};

// ---- Manager only routes ----
const requireManager = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    if (req.user.role !== 'manager') {
        return res.status(403).json({
            success: false,
            message: 'Access denied. Manager privileges required.'
        });
    }
    next();
};

// ---- Admin OR Manager ----
const requireAdminOrManager = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    if (!['admin', 'manager'].includes(req.user.role)) {
        return res.status(403).json({ success: false, message: 'Access denied. Admin or Manager privileges required.' });
    }
    next();
};

// ---- Admin OR Executive (any authenticated user) ----
const requireAdminOrExecutive = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    if (!['admin', 'field_executive'].includes(req.user.role)) {
        return res.status(403).json({ success: false, message: 'Access denied.' });
    }
    next();
};

module.exports = { authenticateToken, requireAdmin, requireExecutive, requireAdminOrExecutive, requireManager, requireAdminOrManager };
