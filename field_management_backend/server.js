
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const cron = require('node-cron');
const crypto = require('crypto');
const rateLimit = require('express-rate-limit');
const winston = require('winston');
require('dotenv').config();

const db = require('./config/database');
const { authenticateToken, requireAdmin, requireAdminOrExecutive, requireAdminOrManager } = require('./middleware/auth');
const { sendPasswordResetEmail, sendVisitUpdateEmail, sendNotificationEmail, sendEmployeeIdEmail } = require('./utils/email');

const app = express();
const PORT = process.env.PORT || 3000;
const IS_PRODUCTION = process.env.NODE_ENV === 'production';
const SERVER_URL = process.env.SERVER_URL || `http://localhost:${PORT}`;

// ==================== LOGGING ====================

const logger = winston.createLogger({
    level: IS_PRODUCTION ? 'info' : 'debug',
    format: winston.format.combine(
        winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
        winston.format.errors({ stack: true }),
        winston.format.json()
    ),
    defaultMeta: { service: 'pegasos-api' },
    transports: [
        new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
        new winston.transports.File({ filename: 'logs/combined.log' }),
    ],
});

if (!IS_PRODUCTION) {
    logger.add(new winston.transports.Console({
        format: winston.format.combine(winston.format.colorize(), winston.format.simple())
    }));
}

['logs', 'uploads/profiles'].forEach(dir => {
    const dirPath = path.join(__dirname, dir);
    if (!fs.existsSync(dirPath)) fs.mkdirSync(dirPath, { recursive: true });
});

// ==================== FILE UPLOAD ====================

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, path.join(__dirname, 'uploads/profiles')),
    filename: (req, file, cb) => {
        const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, 'profile-' + unique + path.extname(file.originalname));
    }
});

const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const ok = /jpeg|jpg|png/.test(file.mimetype) && /jpeg|jpg|png/.test(path.extname(file.originalname).toLowerCase());
        ok ? cb(null, true) : cb(new Error('Only image files allowed'));
    }
});

const storageDocument = multer.diskStorage({
    destination: (req, file, cb) => {
        const dir = path.join(__dirname, 'uploads/documents');
        if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
        cb(null, dir);
    },
    filename: (req, file, cb) => {
        const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, 'doc-' + unique + path.extname(file.originalname));
    }
});

const uploadDocument = multer({
    storage: storageDocument,
    limits: { fileSize: 20 * 1024 * 1024 }, // 20 MB limit
    fileFilter: (req, file, cb) => {
        const allowedTypes = /pdf|doc|docx|xls|xlsx|png|jpg|jpeg/;
        const ok = allowedTypes.test(file.mimetype) || allowedTypes.test(path.extname(file.originalname).toLowerCase());
        ok ? cb(null, true) : cb(new Error('Invalid file type'));
    }
});

// ==================== MIDDLEWARE ====================

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));
app.use((req, res, next) => {
    logger.info(`${req.method} ${req.path}`, { ip: req.ip });
    next();
});

// Rate limiting
const authLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: IS_PRODUCTION ? 10 : 1000 });
const apiLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: IS_PRODUCTION ? 100 : 1000 });
app.use('/api/auth/', authLimiter);
app.use('/api/', apiLimiter);

// Routes
app.use('/api/admin/dashboard', require('./routes/admin_dashboard'));
app.use('/api/expenses', require('./routes/expenses'));
app.use('/api/export', require('./routes/export'));

// ==================== HELPERS ====================

function getImageUrl(imagePath) {
    if (!imagePath) return null;
    return `${SERVER_URL}${imagePath}`;
}

async function deleteOldProfileImage(imagePath) {
    if (!imagePath) return;
    try {
        const fullPath = path.join(__dirname, imagePath);
        if (fs.existsSync(fullPath)) fs.unlinkSync(fullPath);
    } catch (err) {
        logger.warn('Failed to delete old image', { path: imagePath });
    }
}

// Create a notification record in DB
async function createNotification(userId, title, message, type, actionUrl = null) {
    try {
        await db.execute(
            'INSERT INTO notifications (user_id, title, message, type, action_url) VALUES (?, ?, ?, ?, ?)',
            [userId, title, message, type, actionUrl]
        );
    } catch (err) {
        logger.error('Failed to create notification', { err: err.message });
    }
}

// ============================================================
// AUTH ROUTES
// ============================================================

// ---- SIGNUP ----

// ---- PUBLIC MANAGERS LIST ----
app.get('/api/auth/managers', async (req, res) => {
    try {
        const [managers] = await db.execute(
            'SELECT id, name, employee_id, zone FROM users WHERE role = \'manager\' AND is_deleted = FALSE'
        );
        res.json({ success: true, data: managers });
    } catch (error) {
        logger.error('Error fetching public managers list', { error: error.message });
        res.status(500).json({ success: false, message: 'Internal server error' });
    }
});


app.post('/api/auth/signup', upload.single('profileImage'), async (req, res) => {
    try {
        const { name, email, phone, zone, city, state, role, password, manager_id } = req.body;

        if (!name || !email || !password || !phone) {
            return res.status(400).json({ success: false, message: 'Name, email, phone and password are required' });
        }

        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            return res.status(400).json({ success: false, message: 'Invalid email format' });
        }

        if (password.length < 8) {
            return res.status(400).json({ success: false, message: 'Password must be at least 8 characters' });
        }

        const [existing] = await db.execute('SELECT id FROM profile WHERE email = ?', [email.trim().toLowerCase()]);
        if (existing.length > 0) {
            return res.status(400).json({ success: false, message: 'Email already exists' });
        }

        // Generate employee ID
        const [lastUser] = await db.execute('SELECT employee_id FROM users ORDER BY id DESC LIMIT 1');
        let nextNum = 1;
        if (lastUser.length > 0 && lastUser[0].employee_id) {
            const match = lastUser[0].employee_id.match(/^EMP(\d+)$/);
            if (match) nextNum = parseInt(match[1]) + 1;
        }
        const employeeId = 'EMP' + String(nextNum).padStart(3, '0');

        const hashedPassword = await bcrypt.hash(password, 10);
        const userRole = role || 'field_executive';

        // Block Admin signup on the backend entirely
        if (userRole === 'admin' || userRole.toLowerCase() === 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Administrator signup is strictly blocked on the backend.'
            });
        }

        const profileImagePath = req.file ? `/uploads/profiles/${req.file.filename}` : null;

        const [userResult] = await db.execute(
            'INSERT INTO users (employee_id, name, password, role, manager_id, created_at) VALUES (?, ?, ?, ?, ?, UTC_TIMESTAMP())',
            [employeeId, name.trim(), hashedPassword, userRole, manager_id || null]
        );

        const userId = userResult.insertId;

        await db.execute(
            'INSERT INTO profile (user_id, email, phone, zone, city, state, role, profile_image, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, UTC_TIMESTAMP())',
            [userId, email.trim().toLowerCase(), phone || null, zone || null, city || null, state || null, userRole, profileImagePath]
        );

        logger.info('Signup successful', { userId, employeeId });

        // Send welcome email with employee ID (non-blocking)
        try {
            await sendEmployeeIdEmail(email.trim().toLowerCase(), name.trim(), employeeId, userRole);
            logger.info('Welcome email sent', { userId, employeeId });
        } catch (emailErr) {
            logger.warn('Welcome email failed (account still created)', { error: emailErr.message });
        }

        // Notify all active admins about the new registration
        try {
            const roleName = userRole === 'manager' ? 'Manager' : 'Field Executive';
            const [admins] = await db.execute("SELECT id FROM users WHERE role = 'admin' AND is_active = TRUE");
            for (const admin of admins) {
                await createNotification(
                    admin.id,
                    `New ${roleName} Registered`,
                    `${name.trim()} (${employeeId}) has created a new ${roleName} account.`,
                    'general',
                    null
                );
            }
        } catch (notifErr) {
            logger.warn('Admin notification failed after signup', { error: notifErr.message });
        }

        return res.status(201).json({
            success: true,
            message: 'Account created successfully',
            data: { id: userId, name: name.trim(), employeeId, email: email.trim().toLowerCase(), role: userRole }
        });

    } catch (error) {
        logger.error('Signup error', { error: error.message });
        if (req.file) deleteOldProfileImage(`/uploads/profiles/${req.file.filename}`);
        return res.status(500).json({ success: false, message: IS_PRODUCTION ? 'Internal server error' : error.message });
    }
});

// ---- LOGIN (REQ #2, #3, #12) ----
app.post('/api/auth/login', async (req, res) => {
    try {
        const { employeeId, password } = req.body;

        if (!employeeId || !password) {
            return res.status(400).json({ success: false, message: 'Employee ID and password are required' });
        }

        const [users] = await db.execute(
            `SELECT u.*, p.email, p.phone, p.role AS profile_role, p.zone, p.city, p.state, 
                    p.profile_image, p.fcm_token
             FROM users u
             LEFT JOIN profile p ON u.id = p.user_id
             WHERE u.employee_id = ? AND u.is_active = TRUE`,
            [employeeId.trim()]
        );

        if (users.length === 0) {
            return res.status(401).json({ success: false, message: 'Invalid employee ID or password' });
        }

        const user = users[0];
        const isValid = await bcrypt.compare(password, user.password);

        if (!isValid) {
            return res.status(401).json({ success: false, message: 'Invalid employee ID or password' });
        }

        // REQ #2: role goes into JWT so all routes know who is who
        const role = user.role || user.profile_role || 'field_executive';

        // Single admin enforcement: only the first (lowest-ID) admin can log in
        if (role === 'admin') {
            const [admins] = await db.execute(
                "SELECT id FROM users WHERE role = 'admin' AND is_active = TRUE ORDER BY id ASC LIMIT 1"
            );
            if (admins.length > 0 && admins[0].id !== user.id) {
                return res.status(403).json({
                    success: false,
                    message: 'Only one administrator account is allowed. Access denied.'
                });
            }
        }

        const token = jwt.sign(
            { userId: user.id, employeeId: user.employee_id, name: user.name, role },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        logger.info('Login successful', { userId: user.id, role });

        return res.json({
            success: true,
            message: 'Login successful',
            data: {
                token,
                user: {
                    id: user.id,
                    name: user.name,
                    employeeId: user.employee_id,
                    email: user.email,
                    phone: user.phone,
                    role,                          // REQ #2: frontend uses this to show correct panel
                    zone: user.zone,
                    city: user.city,               // REQ #3: city for homepage display
                    state: user.state,             // REQ #3: state for homepage display
                    profileImage: getImageUrl(user.profile_image)
                }
            }
        });

    } catch (error) {
        logger.error('Login error', { error: error.message });
        return res.status(500).json({ success: false, message: 'Internal server error' });
    }
});

// ---- FORGOT PASSWORD (REQ #1) — OTP-based for Mobile ----
app.post('/api/auth/forgot-password', async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) return res.status(400).json({ success: false, message: 'Email is required' });

        const [profiles] = await db.execute(
            'SELECT p.*, u.name, u.id as user_id FROM profile p JOIN users u ON p.user_id = u.id WHERE p.email = ?',
            [email.trim().toLowerCase()]
        );

        if (profiles.length === 0) {
            return res.status(404).json({ success: false, message: 'No account found with this email address.' });
        }

        const profile = profiles[0];

        // Delete any existing unused tokens
        await db.execute('DELETE FROM password_reset_tokens WHERE user_id = ? AND is_used = FALSE', [profile.user_id]);

        // Generate 6-digit OTP code
        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 mins

        await db.execute(
            'INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES (?, ?, ?)',
            [profile.user_id, otpCode, expiresAt]
        );

        // Try to send email (non-blocking — if email fails, OTP still works in dev)
        try {
            await sendPasswordResetEmail(profile.email, profile.name, otpCode);
            logger.info('Password reset OTP emailed', { userId: profile.user_id });
        } catch (emailErr) {
            logger.warn('Email send failed, but OTP is saved', { error: emailErr.message });
        }

        // Build response
        const responseData = {
            success: true,
            message: 'A 6-digit reset code has been sent to your email.',
            data: { email: profile.email, name: profile.name }
        };

        // OPTIONAL: Log OTP on server for debugging (only when not in production)
        if (!IS_PRODUCTION) {
            logger.info('DEV OTP (not sent to client)', { otp: otpCode, userId: profile.user_id });
        }

        return res.json(responseData);

    } catch (error) {
        logger.error('Forgot password error', { error: error.message });
        return res.status(500).json({ success: false, message: 'Failed to process reset request' });
    }
});

// ---- RESEND OTP ----
app.post('/api/auth/resend-otp', async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) return res.status(400).json({ success: false, message: 'Email is required' });

        const [profiles] = await db.execute(
            'SELECT p.*, u.name, u.id as user_id FROM profile p JOIN users u ON p.user_id = u.id WHERE p.email = ?',
            [email.trim().toLowerCase()]
        );

        if (profiles.length === 0) {
            return res.status(404).json({ success: false, message: 'No account found with this email address.' });
        }

        const profile = profiles[0];

        // Delete any existing unused tokens
        await db.execute('DELETE FROM password_reset_tokens WHERE user_id = ? AND is_used = FALSE', [profile.user_id]);

        // Generate 6-digit OTP code
        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 mins

        await db.execute(
            'INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES (?, ?, ?)',
            [profile.user_id, otpCode, expiresAt]
        );

        // Try to send email
        try {
            await sendPasswordResetEmail(profile.email, profile.name, otpCode);
        } catch (emailErr) {
            logger.warn('Email send failed, but OTP is saved', { error: emailErr.message });
        }

        return res.json({ success: true, message: 'A new 6-digit reset code has been sent to your email.' });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to process resend request' });
    }
});

// ---- RESET PASSWORD (REQ #1) — OTP verification ----
app.post('/api/auth/reset-password', async (req, res) => {
    try {
        const { email, otp, newPassword } = req.body;

        if (!email || !otp || !newPassword) {
            return res.status(400).json({ success: false, message: 'Email, OTP code and new password are required' });
        }

        // Enforce password policy: 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special character
        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
        if (!passwordRegex.test(newPassword)) {
            return res.status(400).json({ success: false, message: 'Password must be at least 8 characters, and include an uppercase letter, a lowercase letter, a number, and a special character.' });
        }

        // Find user by email
        const [profiles] = await db.execute(
            'SELECT user_id FROM profile WHERE email = ?',
            [email.trim().toLowerCase()]
        );

        if (profiles.length === 0) {
            return res.status(400).json({ success: false, message: 'Invalid email address' });
        }

        const userId = profiles[0].user_id;

        // Verify OTP
        const [tokens] = await db.execute(
            'SELECT * FROM password_reset_tokens WHERE user_id = ? AND token = ? AND is_used = FALSE AND expires_at > UTC_TIMESTAMP()',
            [userId, otp.trim()]
        );

        if (tokens.length === 0) {
            return res.status(400).json({ success: false, message: 'Invalid or expired OTP code. Please request a new one.' });
        }

        const resetRecord = tokens[0];
        const hashedPassword = await bcrypt.hash(newPassword, 10);

        // REQ #1: Update password securely in DB
        await db.execute('UPDATE users SET password = ?, updated_at = UTC_TIMESTAMP() WHERE id = ?', [hashedPassword, userId]);
        await db.execute('UPDATE password_reset_tokens SET is_used = TRUE WHERE id = ?', [resetRecord.id]);

        logger.info('Password reset successful via OTP', { userId });

        return res.json({ success: true, message: 'Password reset successfully! Please login with your new password.' });

    } catch (error) {
        logger.error('Reset password error', { error: error.message });
        return res.status(500).json({ success: false, message: 'Failed to reset password' });
    }
});

// ---- UPDATE FCM TOKEN (for push notifications) ----
app.put('/api/auth/fcm-token', authenticateToken, async (req, res) => {
    try {
        const { fcmToken } = req.body;
        if (!fcmToken) return res.status(400).json({ success: false, message: 'FCM token required' });

        await db.execute('UPDATE profile SET fcm_token = ? WHERE user_id = ?', [fcmToken, req.user.userId]);

        return res.json({ success: true, message: 'FCM token updated' });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to update FCM token' });
    }
});

// ============================================================
// USER / PROFILE ROUTES
// ============================================================

// ---- GET PROFILE (REQ #3, #12) ----
app.get('/api/user/profile', authenticateToken, async (req, res) => {
    try {
        const [results] = await db.execute(
            `SELECT u.id, u.employee_id, u.name, u.role,
                    p.email, p.phone, p.zone, p.city, p.state, p.profile_image
             FROM users u
             LEFT JOIN profile p ON u.id = p.user_id
             WHERE u.id = ?`,
            [req.user.userId]
        );

        if (results.length === 0) return res.status(404).json({ success: false, message: 'User not found' });

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
                city: user.city,               // REQ #3
                state: user.state,             // REQ #3
                profileImage: getImageUrl(user.profile_image)
            }
        });

    } catch (error) {
        logger.error('Profile fetch error', { error: error.message });
        return res.status(500).json({ success: false, message: 'Failed to fetch profile' });
    }
});

// ---- UPDATE PROFILE ----
app.put('/api/user/profile', authenticateToken, upload.single('profileImage'), async (req, res) => {
    try {
        const userId = req.user.userId;
        const { name, email, phone, zone, city, state } = req.body;

        if (name) await db.execute('UPDATE users SET name = ? WHERE id = ?', [name.trim(), userId]);

        const fields = [];
        const values = [];

        if (email) { fields.push('email = ?'); values.push(email.trim().toLowerCase()); }
        if (phone) { fields.push('phone = ?'); values.push(phone); }
        if (zone) { fields.push('zone = ?'); values.push(zone); }
        if (city) { fields.push('city = ?'); values.push(city); }
        if (state) { fields.push('state = ?'); values.push(state); }
        if (req.file) { fields.push('profile_image = ?'); values.push(`/uploads/profiles/${req.file.filename}`); }

        if (fields.length > 0) {
            values.push(userId);
            await db.execute(`UPDATE profile SET ${fields.join(', ')} WHERE user_id = ?`, values);
        }

        return res.json({ success: true, message: 'Profile updated successfully' });

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to update profile' });
    }
});

// ---- ADMIN & MANAGER: GET EXECUTIVES (REQ #2) ----
app.get('/api/admin/executives', authenticateToken, requireAdminOrManager, async (req, res) => {
    try {
        const isManager = req.user.role === 'manager';
        const managerFilter = isManager ? 'AND u.manager_id = ?' : '';
        const params = isManager ? [req.user.userId] : [];

        const [results] = await db.execute(
            `SELECT u.id, u.employee_id, u.name, u.role, u.is_active, u.manager_id,
                    p.email, p.phone, p.zone, p.city, p.state, p.profile_image,
                    m.name AS manager_name
             FROM users u
             LEFT JOIN profile p ON u.id = p.user_id
             LEFT JOIN users m ON u.manager_id = m.id
             WHERE u.role = 'field_executive' ${managerFilter}
             ORDER BY u.name ASC`,
            params
        );

        return res.json({ success: true, data: results });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch executives' });
    }
});

// ---- ADMIN: GET ALL MANAGERS ----
app.get('/api/admin/managers', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const [results] = await db.execute(
            `SELECT u.id, u.employee_id, u.name, u.is_active,
                    p.email, p.phone, p.zone, p.city, p.state,
                    (SELECT COUNT(*) FROM users sub WHERE sub.manager_id = u.id AND sub.role = 'field_executive' AND sub.is_active = TRUE) AS fe_count
             FROM users u
             LEFT JOIN profile p ON u.id = p.user_id
             WHERE u.role = 'manager'
             ORDER BY u.name ASC`
        );

        return res.json({ success: true, data: results });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch managers' });
    }
});

// ---- ADMIN: ASSIGN FE TO MANAGER ----
app.put('/api/admin/executives/:id/assign-manager', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const { id } = req.params;
        const { manager_id } = req.body;

        let managerName = 'Unassigned';
        let managerEmail = null;

        if (manager_id) {
            const [managerCheck] = await db.execute(
                'SELECT u.id, u.name, p.email FROM users u LEFT JOIN profile p ON u.id = p.user_id WHERE u.id = ? AND u.role = "manager"',
                [manager_id]
            );
            if (managerCheck.length === 0) {
                return res.status(400).json({ success: false, message: 'Invalid manager ID' });
            }
            managerName = managerCheck[0].name;
            managerEmail = managerCheck[0].email;
        }

        await db.execute('UPDATE users SET manager_id = ? WHERE id = ? AND role = "field_executive"', [manager_id || null, id]);

        // Fetch FE details to send emails
        if (manager_id && managerEmail) {
            try {
                const [feCheck] = await db.execute(
                    'SELECT u.name, p.email FROM users u LEFT JOIN profile p ON u.id = p.user_id WHERE u.id = ?',
                    [id]
                );
                if (feCheck.length > 0 && feCheck[0].email) {
                    const { sendManagerAssignmentEmails } = require('./utils/email');
                    await sendManagerAssignmentEmails(
                        feCheck[0].email, feCheck[0].name,
                        managerEmail, managerName
                    );
                    logger.info('Assignment emails sent', { feId: id, managerId: manager_id });
                }
            } catch (err) {
                logger.warn('Failed to send assignment emails', { error: err.message });
            }
        }

        return res.json({ success: true, message: 'Manager assigned successfully' });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to assign manager' });
    }
});

// ============================================================
// DASHBOARD ROUTES (REQ #5)
// ============================================================

// ---- DASHBOARD METRICS ----
app.get('/api/dashboard/metrics', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';
        const isManager = req.user.role === 'manager';

        let aliasWhereClause = 'WHERE t.assigned_to = ? AND t.is_deleted = FALSE';
        let params = [userId];

        if (isAdmin) {
            aliasWhereClause = 'WHERE t.is_deleted = FALSE';
            params = [];
        } else if (isManager) {
            aliasWhereClause = 'WHERE t.assigned_to IN (SELECT id FROM users WHERE manager_id = ?) AND t.is_deleted = FALSE';
        }

        const totalsQuery = `
            SELECT 
                COUNT(*) AS total,
                SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) AS completed,
                SUM(CASE WHEN t.status = 'pending' OR t.status = 'in_progress' THEN 1 ELSE 0 END) AS pending,
                SUM(CASE WHEN t.status = 'missed' THEN 1 ELSE 0 END) AS missed,
                SUM(CASE WHEN DATE(t.scheduled_time) = CURDATE() THEN 1 ELSE 0 END) AS today
            FROM tasks t
            ${aliasWhereClause}
        `;

        const [totals] = await db.execute(totalsQuery, params);

        // Additional Analytics: Visit counts (now just counting tasks)
        let visitWhere = 'WHERE assigned_to = ? AND is_deleted = FALSE';
        let visitParams = [userId];

        if (isAdmin) {
            visitWhere = 'WHERE is_deleted = FALSE';
            visitParams = [];
        } else if (isManager) {
            visitWhere = 'WHERE assigned_to IN (SELECT id FROM users WHERE manager_id = ?) AND is_deleted = FALSE';
        }

        const [visits] = await db.execute(
            `SELECT COUNT(*) AS total_visits FROM tasks ${visitWhere}`,
            visitParams
        );

        const totalTasks = parseInt(totals[0].total) || 0;
        const completedTasks = parseInt(totals[0].completed) || 0;
        const conversionRatio = totalTasks > 0 ? ((completedTasks / totalTasks) * 100).toFixed(1) : 0;

        return res.json({
            success: true,
            data: {
                total: totalTasks,
                completed: completedTasks,
                pending: parseInt(totals[0].pending) || 0,
                missed: parseInt(totals[0].missed) || 0,
                today: parseInt(totals[0].today) || 0,
                visits_count: visits[0].total_visits || 0,
                conversion_ratio: parseFloat(conversionRatio)
            }
        });

    } catch (error) {
        logger.error('Dashboard metrics error', { error: error.message, stack: error.stack });
        return res.status(500).json({ success: false, message: 'Failed to fetch metrics' });
    }
});

// ---- DASHBOARD DETAIL BY STATUS (REQ #5) ----
// Example: GET /api/dashboard/tasks?status=pending

// ---- ADMIN/MANAGER DASHBOARD STATS ----

// ---- ADMIN/MANAGER DASHBOARD STATS ----
app.get('/api/admin/dashboard/stats', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';
        const isManager = req.user.role === 'manager';

        let usersWhere = 'role = \'field_executive\'';
        let usersParams = [];
        let tasksWhere = 't.is_deleted = FALSE';
        let tasksParams = [];

        if (isManager) {
            usersWhere += ' AND manager_id = ?';
            usersParams.push(userId);
            tasksWhere += ' AND t.assigned_to IN (SELECT id FROM users WHERE manager_id = ?)';
            tasksParams.push(userId);
        } else if (!isAdmin) {
            return res.status(403).json({ success: false, message: 'Forbidden' });
        }

        // Performance (Executives)
        const [executives] = await db.execute(
            'SELECT id, name, employee_id, zone FROM users WHERE ' + usersWhere,
            usersParams
        );

        const performance = [];
        for (const exec of executives) {
            const [counts] = await db.execute(
                'SELECT COUNT(*) as total, SUM(CASE WHEN status = \'completed\' THEN 1 ELSE 0 END) as completed FROM tasks WHERE assigned_to = ? AND is_deleted = FALSE',
                [exec.id]
            );
            const total = parseInt(counts[0].total) || 0;
            const completed = parseInt(counts[0].completed) || 0;
            const success_rate = total > 0 ? ((completed / total) * 100).toFixed(1) : 0;
            performance.push({
                name: exec.name,
                employee_id: exec.employee_id,
                zone: exec.zone,
                total_tasks: total,
                completed_tasks: completed,
                success_rate: success_rate
            });
        }

        // Recent Missed Tasks
        const [recentMissed] = await db.execute(
            'SELECT t.id, t.title, t.status, t.scheduled_time, u.name as executive_name, u.employee_id ' +
            'FROM tasks t ' +
            'LEFT JOIN users u ON t.assigned_to = u.id ' +
            'WHERE ' + tasksWhere + ' AND t.status = \'missed\' ' +
            'ORDER BY t.scheduled_time DESC LIMIT 5',
            tasksParams
        );

        // We can mock leadsStats and visitActivity for now as it\'s mainly for UI demo
        const leadsStats = [
            { day: 'Mon', count: 12 }, { day: 'Tue', count: 19 },
            { day: 'Wed', count: 15 }, { day: 'Thu', count: 22 },
            { day: 'Fri', count: 28 }, { day: 'Sat', count: 10 }
        ];

        const visitActivity = [
            { day: 'Mon', visits: 40 }, { day: 'Tue', visits: 45 },
            { day: 'Wed', visits: 38 }, { day: 'Thu', visits: 50 },
            { day: 'Fri', visits: 55 }, { day: 'Sat', visits: 20 }
        ];

        res.json({
            success: true,
            data: {
                performance,
                recentMissed,
                leadsStats,
                visitActivity
            }
        });
    } catch (error) {
        logger.error('Error fetching admin stats', { error: error.message });
        res.status(500).json({ success: false, message: 'Internal server error' });
    }
});

app.get('/api/dashboard/tasks', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';
        const isManager = req.user.role === 'manager';
        const { status, page = 1, limit = 20 } = req.query;
        const offset = (page - 1) * limit;

        const validStatuses = ['pending', 'completed', 'missed', 'in_progress'];
        if (status && !validStatuses.includes(status)) {
            return res.status(400).json({ success: false, message: 'Invalid status filter' });
        }

        let query = `
            SELECT t.*, u.name AS executive_name, u.employee_id
            FROM tasks t
            LEFT JOIN users u ON t.assigned_to = u.id
            WHERE t.is_deleted = FALSE
        `;
        const params = [];

        // REQ #12: Filter by user if executive or manager
        if (isManager) {
            query += ' AND t.assigned_to IN (SELECT id FROM users WHERE manager_id = ?)';
            params.push(userId);
        } else if (!isAdmin) {
            query += ' AND t.assigned_to = ?';
            params.push(userId);
        }

        if (status) {
            query += ' AND t.status = ?';
            params.push(status);
        }

        // Count total
        const countQuery = query.replace('t.*, u.name AS executive_name, u.employee_id', 'COUNT(*) as total');
        const [countResult] = await db.execute(countQuery, params);
        const total = countResult[0].total;

        query += ' ORDER BY t.scheduled_time DESC LIMIT ? OFFSET ?';
        params.push(parseInt(limit), offset);

        const [tasks] = await db.execute(query, params);

        return res.json({
            success: true,
            data: tasks,
            pagination: { page: parseInt(page), limit: parseInt(limit), total, totalPages: Math.ceil(total / limit) }
        });

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch tasks' });
    }
});

// ============================================================
// TASKS ROUTES (REQ #5, #7, #10, #12)
// ============================================================

// ---- GET TASKS ----
app.get('/api/tasks', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';
        const isManager = req.user.role === 'manager';
        const { page = 1, limit = isAdmin || isManager ? 200 : 20, status } = req.query;
        const offset = (page - 1) * limit;

        let query = `
            SELECT t.*, u.name AS executive_name, u.employee_id
            FROM tasks t
            LEFT JOIN users u ON t.assigned_to = u.id
            WHERE t.is_deleted = FALSE
        `;
        const params = [];

        // REQ #12: Executives only see their own tasks
        if (isManager) {
            query += ' AND t.assigned_to IN (SELECT id FROM users WHERE manager_id = ?)';
            params.push(userId);
        } else if (!isAdmin) {
            query += ' AND t.assigned_to = ?';
            params.push(userId);
        }

        if (status) {
            query += ' AND t.status = ?';
            params.push(status);
        }

        const [countResult] = await db.execute(
            query.replace('t.*, u.name AS executive_name, u.employee_id', 'COUNT(*) as total'),
            params
        );

        query += ' ORDER BY t.scheduled_time ASC LIMIT ? OFFSET ?';
        params.push(parseInt(limit), offset);

        const [tasks] = await db.execute(query, params);

        return res.json({
            success: true,
            data: tasks,
            pagination: {
                page: parseInt(page), limit: parseInt(limit),
                total: countResult[0].total,
                totalPages: Math.ceil(countResult[0].total / limit)
            }
        });

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch tasks' });
    }
});

// ---- GET SINGLE TASK ----
app.get('/api/tasks/:taskId', authenticateToken, async (req, res) => {
    try {
        const { taskId } = req.params;
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';
        const isManager = req.user.role === 'manager';

        const [tasks] = await db.execute(
            `SELECT t.*, u.name AS executive_name, u.employee_id
             FROM tasks t
             LEFT JOIN users u ON t.assigned_to = u.id
             WHERE t.id = ? AND t.is_deleted = FALSE`,
            [taskId]
        );

        if (tasks.length === 0) return res.status(404).json({ success: false, message: 'Task not found' });

        // REQ #12: Executive cannot access other's tasks
        if (!isAdmin && !isManager && tasks[0].assigned_to !== userId) {
            return res.status(403).json({ success: false, message: 'Access denied' });
        }

        if (isManager) {
            const [check] = await db.execute('SELECT manager_id FROM users WHERE id = ?', [tasks[0].assigned_to]);
            if (check.length === 0 || check[0].manager_id !== userId) {
                return res.status(403).json({ success: false, message: 'Access denied to this task' });
            }
        }

        return res.json({ success: true, data: tasks[0] });

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch task' });
    }
});

// ---- CREATE TASK (Admin & Executive) ----
app.post('/api/tasks', authenticateToken, async (req, res) => {
    try {
        const isAdmin = req.user.role === 'admin';
        const isManager = req.user.role === 'manager';
        const { title, description, type, assigned_to, client_id, client_name, location, scheduled_time } = req.body;

        // Managers can only assign to their FEs
        if (isManager && assigned_to) {
            const [check] = await db.execute('SELECT manager_id FROM users WHERE id = ?', [assigned_to]);
            if (check.length === 0 || check[0].manager_id !== req.user.userId) {
                return res.status(403).json({ success: false, message: 'You can only assign tasks to your own Field Executives' });
            }
        }

        // Executives self-assign if they don't provide assigned_to
        const finalAssignedTo = assigned_to || (!isAdmin && !isManager ? req.user.userId : null);

        if (!title || !type || !finalAssignedTo) {
            return res.status(400).json({ success: false, message: 'Title, type and assigned_to are required' });
        }

        // Auto-fetch client name if client_id provided (REQ #6)
        let resolvedClientId = client_id;
        let resolvedClientName = client_name;

        if (client_id && !client_name) {
            const [clients] = await db.execute('SELECT name FROM clients WHERE id = ?', [client_id]);
            if (clients.length > 0) resolvedClientName = clients[0].name;
        }

        // Auto-insert client if it doesn't exist
        if (!resolvedClientId && resolvedClientName) {
            const [existingClients] = await db.execute('SELECT id FROM clients WHERE name = ?', [resolvedClientName]);
            if (existingClients.length > 0) {
                resolvedClientId = existingClients[0].id;
            } else {
                const [insertClient] = await db.execute('INSERT INTO clients (name, created_at) VALUES (?, UTC_TIMESTAMP())', [resolvedClientName]);
                resolvedClientId = insertClient.insertId;
            }
        }

        const [result] = await db.execute(
            `INSERT INTO tasks (title, description, type, assigned_to, assigned_by, client_id, client_name, location, scheduled_time, created_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, UTC_TIMESTAMP())`,
            [title, description || null, type, finalAssignedTo, req.user.userId, resolvedClientId || null, resolvedClientName || null, location || null, scheduled_time || null]
        );

        // REQ #4: Create notification for assigned executive
        await createNotification(
            finalAssignedTo,
            'New Task Assigned',
            `You have a new task: ${title}`,
            'task_assigned',
            `/tasks/${result.insertId}`
        );

        // Send Email notification
        try {
            const [profiles] = await db.execute(
                'SELECT p.email, u.name FROM profile p JOIN users u ON p.user_id = u.id WHERE p.user_id = ?',
                [finalAssignedTo]
            );
            if (profiles.length > 0 && profiles[0].email) {
                await sendNotificationEmail(
                    profiles[0].email,
                    profiles[0].name,
                    'New Task Assigned',
                    `Hello ${profiles[0].name}, you have been assigned a new task: "${title}". Scheduled for: ${scheduled_time || 'Not set'}.`
                );
            }
        } catch (emailErr) {
            logger.error('Failed to send task assignment email', { error: emailErr.message });
        }

        // Notify admins about the new task
        try {
            const [admins] = await db.execute("SELECT id FROM users WHERE role = 'admin' AND is_active = TRUE");
            for (const admin of admins) {
                await createNotification(
                    admin.id,
                    'New Task Created',
                    `${req.user.name} created a new task: "${title}".`,
                    'task_assigned',
                    `/tasks/${result.insertId}`
                );
            }
        } catch (notifErr) {
            logger.warn('Failed to notify admins of new task', { error: notifErr.message });
        }

        return res.status(201).json({ success: true, message: 'Task created', data: { id: result.insertId } });

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to create task' });
    }
});

// ---- UPDATE TASK STATUS (REQ #10) ----
app.put('/api/tasks/:taskId/status', authenticateToken, async (req, res) => {
    try {
        const { taskId } = req.params;
        const { status, notes } = req.body;
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';

        const validStatuses = ['pending', 'in_progress', 'completed', 'missed'];
        if (!validStatuses.includes(status)) {
            return res.status(400).json({ success: false, message: 'Invalid status' });
        }

        // LOCK: Completed tasks cannot be reverted to pending or any other status
        const [existingTask] = await db.execute('SELECT status FROM tasks WHERE id = ? AND is_deleted = FALSE', [taskId]);
        if (existingTask.length > 0 && existingTask[0].status === 'completed' && status !== 'completed') {
            return res.status(403).json({ success: false, message: 'Completed tasks are locked and cannot be changed' });
        }

        // REQ #12: Executive can only update their own tasks
        const whereExtra = isAdmin ? '' : 'AND assigned_to = ?';
        const params = isAdmin ? [status, notes || null, taskId] : [status, notes || null, taskId, userId];

        const [result] = await db.execute(
            `UPDATE tasks SET status = ?, notes = ?, updated_at = UTC_TIMESTAMP() WHERE id = ? AND is_deleted = FALSE ${whereExtra}`,
            params
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Task not found or access denied' });
        }

        logger.info('Task status updated', { taskId, status, userId });

        // Notify admin when executive updates a task status
        if (!isAdmin) {
            try {
                const [taskInfo] = await db.execute('SELECT title, client_name FROM tasks WHERE id = ?', [taskId]);
                const taskTitle = taskInfo.length > 0 ? taskInfo[0].title : 'Unknown';
                const [admins] = await db.execute("SELECT id FROM users WHERE role = 'admin' AND is_active = TRUE");
                for (const admin of admins) {
                    await createNotification(
                        admin.id,
                        `Task ${status.charAt(0).toUpperCase() + status.slice(1)}`,
                        `${req.user.name} updated task "${taskTitle}" to ${status}.`,
                        'task_update',
                        `/tasks/${taskId}`
                    );
                }
            } catch (notifErr) {
                logger.error('Failed to notify admin of task update', { error: notifErr.message });
            }
        }

        return res.json({ success: true, message: 'Task updated successfully' });

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to update task' });
    }
});

// ---- DELETE TASK (REQ #10) ----
app.delete('/api/tasks/:taskId', authenticateToken, async (req, res) => {
    try {
        const { taskId } = req.params;
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';

        // LOCK: Completed tasks cannot be deleted
        const [existingTask] = await db.execute('SELECT status FROM tasks WHERE id = ? AND is_deleted = FALSE', [taskId]);
        if (existingTask.length > 0 && existingTask[0].status === 'completed') {
            return res.status(403).json({ success: false, message: 'Completed tasks are locked and cannot be deleted' });
        }

        // REQ #12: Executive can only delete their own tasks
        const whereExtra = isAdmin ? '' : 'AND assigned_to = ?';
        const params = isAdmin ? [taskId] : [taskId, userId];

        const [result] = await db.execute(
            `UPDATE tasks SET is_deleted = TRUE, deleted_at = UTC_TIMESTAMP() WHERE id = ? AND is_deleted = FALSE ${whereExtra}`,
            params
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Task not found or access denied' });
        }

        return res.json({ success: true, message: 'Task deleted successfully' });

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to delete task' });
    }
});

// ---- EDIT PENDING TASK DETAILS ----
app.put('/api/tasks/:taskId/edit', authenticateToken, async (req, res) => {
    try {
        const { taskId } = req.params;
        const { title, location, client_phone, notes, scheduled_time } = req.body;
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';

        // Check task exists and is not completed
        const [existingTask] = await db.execute('SELECT status, assigned_to FROM tasks WHERE id = ? AND is_deleted = FALSE', [taskId]);
        if (existingTask.length === 0) {
            return res.status(404).json({ success: false, message: 'Task not found' });
        }
        if (existingTask[0].status === 'completed') {
            return res.status(403).json({ success: false, message: 'Completed tasks are locked and cannot be edited' });
        }
        // Non-admin can only edit their own tasks
        if (!isAdmin && existingTask[0].assigned_to !== userId) {
            return res.status(403).json({ success: false, message: 'Access denied' });
        }

        const updates = [];
        const params = [];

        if (title) { updates.push('title = ?'); params.push(title); }
        if (location) { updates.push('location = ?'); params.push(location); }
        if (client_phone) { updates.push('client_phone = ?'); params.push(client_phone); }
        if (notes !== undefined) { updates.push('notes = ?'); params.push(notes); }
        if (scheduled_time) {
            updates.push('scheduled_time = ?'); params.push(scheduled_time);
            // Auto-revert missed to pending on reschedule
            if (existingTask[0].status === 'missed') {
                updates.push('status = ?'); params.push('pending');
            }
        }

        if (updates.length === 0) {
            return res.status(400).json({ success: false, message: 'No fields to update' });
        }

        updates.push('updated_at = UTC_TIMESTAMP()');
        params.push(taskId);

        await db.execute(
            `UPDATE tasks SET ${updates.join(', ')} WHERE id = ? AND is_deleted = FALSE`,
            params
        );

        logger.info('Task edited', { taskId, userId });
        return res.json({ success: true, message: 'Task updated successfully' });

    } catch (error) {
        logger.error('Error editing task', { error: error.message });
        return res.status(500).json({ success: false, message: 'Failed to edit task' });
    }
});

// ============================================================
// CLIENTS ROUTES (REQ #6 - Auto-fetch client names)
// ============================================================

// ---- SEARCH CLIENTS (auto-fetch by name) ----
app.get('/api/clients/search', authenticateToken, async (req, res) => {
    try {
        const { q } = req.query;
        if (!q || q.length < 2) {
            return res.status(400).json({ success: false, message: 'Search term must be at least 2 characters' });
        }

        const [clients] = await db.execute(
            'SELECT id, name, email, phone, company, address, city FROM clients WHERE name LIKE ? LIMIT 10',
            [`%${q}%`]
        );

        return res.json({ success: true, data: clients });

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to search clients' });
    }
});

// ---- GET ALL CLIENTS ----
app.get('/api/clients', authenticateToken, async (req, res) => {
    try {
        const [clients] = await db.execute('SELECT * FROM clients ORDER BY name ASC');
        return res.json({ success: true, data: clients });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch clients' });
    }
});

// ---- CREATE CLIENT ----
app.post('/api/clients', authenticateToken, async (req, res) => {
    try {
        const { name, email, phone, company, address, city } = req.body;
        if (!name) return res.status(400).json({ success: false, message: 'Client name is required' });

        const [result] = await db.execute(
            'INSERT INTO clients (name, email, phone, company, address, city, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [name, email || null, phone || null, company || null, address || null, city || null, req.user.userId]
        );

        return res.status(201).json({ success: true, message: 'Client created', data: { id: result.insertId } });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to create client' });
    }
});

// ============================================================
// VISITS ROUTES (REQ #7, #9, #11)
// ============================================================

// ---- GET VISITS ----
app.get('/api/visits', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';
        const { page = 1, limit = 20 } = req.query;
        const offset = (page - 1) * limit;

        // REQ #12: Only own visits for executives
        const whereClause = isAdmin ? '' : 'WHERE v.executive_id = ?';
        const params = isAdmin ? [] : [userId];

        const [countResult] = await db.execute(
            `SELECT COUNT(*) as total FROM visits v ${whereClause}`, params
        );

        const [visits] = await db.execute(
            `SELECT v.*, u.name AS executive_name, u.employee_id
             FROM visits v
             LEFT JOIN users u ON v.executive_id = u.id
             ${whereClause}
             ORDER BY v.created_at DESC LIMIT ? OFFSET ?`,
            [...params, parseInt(limit), offset]
        );

        return res.json({
            success: true,
            data: visits,
            pagination: { page: parseInt(page), limit: parseInt(limit), total: countResult[0].total }
        });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch visits' });
    }
});

// ---- CREATE VISIT ----
app.post('/api/visits', authenticateToken, async (req, res) => {
    try {
        const { task_id, client_id, client_name, title, notes } = req.body;

        if (!title) return res.status(400).json({ success: false, message: 'Title is required' });

        // REQ #6: Auto-fetch client name
        let resolvedClientName = client_name;
        if (client_id && !client_name) {
            const [clients] = await db.execute('SELECT name FROM clients WHERE id = ?', [client_id]);
            if (clients.length > 0) resolvedClientName = clients[0].name;
        }

        const [result] = await db.execute(
            'INSERT INTO visits (task_id, executive_id, client_id, client_name, title, notes, scheduled_time) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [task_id || null, req.user.userId, client_id || null, resolvedClientName || null, title, notes || null, req.body.scheduled_time || null]
        );

        return res.status(201).json({ success: true, message: 'Visit created', data: { id: result.insertId } });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to create visit' });
    }
});

// ---- CHECK-IN (REQ #9) ----
app.post('/api/visits/:visitId/checkin', authenticateToken, async (req, res) => {
    try {
        const { visitId } = req.params;
        const { lat, lng, address } = req.body;
        const userId = req.user.userId;

        if (!lat || !lng) {
            return res.status(400).json({ success: false, message: 'Latitude and longitude are required' });
        }

        const [result] = await db.execute(
            `UPDATE visits 
             SET checkin_lat = ?, checkin_lng = ?, checkin_address = ?,
                 checkin_time = UTC_TIMESTAMP(), status = 'checked_in', updated_at = UTC_TIMESTAMP()
             WHERE id = ? AND executive_id = ?`,
            [lat, lng, address || null, visitId, userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Visit not found or access denied' });
        }

        return res.json({ success: true, message: 'Checked in successfully', data: { lat, lng, address, checkinTime: new Date() } });

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to check in' });
    }
});

// ---- MAIL IT (REQ #7) ----
app.post('/api/visits/:visitId/mail', authenticateToken, async (req, res) => {
    try {
        const { visitId } = req.params;
        const { toEmail, toName } = req.body;
        const userId = req.user.userId;

        if (!toEmail) return res.status(400).json({ success: false, message: 'Recipient email is required' });

        const [visits] = await db.execute(
            `SELECT v.*, u.name AS executive_name 
             FROM visits v JOIN users u ON v.executive_id = u.id
             WHERE v.id = ? AND v.executive_id = ?`,
            [visitId, userId]
        );

        if (visits.length === 0) return res.status(404).json({ success: false, message: 'Visit not found' });

        const visit = visits[0];

        await sendVisitUpdateEmail(toEmail, toName || 'Client', {
            title: visit.title,
            executiveName: visit.executive_name,
            location: visit.checkin_address,
            checkinTime: visit.checkin_time,
            notes: visit.notes,
            status: visit.status
        });

        await db.execute(
            'UPDATE visits SET mail_sent = TRUE, mail_sent_at = UTC_TIMESTAMP() WHERE id = ?',
            [visitId]
        );

        return res.json({ success: true, message: 'Visit update emailed successfully' });

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to send email' });
    }
});

// ============================================================
// LEADS ROUTES (REQ #8 - Lead Icon)
// ============================================================

// ---- GET LEADS ----
app.get('/api/leads', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';
        const { status, classification, page = 1, limit = 20 } = req.query;
        const offset = (page - 1) * limit;

        // REQ #12: Executives only see assigned leads
        let query = `
            SELECT l.*, u.name AS executive_name
            FROM leads l
            LEFT JOIN users u ON l.assigned_to = u.id
            WHERE l.is_deleted = FALSE
        `;
        const params = [];

        if (!isAdmin) { query += ' AND l.assigned_to = ?'; params.push(userId); }
        if (status) { query += ' AND l.status = ?'; params.push(status); }
        if (classification) { query += ' AND l.classification = ?'; params.push(classification); }

        const [countResult] = await db.execute(
            query.replace('l.*, u.name AS executive_name', 'COUNT(*) as total'), params
        );

        query += ' ORDER BY l.created_at DESC LIMIT ? OFFSET ?';
        params.push(parseInt(limit), offset);

        const [leads] = await db.execute(query, params);

        return res.json({
            success: true,
            data: leads,
            pagination: { page: parseInt(page), limit: parseInt(limit), total: countResult[0].total }
        });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch leads' });
    }
});

// ---- CREATE LEAD (Admin & Executive) ----
app.post('/api/leads', authenticateToken, requireAdminOrExecutive, async (req, res) => {
    try {
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';
        const { client_name, client_email, client_phone, company, source, assigned_to, notes, follow_up_date, classification } = req.body;

        if (!client_name) return res.status(400).json({ success: false, message: 'Client name is required' });

        // Auto-assign to self if executive and no assignment provided
        const finalAssignedTo = assigned_to || (isAdmin ? null : userId);

        const [result] = await db.execute(
            'INSERT INTO leads (client_name, client_email, client_phone, company, source, assigned_to, assigned_by, notes, follow_up_date, status, classification) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [client_name, client_email || null, client_phone || null, company || null, source || null, finalAssignedTo, userId, notes || null, follow_up_date || null, req.body.status || 'new', classification || null]
        );

        if (finalAssignedTo) {
            await createNotification(finalAssignedTo, 'New Lead Assigned', `New lead: ${client_name}`, 'lead_update');

            // Send Email notification
            try {
                const [profiles] = await db.execute(
                    'SELECT p.email, u.name FROM profile p JOIN users u ON p.user_id = u.id WHERE p.user_id = ?',
                    [finalAssignedTo]
                );
                if (profiles.length > 0 && profiles[0].email) {
                    await sendNotificationEmail(
                        profiles[0].email,
                        profiles[0].name,
                        'New Lead Assigned',
                        `Hello ${profiles[0].name}, a new lead has been assigned to you: "${client_name}" from ${company || 'N/A'}.`
                    );
                }
            } catch (emailErr) {
                logger.error('Failed to send lead assignment email', { error: emailErr.message });
            }
        }

        return res.status(201).json({ success: true, message: 'Lead created', data: { id: result.insertId } });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to create lead' });
    }
});

// ---- UPDATE LEAD STATUS ----
app.put('/api/leads/:leadId/status', authenticateToken, async (req, res) => {
    try {
        const { leadId } = req.params;
        const { status, notes } = req.body;
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';

        const validStatuses = ['new', 'contacted', 'qualified', 'proposal', 'won', 'lost'];
        if (!validStatuses.includes(status)) return res.status(400).json({ success: false, message: 'Invalid status' });

        const whereExtra = isAdmin ? '' : 'AND assigned_to = ?';
        const params = isAdmin ? [status, notes || null, leadId] : [status, notes || null, leadId, userId];

        const [result] = await db.execute(
            `UPDATE leads SET status = ?, notes = ?, updated_at = UTC_TIMESTAMP() WHERE id = ? AND is_deleted = FALSE ${whereExtra}`,
            params
        );

        if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Lead not found or access denied' });

        return res.json({ success: true, message: 'Lead updated successfully' });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to update lead' });
    }
});

// ---- UPDATE LEAD CLASSIFICATION ----
app.put('/api/leads/:leadId/classification', authenticateToken, async (req, res) => {
    try {
        const { leadId } = req.params;
        const { classification } = req.body;
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';

        const validClassifications = ['hot', 'warm', 'cold'];
        if (!validClassifications.includes(classification) && classification !== null) {
            return res.status(400).json({ success: false, message: 'Invalid classification' });
        }

        const whereExtra = isAdmin ? '' : 'AND assigned_to = ?';
        const params = isAdmin ? [classification, leadId] : [classification, leadId, userId];

        const [result] = await db.execute(
            `UPDATE leads SET classification = ? WHERE id = ? AND is_deleted = FALSE ${whereExtra}`,
            params
        );

        if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Lead not found or access denied' });

        return res.json({ success: true, message: 'Classification updated successfully' });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to update classification' });
    }
});

// ---- PROPOSALS (LEADS) ----
app.post('/api/leads/:leadId/proposals', authenticateToken, uploadDocument.single('proposal_file'), async (req, res) => {
    try {
        const { leadId } = req.params;
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';

        if (!req.file) return res.status(400).json({ success: false, message: 'No file uploaded' });

        // Check access
        const whereExtra = isAdmin ? '' : 'AND assigned_to = ?';
        const params = isAdmin ? [leadId] : [leadId, userId];
        const [leads] = await db.execute(`SELECT status FROM leads WHERE id = ? AND is_deleted = FALSE ${whereExtra}`, params);
        if (leads.length === 0) return res.status(404).json({ success: false, message: 'Lead not found or access denied' });

        // Encrypt the file
        const crypto = require('crypto');
        const fs = require('fs');
        const algorithm = 'aes-256-cbc';
        const key = process.env.JWT_SECRET.substring(0, 32); // Using JWT secret as a 32-byte key
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipheriv(algorithm, Buffer.from(key), iv);

        const fileBuffer = fs.readFileSync(req.file.path);
        const encrypted = Buffer.concat([cipher.update(fileBuffer), cipher.final()]);

        // Write the IV and encrypted data back to the file
        const encryptedData = Buffer.concat([iv, encrypted]);
        fs.writeFileSync(req.file.path, encryptedData);

        await db.execute(
            'INSERT INTO lead_proposals (lead_id, file_path, original_filename, status) VALUES (?, ?, ?, ?)',
            [leadId, req.file.path, req.file.originalname, 'pending']
        );

        return res.status(201).json({ success: true, message: 'Proposal uploaded successfully' });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to upload proposal' });
    }
});

app.get('/api/leads/:leadId/proposals', authenticateToken, async (req, res) => {
    try {
        const { leadId } = req.params;
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';

        // Check access
        const whereExtra = isAdmin ? '' : 'AND assigned_to = ?';
        const params = isAdmin ? [leadId] : [leadId, userId];
        const [leads] = await db.execute(`SELECT id FROM leads WHERE id = ? AND is_deleted = FALSE ${whereExtra}`, params);
        if (leads.length === 0) return res.status(404).json({ success: false, message: 'Lead not found or access denied' });

        const [proposals] = await db.execute(
            'SELECT id, original_filename, status, created_at FROM lead_proposals WHERE lead_id = ? ORDER BY created_at DESC',
            [leadId]
        );

        return res.json({ success: true, data: proposals });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch proposals' });
    }
});

app.get('/api/proposals/:proposalId/download', authenticateToken, async (req, res) => {
    try {
        const { proposalId } = req.params;
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';

        const [proposals] = await db.execute('SELECT lp.*, l.assigned_to FROM lead_proposals lp JOIN leads l ON lp.lead_id = l.id WHERE lp.id = ?', [proposalId]);
        if (proposals.length === 0) return res.status(404).json({ success: false, message: 'Proposal not found' });

        if (!isAdmin && proposals[0].assigned_to !== userId) {
            return res.status(403).json({ success: false, message: 'Access denied' });
        }

        const crypto = require('crypto');
        const fs = require('fs');
        const filePath = proposals[0].file_path;
        if (!fs.existsSync(filePath)) return res.status(404).json({ success: false, message: 'File not found on server' });

        // Decrypt the file
        const fileData = fs.readFileSync(filePath);
        const iv = fileData.subarray(0, 16);
        const encryptedData = fileData.subarray(16);

        const algorithm = 'aes-256-cbc';
        const key = process.env.JWT_SECRET.substring(0, 32);
        const decipher = crypto.createDecipheriv(algorithm, Buffer.from(key), iv);

        const decrypted = Buffer.concat([decipher.update(encryptedData), decipher.final()]);

        res.setHeader('Content-Disposition', `attachment; filename="${proposals[0].original_filename}"`);
        res.setHeader('Content-Type', 'application/octet-stream');
        return res.send(decrypted);

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to download proposal' });
    }
});

app.put('/api/proposals/:proposalId/status', authenticateToken, async (req, res) => {
    try {
        const { proposalId } = req.params;
        const { status } = req.body;
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';

        if (!['pending', 'won', 'lost'].includes(status)) return res.status(400).json({ success: false, message: 'Invalid status' });

        const [proposals] = await db.execute('SELECT lp.*, l.assigned_to FROM lead_proposals lp JOIN leads l ON lp.lead_id = l.id WHERE lp.id = ?', [proposalId]);
        if (proposals.length === 0) return res.status(404).json({ success: false, message: 'Proposal not found' });

        if (!isAdmin && proposals[0].assigned_to !== userId) {
            return res.status(403).json({ success: false, message: 'Access denied' });
        }

        await db.execute('UPDATE lead_proposals SET status = ? WHERE id = ?', [status, proposalId]);
        return res.json({ success: true, message: 'Proposal status updated' });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to update proposal status' });
    }
});

// ---- UPDATE VISIT STATUS ----
app.put('/api/visits/:visitId/status', authenticateToken, async (req, res) => {
    try {
        const { visitId } = req.params;
        const { status, notes } = req.body;
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';

        const validStatuses = ['pending', 'checked_in', 'completed', 'missed', 'cancelled'];
        if (!validStatuses.includes(status)) return res.status(400).json({ success: false, message: 'Invalid status' });

        const whereExtra = isAdmin ? '' : 'AND executive_id = ?';
        const params = isAdmin ? [status, notes || null, visitId] : [status, notes || null, visitId, userId];

        const [result] = await db.execute(
            `UPDATE visits SET status = ?, notes = ?, updated_at = UTC_TIMESTAMP() WHERE id = ? ${whereExtra}`,
            params
        );

        if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Visit not found or access denied' });

        return res.json({ success: true, message: 'Visit updated successfully' });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to update visit' });
    }
});

// ---- DELETE VISIT (Executive only deletes own) ----
app.delete('/api/visits/:visitId', authenticateToken, async (req, res) => {
    try {
        const { visitId } = req.params;
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';

        const whereExtra = isAdmin ? '' : 'AND executive_id = ?';
        const params = isAdmin ? [visitId] : [visitId, userId];

        const [result] = await db.execute(
            `DELETE FROM visits WHERE id = ? ${whereExtra}`,
            params
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Visit not found or access denied' });
        }

        return res.json({ success: true, message: 'Visit deleted successfully' });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to delete visit' });
    }
});

// ---- DELETE LEAD ----
app.delete('/api/leads/:leadId', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const [result] = await db.execute(
            'UPDATE leads SET is_deleted = TRUE WHERE id = ?',
            [req.params.leadId]
        );
        if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Lead not found' });
        return res.json({ success: true, message: 'Lead deleted' });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to delete lead' });
    }
});

// ============================================================
// NOTIFICATIONS ROUTES (REQ #4)
// ============================================================

// ---- GET NOTIFICATIONS ----
app.get('/api/notifications', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const { page = 1, limit = 20 } = req.query;
        const offset = (page - 1) * limit;

        const [countResult] = await db.execute(
            'SELECT COUNT(*) as total, SUM(CASE WHEN is_read = FALSE THEN 1 ELSE 0 END) as unread FROM notifications WHERE user_id = ?',
            [userId]
        );

        const [notifications] = await db.execute(
            'SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?',
            [userId, parseInt(limit), offset]
        );

        return res.json({
            success: true,
            data: notifications,
            unreadCount: parseInt(countResult[0].unread) || 0,
            pagination: { page: parseInt(page), limit: parseInt(limit), total: parseInt(countResult[0].total) || 0 }
        });

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch notifications' });
    }
});

// ---- MARK NOTIFICATION AS READ ----
app.put('/api/notifications/:notifId/read', authenticateToken, async (req, res) => {
    try {
        await db.execute(
            'UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?',
            [req.params.notifId, req.user.userId]
        );
        return res.json({ success: true, message: 'Notification marked as read' });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to update notification' });
    }
});

// ---- MARK ALL NOTIFICATIONS AS READ ----
app.put('/api/notifications/read-all', authenticateToken, async (req, res) => {
    try {
        await db.execute(
            'UPDATE notifications SET is_read = TRUE WHERE user_id = ? AND is_read = FALSE',
            [req.user.userId]
        );
        return res.json({ success: true, message: 'All notifications marked as read' });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to update notifications' });
    }
});

// ---- GET UNREAD NOTIFICATION COUNT (lightweight polling endpoint) ----
app.get('/api/notifications/unread-count', authenticateToken, async (req, res) => {
    try {
        const [result] = await db.execute(
            'SELECT COUNT(*) as unread FROM notifications WHERE user_id = ? AND is_read = FALSE',
            [req.user.userId]
        );
        return res.json({ success: true, unreadCount: result[0].unread || 0 });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch unread count' });
    }
});

// ============================================================
// COMMUNICATION ROUTES (REQ #11)
// ============================================================

// ---- LOG A CALL ----
app.post('/api/communication/call', authenticateToken, async (req, res) => {
    try {
        const { clientPhone, clientName, taskId, leadId, notes } = req.body;

        if (!clientPhone) return res.status(400).json({ success: false, message: 'Phone number required' });

        // Return the phone number so frontend can initiate call
        // tel: protocol is used on the mobile app
        return res.json({
            success: true,
            message: 'Call initiated',
            data: {
                phone: clientPhone,
                name: clientName,
                dialUrl: `tel:${clientPhone}`      // REQ #11: frontend uses this to open dialer
            }
        });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to initiate call' });
    }
});

// ---- SEND EMAIL TO CLIENT (REQ #11) ----
app.post('/api/communication/email', authenticateToken, async (req, res) => {
    try {
        const { toEmail, toName, subject, message } = req.body;

        if (!toEmail || !subject || !message) {
            return res.status(400).json({ success: false, message: 'Email, subject and message are required' });
        }

        await sendNotificationEmail(toEmail, toName || 'Client', subject, message);

        return res.json({ success: true, message: 'Email sent successfully' });

    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to send email' });
    }
});

// ============================================================
// LEAVES ROUTES
// ============================================================

app.post('/api/leaves', authenticateToken, async (req, res) => {
    try {
        const { leave_type, from_date, to_date, notes } = req.body;
        if (!leave_type || !from_date || !to_date) {
            return res.status(400).json({ success: false, message: 'Leave type, from and to dates are required' });
        }

        const [result] = await db.execute(
            `INSERT INTO leaves (user_id, leave_type, from_date, to_date, notes, status, created_at)
             VALUES (?, ?, ?, ?, ?, 'pending', UTC_TIMESTAMP())`,
            [req.user.userId, leave_type, from_date, to_date, notes || null]
        );

        return res.status(201).json({ success: true, message: 'Leave application submitted', data: { id: result.insertId } });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to apply leave' });
    }
});

app.get('/api/leaves', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        const isAdmin = req.user.role === 'admin';
        const { page = 1, limit = 20 } = req.query;
        const offset = (page - 1) * limit;

        const whereClause = isAdmin ? '' : 'WHERE l.user_id = ?';
        const params = isAdmin ? [] : [userId];

        const [countResult] = await db.execute(
            `SELECT COUNT(*) as total FROM leaves l ${whereClause}`, params
        );

        const [leaves] = await db.execute(
            `SELECT l.*, u.name AS executive_name
             FROM leaves l LEFT JOIN users u ON l.user_id = u.id
             ${whereClause}
             ORDER BY l.created_at DESC LIMIT ? OFFSET ?`,
            [...params, parseInt(limit), offset]
        );

        return res.json({
            success: true,
            data: leaves,
            pagination: { page: parseInt(page), limit: parseInt(limit), total: countResult[0].total }
        });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to fetch leaves' });
    }
});

// ---- ADMIN: Approve / Reject Leave ----
app.put('/api/leaves/:leaveId/status', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const { status } = req.body;
        if (!['approved', 'rejected'].includes(status)) {
            return res.status(400).json({ success: false, message: 'Status must be approved or rejected' });
        }

        const [result] = await db.execute(
            'UPDATE leaves SET status = ?, reviewed_by = ?, reviewed_at = UTC_TIMESTAMP() WHERE id = ?',
            [status, req.user.userId, req.params.leaveId]
        );

        if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Leave not found' });

        // Notify executive
        const [leave] = await db.execute('SELECT user_id FROM leaves WHERE id = ?', [req.params.leaveId]);
        if (leave.length > 0) {
            await createNotification(
                leave[0].user_id,
                `Leave ${status.charAt(0).toUpperCase() + status.slice(1)}`,
                `Your leave application has been ${status}.`,
                'leave_update'
            );
        }

        return res.json({ success: true, message: `Leave ${status} successfully` });
    } catch (error) {
        return res.status(500).json({ success: false, message: 'Failed to update leave' });
    }
});

// ============================================================
// HEALTH CHECK
// ============================================================

app.get('/', (req, res) => {
    return res.json({
        message: 'Pegasos Field App API v2.0 🚀',
        timestamp: new Date().toISOString(),
        version: '2.0.0',
        requirements: {
            req1_forgot_password: '✅ /api/auth/forgot-password + /api/auth/reset-password',
            req2_role_access: '✅ JWT role in token, requireAdmin middleware',
            req3_homepage_data: '✅ city, state in login response',
            req4_notifications: '✅ /api/notifications (GET, mark-read)',
            req5_dashboard: '✅ /api/dashboard/metrics + /api/dashboard/tasks?status=',
            req6_client_autofetch: '✅ /api/clients/search?q=',
            req7_title_mailit: '✅ title field in tasks/visits, /api/visits/:id/mail',
            req8_leads: '✅ /api/leads (GET, POST, status)',
            req9_checkin: '✅ /api/visits/:id/checkin (GPS)',
            req10_delete_pending: '✅ DELETE /api/tasks/:id + PUT status=pending',
            req11_call_email: '✅ /api/communication/call + /api/communication/email',
            req12_data_by_login: '✅ All queries filtered by userId + role'
        }
    });
});

app.get('/api/health', async (req, res) => {
    try {
        await db.execute('SELECT 1');
        return res.json({ success: true, status: 'healthy', database: 'connected' });
    } catch (error) {
        return res.status(500).json({ success: false, status: 'unhealthy', database: 'disconnected' });
    }
});

// Error handler
app.use((err, req, res, next) => {
    logger.error('Unhandled error', { error: err.message, stack: err.stack });
    return res.status(500).json({ success: false, message: IS_PRODUCTION ? 'Internal server error' : err.message });
});

// Start
app.listen(PORT, '0.0.0.0', () => {
    console.log('='.repeat(60));
    console.log('🚀 PEGASOS FIELD APP API v2.0');
    console.log('='.repeat(60));
    console.log(`📍 Port      : ${PORT}`);
    console.log(`🔒 Env       : ${IS_PRODUCTION ? 'PRODUCTION' : 'DEVELOPMENT'}`);
    console.log(`✅ Req #1    : Forgot Password`);
    console.log(`✅ Req #2    : Admin + Executive Panels`);
    console.log(`✅ Req #3    : Homepage dynamic data`);
    console.log(`✅ Req #4    : Notifications`);
    console.log(`✅ Req #5    : Dashboard metrics`);
    console.log(`✅ Req #6    : Client auto-fetch`);
    console.log(`✅ Req #7    : Title + Mail It`);
    console.log(`✅ Req #8    : Leads`);
    console.log(`✅ Req #9    : Check-in / GPS`);
    console.log(`✅ Req #10   : Delete + Pending`);
    console.log(`✅ Req #11   : Call + Email`);
    console.log(`✅ Req #12   : Data by login`);
    console.log('='.repeat(60));
});

// ============================================================
// NOTIFICATION ENGINE (CRON JOBS)
// ============================================================

// Check for reminders and missed tasks every minute
cron.schedule('* * * * *', async () => {
    try {
        const now = new Date();
        const thirtyMinsLater = new Date(now.getTime() + 30 * 60000);

        // 1. NEAR DUE REMINDERS (30 mins before)
        const [nearDueTasks] = await db.execute(
            `SELECT t.*, p.email, p.fcm_token, u.name as executive_name 
             FROM tasks t
             JOIN profile p ON t.assigned_to = p.user_id
             JOIN users u ON t.assigned_to = u.id
             WHERE t.status = 'pending' 
             AND t.scheduled_time BETWEEN ? AND ?
             AND t.reminder_sent = FALSE
             AND t.is_deleted = FALSE`,
            [now, thirtyMinsLater]
        );

        for (const task of nearDueTasks) {
            await createNotification(
                task.assigned_to,
                'Upcoming Meeting Reminder',
                `Reminder: Meeting with ${task.client_name} for "${task.title}" starts in 30 minutes.`,
                'visit_reminder'
            );

            if (task.email) {
                try {
                    await sendNotificationEmail(
                        task.email,
                        task.executive_name,
                        'Upcoming Meeting Reminder',
                        `Hello ${task.executive_name}, this is a reminder that your meeting with ${task.client_name} for "${task.title}" is scheduled for ${task.scheduled_time}.`
                    );
                } catch (emailErr) {
                    logger.error('Failed to send reminder email', { taskId: task.id, error: emailErr.message });
                }
            }

            await db.execute('UPDATE tasks SET reminder_sent = TRUE WHERE id = ?', [task.id]);
        }

        // 2. MEETING START NOTIFICATIONS
        const [startingTasks] = await db.execute(
            `SELECT t.*, p.email, u.name as executive_name 
             FROM tasks t
             JOIN profile p ON t.assigned_to = p.user_id
             JOIN users u ON t.assigned_to = u.id
             WHERE t.status = 'pending' 
             AND t.scheduled_time <= ?
             AND t.start_notification_sent = FALSE
             AND t.is_deleted = FALSE`,
            [now]
        );

        for (const task of startingTasks) {
            await createNotification(
                task.assigned_to,
                'Meeting Starting Now',
                `Your meeting with ${task.client_name} for "${task.title}" should start now.`,
                'visit_reminder'
            );

            await db.execute('UPDATE tasks SET start_notification_sent = TRUE WHERE id = ?', [task.id]);
        }

        // 3. AUTO-MARK MISSED
        // If task is pending and scheduled_time is > 1 hour ago
        const oneHourAgo = new Date(now.getTime() - 60 * 60000);
        const [missedTasks] = await db.execute(
            `SELECT t.*, p.email, u.name as executive_name 
             FROM tasks t
             JOIN profile p ON t.assigned_to = p.user_id
             JOIN users u ON t.assigned_to = u.id
             WHERE t.status = 'pending' 
             AND t.scheduled_time < ?
             AND t.is_deleted = FALSE`,
            [oneHourAgo]
        );

        for (const task of missedTasks) {
            await db.execute("UPDATE tasks SET status = 'missed', updated_at = UTC_TIMESTAMP() WHERE id = ?", [task.id]);

            await createNotification(
                task.assigned_to,
                'Meeting Missed',
                `The scheduled time for your meeting with ${task.client_name} has passed and it was marked as missed.`,
                'task_update'
            );

            // Also notify admin about auto-missed tasks
            try {
                const [admins] = await db.execute("SELECT id FROM users WHERE role = 'admin' AND is_active = TRUE");
                for (const admin of admins) {
                    await createNotification(
                        admin.id,
                        'Task Auto-Missed',
                        `${task.executive_name}'s task "${task.title}" with ${task.client_name} was auto-marked as missed.`,
                        'task_update',
                        `/tasks/${task.id}`
                    );
                }
            } catch (notifErr) {
                logger.error('Failed to notify admin of missed task', { error: notifErr.message });
            }

            if (task.email) {
                try {
                    await sendNotificationEmail(
                        task.email,
                        task.executive_name,
                        'Meeting Missed Notification',
                        `Your meeting with ${task.client_name} for "${task.title}" was marked as missed because the scheduled time has passed without completion.`
                    );
                } catch (emailErr) {
                    logger.error('Failed to send missed email', { taskId: task.id, error: emailErr.message });
                }
            }
        }

    } catch (err) {
        logger.error('Cron job error', { error: err.message });
    }
});

// Daily Database Cleanup (Midnight)
cron.schedule('0 0 * * *', async () => {
    try {
        logger.info('Running daily database cleanup for soft-deleted records...');

        // Tasks
        const [taskResult] = await db.execute(
            "DELETE FROM tasks WHERE is_deleted = TRUE AND deleted_at < DATE_SUB(NOW(), INTERVAL 30 DAY)"
        );
        if (taskResult.affectedRows > 0) logger.info(`Deleted ${taskResult.affectedRows} old tasks.`);

        // Leads
        const [leadResult] = await db.execute(
            "DELETE FROM leads WHERE is_deleted = TRUE AND updated_at < DATE_SUB(NOW(), INTERVAL 30 DAY)"
        );
        if (leadResult.affectedRows > 0) logger.info(`Deleted ${leadResult.affectedRows} old leads.`);

    } catch (err) {
        logger.error('Daily cleanup cron error', { error: err.message });
    }
});
