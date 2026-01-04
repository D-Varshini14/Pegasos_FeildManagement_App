const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const mysql = require('mysql2');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const rateLimit = require('express-rate-limit');
const winston = require('winston');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const IS_PRODUCTION = process.env.NODE_ENV === 'production';
const SERVER_URL = process.env.SERVER_URL || `http://localhost:${PORT}`;

// ==================== LOGGING SETUP ====================

const logger = winston.createLogger({
    level: IS_PRODUCTION ? 'info' : 'debug',
    format: winston.format.combine(
        winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
        winston.format.errors({ stack: true }),
        winston.format.splat(),
        winston.format.json()
    ),
    defaultMeta: { service: 'field-management-api' },
    transports: [
        new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
        new winston.transports.File({ filename: 'logs/combined.log' }),
    ],
});

// Console output in development
if (!IS_PRODUCTION) {
    logger.add(new winston.transports.Console({
        format: winston.format.combine(
            winston.format.colorize(),
            winston.format.simple()
        )
    }));
}

// Create logs directory if it doesn't exist
const logsDir = path.join(__dirname, 'logs');
if (!fs.existsSync(logsDir)) {
    fs.mkdirSync(logsDir, { recursive: true });
}

// ==================== FILE UPLOAD SETUP ====================

const uploadsDir = path.join(__dirname, 'uploads', 'profiles');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadsDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, 'profile-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const filetypes = /jpeg|jpg|png/;
        const mimetype = filetypes.test(file.mimetype);
        const extname = filetypes.test(path.extname(file.originalname).toLowerCase());

        if (mimetype && extname) {
            return cb(null, true);
        }
        cb(new Error('Only image files are allowed!'));
    }
});

// ==================== DATABASE SETUP ====================

const db = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    timezone: '+00:00' // Store dates in UTC
}).promise();

// Test database connection
(async () => {
    try {
        await db.query('SELECT 1');
        logger.info('✅ Connected to MySQL database');
    } catch (err) {
        logger.error('❌ Database connection failed', { error: err.message, code: err.code });
        process.exit(1);
    }
})();

// ==================== MIDDLEWARE ====================

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Request logging middleware
app.use((req, res, next) => {
    logger.info(`${req.method} ${req.path}`, {
        ip: req.ip,
        userAgent: req.get('user-agent')
    });
    next();
});

// ==================== RATE LIMITING ====================

// Strict rate limiting for auth endpoints (only in production)
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: IS_PRODUCTION ? 5 : 1000, // Relaxed in development
    message: {
        success: false,
        message: 'Too many attempts, please try again after 15 minutes'
    },
    skip: (req) => !IS_PRODUCTION, // Skip in development if needed
    standardHeaders: true,
    legacyHeaders: false,
});

// General API rate limiting
const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: IS_PRODUCTION ? 100 : 1000,
    message: {
        success: false,
        message: 'Too many requests, please try again later'
    },
    standardHeaders: true,
    legacyHeaders: false,
});

app.use('/api/auth/login', authLimiter);
app.use('/api/auth/signup', authLimiter);
app.use('/api/', apiLimiter);

// ==================== HELPER FUNCTIONS ====================

// Delete old profile image
async function deleteOldProfileImage(imagePath) {
    if (!imagePath) return;

    const fullPath = path.join(__dirname, imagePath);
    try {
        if (fs.existsSync(fullPath)) {
            fs.unlinkSync(fullPath);
            logger.info('Deleted old profile image', { path: imagePath });
        }
    } catch (err) {
        logger.warn('Failed to delete old image', { path: imagePath, error: err.message });
    }
}

// Convert image path to full URL
function getImageUrl(imagePath) {
    if (!imagePath) return null;
    return `${SERVER_URL}${imagePath}`;
}

// ==================== AUTHENTICATION ENDPOINTS ====================

// Signup endpoint
app.post('/api/auth/signup', upload.single('profileImage'), async (req, res) => {
    try {
        const { name, email, phone, zone, role, password } = req.body;

        logger.info('Signup request received', { email });

        // Validate required fields
        if (!name || !email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Name, email, and password are required'
            });
        }

        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid email format'
            });
        }

        // Validate password strength
        if (password.length < 8) {
            return res.status(400).json({
                success: false,
                message: 'Password must be at least 8 characters long'
            });
        }

        // Check JWT secret
        if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
            logger.error('JWT_SECRET is not configured or too short');
            return res.status(500).json({
                success: false,
                message: 'Server configuration error'
            });
        }

        // Check if email already exists
        const [existing] = await db.execute(
            'SELECT id FROM profile WHERE email = ?',
            [email.trim().toLowerCase()]
        );

        if (existing.length > 0) {
            logger.warn('Signup failed: Email already exists', { email });
            return res.status(400).json({
                success: false,
                message: 'Email already exists'
            });
        }

        // Generate Employee ID
        const [lastUser] = await db.execute(
            'SELECT employee_id FROM users ORDER BY id DESC LIMIT 1'
        );

        let nextNumber = 1;
        if (lastUser.length > 0 && lastUser[0].employee_id) {
            const lastId = lastUser[0].employee_id;
            const match = lastId.match(/^EMP(\d+)$/);
            if (match) {
                nextNumber = parseInt(match[1]) + 1;
            }
        }

        const employeeId = 'EMP' + String(nextNumber).padStart(3, '0');

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Get profile image path
        const profileImagePath = req.file ? `/uploads/profiles/${req.file.filename}` : null;

        // Insert into users table
        const [userResult] = await db.execute(
            'INSERT INTO users (employee_id, name, password, created_at) VALUES (?, ?, ?, UTC_TIMESTAMP())',
            [employeeId, name.trim(), hashedPassword]
        );

        const userId = userResult.insertId;
        logger.info('User created', { userId, employeeId });

        // Insert into profile table
        try {
            await db.execute(
                `INSERT INTO profile (user_id, email, phone, zone, role, profile_image, created_at) 
                 VALUES (?, ?, ?, ?, ?, ?, UTC_TIMESTAMP())`,
                [
                    userId,
                    email.trim().toLowerCase(),
                    phone || null,
                    zone || null,
                    role || 'field_executive',
                    profileImagePath
                ]
            );

            logger.info('Profile created successfully', { userId, employeeId });

            return res.status(201).json({
                success: true,
                message: 'Account created successfully',
                data: {
                    id: userId,
                    name: name.trim(),
                    employeeId: employeeId,
                    email: email.trim().toLowerCase(),
                    phone: phone || null,
                    role: role || 'field_executive',
                    zone: zone || null,
                    profileImage: getImageUrl(profileImagePath)
                }
            });

        } catch (profileErr) {
            logger.error('Profile creation failed, rolling back', { userId, error: profileErr.message });

            // Rollback: Delete user
            await db.execute('DELETE FROM users WHERE id = ?', [userId]);

            // Delete uploaded image if exists
            if (req.file) {
                deleteOldProfileImage(profileImagePath);
            }

            return res.status(500).json({
                success: false,
                message: 'Failed to create account'
            });
        }

    } catch (error) {
        logger.error('Signup error', { error: error.message, stack: error.stack });

        // Delete uploaded image on error
        if (req.file) {
            deleteOldProfileImage(`/uploads/profiles/${req.file.filename}`);
        }

        return res.status(500).json({
            success: false,
            message: IS_PRODUCTION ? 'Internal server error' : error.message
        });
    }
});

// Login endpoint
app.post('/api/auth/login', async (req, res) => {
    try {
        const { employeeId, password } = req.body;

        logger.info('Login attempt', { employeeId });

        if (!employeeId || !password) {
            return res.status(400).json({
                success: false,
                message: 'Employee ID and password are required'
            });
        }

        // Check user credentials
        const [users] = await db.execute(
            'SELECT * FROM users WHERE employee_id = ?',
            [employeeId.trim()]
        );

        if (users.length === 0) {
            logger.warn('Login failed: Invalid employee ID', { employeeId });
            return res.status(401).json({
                success: false,
                message: 'Invalid employee ID or password'
            });
        }

        const user = users[0];

        // Verify password
        const isValidPassword = await bcrypt.compare(password, user.password);

        if (!isValidPassword) {
            logger.warn('Login failed: Invalid password', { employeeId });
            return res.status(401).json({
                success: false,
                message: 'Invalid employee ID or password'
            });
        }

        // Fetch profile data
        const [profiles] = await db.execute(
            'SELECT * FROM profile WHERE user_id = ?',
            [user.id]
        );

        let profileData = {};

        if (profiles.length > 0) {
            const profile = profiles[0];
            profileData = {
                email: profile.email,
                phone: profile.phone,
                role: profile.role,
                zone: profile.zone,
                profileImage: getImageUrl(profile.profile_image)
            };
        }

        // Generate JWT token
        const token = jwt.sign(
            {
                userId: user.id,
                employeeId: user.employee_id,
                name: user.name
            },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        logger.info('Login successful', { userId: user.id, employeeId });

        return res.json({
            success: true,
            message: 'Login successful',
            data: {
                token,
                user: {
                    id: user.id,
                    name: user.name,
                    employeeId: user.employee_id,
                    ...profileData
                }
            }
        });

    } catch (error) {
        logger.error('Login error', { error: error.message });
        return res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// ==================== USER ENDPOINTS ====================

// Get user profile
app.get('/api/user/profile', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;

        const [results] = await db.execute(
            `SELECT u.id, u.employee_id, u.name, p.email, p.phone, p.role, p.zone, p.profile_image 
             FROM users u
             LEFT JOIN profile p ON u.id = p.user_id
             WHERE u.id = ?`,
            [userId]
        );

        if (results.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const user = results[0];

        return res.json({
            success: true,
            data: {
                id: user.id,
                name: user.name,
                employeeId: user.employee_id,
                email: user.email,
                phone: user.phone,
                role: user.role,
                zone: user.zone,
                profileImage: getImageUrl(user.profile_image)
            }
        });

    } catch (error) {
        logger.error('Error fetching profile', { userId: req.user.userId, error: error.message });
        return res.status(500).json({
            success: false,
            message: 'Failed to fetch profile'
        });
    }
});

// Update user profile
app.put('/api/user/profile', authenticateToken, upload.single('profileImage'), async (req, res) => {
    try {
        const userId = req.user.userId;
        const { name, email, phone, zone } = req.body;

        // Get current profile image before updating
        let oldImagePath = null;
        if (req.file) {
            const [currentProfile] = await db.execute(
                'SELECT profile_image FROM profile WHERE user_id = ?',
                [userId]
            );
            if (currentProfile.length > 0) {
                oldImagePath = currentProfile[0].profile_image;
            }
        }

        // Update user name if provided
        if (name) {
            await db.execute(
                'UPDATE users SET name = ? WHERE id = ?',
                [name.trim(), userId]
            );
        }

        // Prepare profile updates
        const updateFields = [];
        const updateValues = [];

        if (email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                return res.status(400).json({
                    success: false,
                    message: 'Invalid email format'
                });
            }

            const [existingEmail] = await db.execute(
                'SELECT user_id FROM profile WHERE email = ? AND user_id != ?',
                [email.trim().toLowerCase(), userId]
            );

            if (existingEmail.length > 0) {
                return res.status(400).json({
                    success: false,
                    message: 'Email already in use'
                });
            }

            updateFields.push('email = ?');
            updateValues.push(email.trim().toLowerCase());
        }
        if (phone) {
            updateFields.push('phone = ?');
            updateValues.push(phone);
        }
        if (zone) {
            updateFields.push('zone = ?');
            updateValues.push(zone);
        }
        if (req.file) {
            updateFields.push('profile_image = ?');
            updateValues.push(`/uploads/profiles/${req.file.filename}`);
        }

        // Update profile if there are fields to update
        if (updateFields.length > 0) {
            updateValues.push(userId);
            const updateQuery = `UPDATE profile SET ${updateFields.join(', ')} WHERE user_id = ?`;

            await db.execute(updateQuery, updateValues);

            // Delete old image if new one was uploaded
            if (req.file && oldImagePath) {
                await deleteOldProfileImage(oldImagePath);
            }
        }

        logger.info('Profile updated', { userId });

        return res.json({
            success: true,
            message: 'Profile updated successfully'
        });

    } catch (error) {
        logger.error('Profile update error', { userId: req.user.userId, error: error.message });

        if (req.file) {
            deleteOldProfileImage(`/uploads/profiles/${req.file.filename}`);
        }

        return res.status(500).json({
            success: false,
            message: 'Failed to update profile'
        });
    }
});

// ==================== TASKS ENDPOINTS ====================

// Get tasks with pagination
app.get('/api/tasks', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const offset = (page - 1) * limit;

        // Get total count
        const [countResult] = await db.execute(
            'SELECT COUNT(*) as total FROM tasks WHERE assigned_to = ?',
            [userId]
        );
        const total = countResult[0].total;

        // Get paginated results
        const [results] = await db.execute(
            'SELECT * FROM tasks WHERE assigned_to = ? ORDER BY scheduled_time ASC LIMIT ? OFFSET ?',
            [userId, limit, offset]
        );

        return res.json({
            success: true,
            data: results,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit)
            }
        });

    } catch (error) {
        logger.error('Error fetching tasks', { userId: req.user.userId, error: error.message });
        return res.status(500).json({
            success: false,
            message: 'Failed to fetch tasks'
        });
    }
});

// Update task status
app.put('/api/tasks/:taskId/status', authenticateToken, async (req, res) => {
    try {
        const { taskId } = req.params;
        const { status, notes } = req.body;
        const userId = req.user.userId;

        const validStatuses = ['pending', 'in_progress', 'completed', 'cancelled'];
        if (!validStatuses.includes(status)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid status value'
            });
        }

        const [result] = await db.execute(
            'UPDATE tasks SET status = ?, notes = ?, updated_at = UTC_TIMESTAMP() WHERE id = ? AND assigned_to = ?',
            [status, notes || null, taskId, userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Task not found or you do not have permission to update it'
            });
        }

        logger.info('Task updated', { taskId, userId, status });

        return res.json({
            success: true,
            message: 'Task updated successfully'
        });

    } catch (error) {
        logger.error('Task update error', { taskId: req.params.taskId, error: error.message });
        return res.status(500).json({
            success: false,
            message: 'Failed to update task'
        });
    }
});

// ==================== LEAVES ENDPOINTS ====================

// Apply leave
app.post('/api/leaves', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { leave_type, from_date, to_date, notes } = req.body;

        if (!leave_type || !from_date || !to_date) {
            return res.status(400).json({
                success: false,
                message: 'Leave type, from date, and to date are required'
            });
        }

        // Validate dates
        const fromDate = new Date(from_date);
        const toDate = new Date(to_date);

        if (isNaN(fromDate.getTime()) || isNaN(toDate.getTime())) {
            return res.status(400).json({
                success: false,
                message: 'Invalid date format'
            });
        }

        if (toDate < fromDate) {
            return res.status(400).json({
                success: false,
                message: 'End date must be after start date'
            });
        }

        const [result] = await db.execute(
            `INSERT INTO leaves (user_id, leave_type, from_date, to_date, notes, status, created_at) 
             VALUES (?, ?, ?, ?, ?, 'pending', UTC_TIMESTAMP())`,
            [userId, leave_type, from_date, to_date, notes || null]
        );

        logger.info('Leave applied', { userId, leaveId: result.insertId });

        return res.status(201).json({
            success: true,
            message: 'Leave application submitted successfully',
            data: {
                id: result.insertId
            }
        });

    } catch (error) {
        logger.error('Leave application error', { userId: req.user.userId, error: error.message });
        return res.status(500).json({
            success: false,
            message: 'Failed to apply leave'
        });
    }
});

// Get leaves with pagination
app.get('/api/leaves', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const offset = (page - 1) * limit;

        // Get total count
        const [countResult] = await db.execute(
            'SELECT COUNT(*) as total FROM leaves WHERE user_id = ?',
            [userId]
        );
        const total = countResult[0].total;

        // Get paginated results
        const [results] = await db.execute(
            'SELECT * FROM leaves WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?',
            [userId, limit, offset]
        );

        return res.json({
            success: true,
            data: results,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit)
            }
        });

    } catch (error) {
        logger.error('Error fetching leaves', { userId: req.user.userId, error: error.message });
        return res.status(500).json({
            success: false,
            message: 'Failed to fetch leaves'
        });
    }
});

// ==================== MIDDLEWARE ====================

function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({
            success: false,
            message: 'Access token required'
        });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            logger.warn('Invalid token attempt', { error: err.message });
            return res.status(403).json({
                success: false,
                message: 'Invalid or expired token'
            });
        }
        req.user = user;
        next();
    });
}

// ==================== HEALTH CHECK & DEBUG ====================

app.get('/', (req, res) => {
    return res.json({
        message: 'Field Management API - Enterprise Ready 🚀',
        timestamp: new Date().toISOString(),
        version: '3.0.0',
        environment: IS_PRODUCTION ? 'production' : 'development',
        features: {
            logging: 'winston',
            rateLimiting: 'enabled',
            pagination: 'enabled',
            timezone: 'UTC'
        }
    });
});

app.get('/api/debug/db-test', async (req, res) => {
    try {
        const [results] = await db.execute('SELECT 1 + 1 AS result');
        return res.json({
            success: true,
            message: 'Database connection working',
            result: results[0].result
        });
    } catch (error) {
        logger.error('Database test failed', { error: error.message });
        return res.status(500).json({
            success: false,
            message: 'Database connection failed'
        });
    }
});

app.get('/api/debug/check-tables', async (req, res) => {
    try {
        const [results] = await db.execute('SHOW TABLES');
        const tables = results.map(row => Object.values(row)[0]);
        return res.json({
            success: true,
            tables: tables,
            count: tables.length
        });
    } catch (error) {
        logger.error('Error checking tables', { error: error.message });
        return res.status(500).json({
            success: false,
            message: 'Failed to check tables'
        });
    }
});

// Error handling middleware
app.use((err, req, res, next) => {
    logger.error('Unhandled error', { error: err.message, stack: err.stack });

    if (res.headersSent) {
        return next(err);
    }

    return res.status(500).json({
        success: false,
        message: IS_PRODUCTION ? 'Internal server error' : err.message
    });
});

// Graceful shutdown
process.on('SIGINT', () => {
    logger.info('Shutting down gracefully...');
    process.exit(0);
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    logger.info('Server started', {
        port: PORT,
        environment: IS_PRODUCTION ? 'PRODUCTION' : 'DEVELOPMENT',
        version: '3.0.0'
    });

    console.log('='.repeat(60));
    console.log('🚀 FIELD MANAGEMENT API - ENTERPRISE READY');
    console.log('='.repeat(60));
    console.log(`📍 Port: ${PORT}`);
    console.log(`🔒 Environment: ${IS_PRODUCTION ? 'PRODUCTION' : 'DEVELOPMENT'}`);
    console.log(`🛡️  Rate Limiting: ${IS_PRODUCTION ? 'STRICT' : 'RELAXED'}`);
    console.log(`📝 Logging: Winston (logs/combined.log)`);
    console.log(`🌍 Timezone: UTC`);
    console.log(`📄 Pagination: Enabled (default 20 items)`);
    console.log(`🔑 Password Min: 8 characters`);
    console.log('='.repeat(60));
});