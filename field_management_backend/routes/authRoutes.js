const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const signupController = require('../controllers/signupController');
const { authenticateToken } = require('../middleware/auth');

// Login route
router.post('/login', authController.login);

// Signup route
router.post('/signup', signupController.signup);

// Logout route
router.post('/logout', authenticateToken, authController.logout);

// Validate token route
router.get('/validate', authenticateToken, authController.validateToken);

module.exports = router;