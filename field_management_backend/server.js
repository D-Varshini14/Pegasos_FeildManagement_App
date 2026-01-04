const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const mysql = require('mysql2');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, 'uploads', 'profiles');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for file uploads
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
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
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

// Database connection with connection pool
const db = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test database connection
db.getConnection((err, connection) => {
    if (err) {
        console.error('❌ Database connection failed:', err);
        console.error('❌ Error Code:', err.code);
        console.error('❌ Error Message:', err.message);
        process.exit(1);
    }
    console.log('✅ Connected to MySQL database');
    connection.release();
});

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Function to generate next Employee ID
function generateEmployeeId(callback) {
    const query = 'SELECT employee_id FROM users ORDER BY id DESC LIMIT 1';

    db.execute(query, (err, results) => {
        if (err) {
            console.error('❌ Error in generateEmployeeId:', err);
            callback(err, null);
            return;
        }

        let nextNumber = 1;

        if (results.length > 0 && results[0].employee_id) {
            const lastId = results[0].employee_id;
            const match = lastId.match(/^EMP(\d+)$/);
            if (match) {
                const lastNumber = parseInt(match[1]);
                nextNumber = lastNumber + 1;
            }
        }

        const newEmployeeId = 'EMP' + String(nextNumber).padStart(3, '0');
        console.log('✅ Generated Employee ID:', newEmployeeId);
        callback(null, newEmployeeId);
    });
}

// ==================== AUTHENTICATION ENDPOINTS ====================

// Signup endpoint - FIXED to prevent ERR_HTTP_HEADERS_SENT
app.post('/api/auth/signup', upload.single('profileImage'), async (req, res) => {
    let responseSent = false;

    try {
        const { name, email, phone, zone, role, password } = req.body;

        console.log('='.repeat(60));
        console.log('📝 SIGNUP REQUEST RECEIVED');
        console.log('='.repeat(60));
        console.log('Name:', name);
        console.log('Email:', email);
        console.log('Phone:', phone);
        console.log('Zone:', zone);
        console.log('Role:', role);
        console.log('Password:', password ? '[PROVIDED]' : '[MISSING]');
        console.log('Profile Image:', req.file ? req.file.filename : 'None');
        console.log('='.repeat(60));

        // Validate required fields
        if (!name || !email || !password) {
            console.log('❌ Validation failed: Missing required fields');
            responseSent = true;
            return res.status(400).json({
                success: false,
                message: 'Name, email, and password are required'
            });
        }

        // Check if email already exists in profile table
        console.log('🔍 Step 1: Checking if email exists...');
        const checkEmailQuery = 'SELECT * FROM profile WHERE email = ?';

        db.execute(checkEmailQuery, [email], async (err, results) => {
            if (responseSent) return;

            if (err) {
                console.error('='.repeat(60));
                console.error('❌ DATABASE ERROR AT EMAIL CHECK');
                console.error('='.repeat(60));
                console.error('Full Error Object:', err);
                console.error('SQL Message:', err.sqlMessage);
                console.error('SQL Code:', err.code);
                console.error('SQL State:', err.sqlState);
                console.error('SQL Query:', checkEmailQuery);
                console.error('SQL Params:', [email]);
                console.error('='.repeat(60));

                responseSent = true;
                return res.status(500).json({
                    success: false,
                    message: err.sqlMessage || err.message || 'Database error during email check',
                    error_code: err.code,
                    error_state: err.sqlState,
                    step: 'email_check'
                });
            }

            console.log('✅ Email check query executed successfully');
            console.log('📊 Results found:', results.length);

            if (results.length > 0) {
                console.log('❌ Email already exists in database');
                responseSent = true;
                return res.status(400).json({
                    success: false,
                    message: 'Email already exists'
                });
            }

            console.log('✅ Email is available');

            // Generate Employee ID
            console.log('🔍 Step 2: Generating Employee ID...');
            generateEmployeeId(async (empErr, employeeId) => {
                if (responseSent) return;

                if (empErr) {
                    console.error('❌ Error generating employee ID:', empErr);
                    responseSent = true;
                    return res.status(500).json({
                        success: false,
                        message: 'Failed to generate employee ID',
                        error: empErr.message,
                        step: 'generate_employee_id'
                    });
                }

                console.log('✅ Employee ID generated:', employeeId);

                try {
                    // Hash password
                    console.log('🔍 Step 3: Hashing password...');
                    const hashedPassword = await bcrypt.hash(password, 10);
                    console.log('✅ Password hashed successfully');

                    // Get profile image path if uploaded
                    const profileImagePath = req.file ? `/uploads/profiles/${req.file.filename}` : null;
                    console.log('📸 Profile image path:', profileImagePath || 'None');

                    // Insert into users table first
                    console.log('🔍 Step 4: Inserting into users table...');
                    const insertUserQuery = `
                        INSERT INTO users (employee_id, name, password, created_at) 
                        VALUES (?, ?, ?, NOW())
                    `;

                    db.execute(insertUserQuery, [employeeId, name.trim(), hashedPassword], (userErr, userResult) => {
                        if (responseSent) return;

                        if (userErr) {
                            console.error('='.repeat(60));
                            console.error('❌ DATABASE ERROR AT USER INSERTION');
                            console.error('='.repeat(60));
                            console.error('Full Error Object:', userErr);
                            console.error('SQL Message:', userErr.sqlMessage);
                            console.error('SQL Code:', userErr.code);
                            console.error('SQL Query:', insertUserQuery);
                            console.error('SQL Params:', [employeeId, name.trim(), '[HASHED_PASSWORD]']);
                            console.error('='.repeat(60));

                            responseSent = true;
                            return res.status(500).json({
                                success: false,
                                message: userErr.sqlMessage || 'Failed to create user account',
                                error_code: userErr.code,
                                step: 'user_insertion'
                            });
                        }

                        const userId = userResult.insertId;
                        console.log('✅ User inserted successfully with ID:', userId);

                        // Insert into profile table
                        console.log('🔍 Step 5: Inserting into profile table...');
                        const insertProfileQuery = `
                            INSERT INTO profile (user_id, email, phone, zone, role, profile_image, created_at) 
                            VALUES (?, ?, ?, ?, ?, ?, NOW())
                        `;

                        const profileValues = [
                            userId,
                            email.trim(),
                            phone || null,
                            zone || null,
                            role || 'field_executive',
                            profileImagePath
                        ];

                        console.log('📋 Profile values:', {
                            user_id: userId,
                            email: email.trim(),
                            phone: phone || null,
                            zone: zone || null,
                            role: role || 'field_executive',
                            profile_image: profileImagePath
                        });

                        db.execute(insertProfileQuery, profileValues, (profileErr, profileResult) => {
                            if (responseSent) return;

                            if (profileErr) {
                                console.error('='.repeat(60));
                                console.error('❌ DATABASE ERROR AT PROFILE INSERTION');
                                console.error('='.repeat(60));
                                console.error('Full Error Object:', profileErr);
                                console.error('SQL Message:', profileErr.sqlMessage);
                                console.error('SQL Code:', profileErr.code);
                                console.error('SQL Query:', insertProfileQuery);
                                console.error('SQL Params:', profileValues);
                                console.error('='.repeat(60));

                                // Rollback: Delete the user if profile creation fails
                                console.log('🔄 Rolling back user creation...');
                                db.execute('DELETE FROM users WHERE id = ?', [userId], (rollbackErr) => {
                                    if (rollbackErr) {
                                        console.error('❌ Rollback failed:', rollbackErr);
                                    } else {
                                        console.log('✅ User rollback completed');
                                    }
                                });

                                responseSent = true;
                                return res.status(500).json({
                                    success: false,
                                    message: profileErr.sqlMessage || 'Failed to create profile',
                                    error_code: profileErr.code,
                                    step: 'profile_insertion'
                                });
                            }

                            console.log('✅ Profile inserted successfully');
                            console.log('='.repeat(60));
                            console.log('🎉 SIGNUP COMPLETED SUCCESSFULLY');
                            console.log('='.repeat(60));
                            console.log('User ID:', userId);
                            console.log('Employee ID:', employeeId);
                            console.log('Name:', name.trim());
                            console.log('Email:', email.trim());
                            console.log('='.repeat(60));

                            responseSent = true;
                            res.status(201).json({
                                success: true,
                                message: 'Account created successfully',
                                data: {
                                    id: userId,
                                    name: name.trim(),
                                    employeeId: employeeId,
                                    email: email.trim(),
                                    phone: phone || null,
                                    role: role || 'field_executive',
                                    zone: zone || null
                                }
                            });
                        });
                    });
                } catch (hashError) {
                    if (responseSent) return;
                    console.error('❌ Password hashing error:', hashError);
                    responseSent = true;
                    return res.status(500).json({
                        success: false,
                        message: 'Failed to process password',
                        error: hashError.message,
                        step: 'password_hashing'
                    });
                }
            });
        });
    } catch (error) {
        if (responseSent) return;
        console.error('='.repeat(60));
        console.error('❌ UNEXPECTED ERROR IN SIGNUP');
        console.error('='.repeat(60));
        console.error('Error:', error);
        console.error('Stack:', error.stack);
        console.error('='.repeat(60));

        responseSent = true;
        res.status(500).json({
            success: false,
            message: 'Internal server error',
            error: error.message,
            step: 'unexpected_error'
        });
    }
});

// Login endpoint
app.post('/api/auth/login', async (req, res) => {
    let responseSent = false;

    try {
        const { name, userId, password } = req.body;

        console.log('='.repeat(60));
        console.log('🔍 LOGIN REQUEST RECEIVED');
        console.log('='.repeat(60));
        console.log('Name:', name);
        console.log('User ID:', userId);
        console.log('Password:', password ? '[PROVIDED]' : '[MISSING]');
        console.log('='.repeat(60));

        if (!name || !userId || !password) {
            console.log('❌ Validation failed: Missing credentials');
            responseSent = true;
            return res.status(400).json({
                success: false,
                message: 'Name, User ID and password are required'
            });
        }

        console.log('🔍 Step 1: Checking user credentials...');
        const checkUserQuery = 'SELECT * FROM users WHERE employee_id = ? AND name = ?';

        db.execute(checkUserQuery, [userId, name], async (err, results) => {
            if (responseSent) return;

            if (err) {
                console.error('='.repeat(60));
                console.error('❌ DATABASE ERROR AT LOGIN');
                console.error('='.repeat(60));
                console.error('SQL Message:', err.sqlMessage);
                console.error('SQL Code:', err.code);
                console.error('='.repeat(60));

                responseSent = true;
                return res.status(500).json({
                    success: false,
                    message: err.sqlMessage || 'Database connection error',
                    error_code: err.code
                });
            }

            console.log('✅ User query executed, results found:', results.length);

            if (results.length === 0) {
                console.log('❌ User not found with provided credentials');
                responseSent = true;
                return res.status(401).json({
                    success: false,
                    message: 'Invalid name, user ID or password'
                });
            }

            const user = results[0];
            console.log('✅ User found:', user.name, '(' + user.employee_id + ')');

            try {
                console.log('🔍 Step 2: Verifying password...');
                const isValidPassword = await bcrypt.compare(password, user.password);

                if (!isValidPassword) {
                    console.log('❌ Invalid password');
                    if (responseSent) return;
                    responseSent = true;
                    return res.status(401).json({
                        success: false,
                        message: 'Invalid name, user ID or password'
                    });
                }

                console.log('✅ Password verified successfully');

                // Fetch profile data
                console.log('🔍 Step 3: Fetching profile data...');
                const profileQuery = 'SELECT * FROM profile WHERE user_id = ?';

                db.execute(profileQuery, [user.id], (profileErr, profileResults) => {
                    if (responseSent) return;

                    if (profileErr) {
                        console.error('⚠️ Warning: Could not fetch profile:', profileErr.sqlMessage);
                    }

                    let profileData = {};

                    if (!profileErr && profileResults.length > 0) {
                        const profile = profileResults[0];
                        profileData = {
                            email: profile.email,
                            phone: profile.phone,
                            role: profile.role,
                            zone: profile.zone,
                            profileImage: profile.profile_image
                        };
                        console.log('✅ Profile data fetched successfully');
                    } else {
                        console.log('⚠️ No profile data found for user');
                    }

                    console.log('🔍 Step 4: Generating JWT token...');
                    const token = jwt.sign(
                        {
                            userId: user.id,
                            employeeId: user.employee_id,
                            name: user.name
                        },
                        process.env.JWT_SECRET,
                        { expiresIn: '24h' }
                    );

                    console.log('✅ JWT token generated');
                    console.log('='.repeat(60));
                    console.log('🎉 LOGIN SUCCESSFUL');
                    console.log('='.repeat(60));
                    console.log('User:', user.name);
                    console.log('Employee ID:', user.employee_id);
                    console.log('='.repeat(60));

                    if (responseSent) return;
                    responseSent = true;
                    res.json({
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
                });
            } catch (bcryptError) {
                if (responseSent) return;
                console.error('❌ Password comparison error:', bcryptError);
                responseSent = true;
                return res.status(500).json({
                    success: false,
                    message: 'Authentication error'
                });
            }
        });
    } catch (error) {
        if (responseSent) return;
        console.error('❌ Login error:', error);
        responseSent = true;
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// ==================== USER ENDPOINTS ====================

// Get user profile endpoint
app.get('/api/user/profile', authenticateToken, (req, res) => {
    const userId = req.user.userId;

    console.log('📋 Fetching profile for user ID:', userId);

    const query = `
        SELECT u.id, u.employee_id, u.name, p.email, p.phone, p.role, p.zone, p.profile_image 
        FROM users u
        LEFT JOIN profile p ON u.id = p.user_id
        WHERE u.id = ?
    `;

    db.execute(query, [userId], (err, results) => {
        if (err) {
            console.error('❌ Error fetching profile:', err);
            return res.status(500).json({
                success: false,
                message: 'Database error'
            });
        }

        if (results.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const user = results[0];
        console.log('✅ Profile fetched successfully');

        res.json({
            success: true,
            data: {
                id: user.id,
                name: user.name,
                employeeId: user.employee_id,
                email: user.email,
                phone: user.phone,
                role: user.role,
                zone: user.zone,
                profileImage: user.profile_image
            }
        });
    });
});

// Update user profile endpoint - FIXED
app.put('/api/user/profile', authenticateToken, upload.single('profileImage'), (req, res) => {
    let responseSent = false;

    const userId = req.user.userId;
    const { name, email, phone, zone } = req.body;

    console.log('🔍 Profile update request for user:', userId);

    // Prepare profile updates
    let updateProfileQuery = 'UPDATE profile SET';
    const updateValues = [];
    const updateFields = [];

    if (email) {
        updateFields.push(' email = ?');
        updateValues.push(email.trim());
    }
    if (phone) {
        updateFields.push(' phone = ?');
        updateValues.push(phone);
    }
    if (zone) {
        updateFields.push(' zone = ?');
        updateValues.push(zone);
    }
    if (req.file) {
        updateFields.push(' profile_image = ?');
        updateValues.push(`/uploads/profiles/${req.file.filename}`);
    }

    // Function to update user name
    const updateUserName = (callback) => {
        if (name) {
            const updateUserQuery = 'UPDATE users SET name = ? WHERE id = ?';
            db.execute(updateUserQuery, [name.trim(), userId], (err) => {
                if (err) {
                    console.error('❌ Error updating user name:', err);
                    callback(err);
                } else {
                    console.log('✅ User name updated');
                    callback(null);
                }
            });
        } else {
            callback(null);
        }
    };

    // Function to update profile
    const updateProfile = (callback) => {
        if (updateFields.length > 0) {
            updateProfileQuery += updateFields.join(',') + ' WHERE user_id = ?';
            updateValues.push(userId);

            db.execute(updateProfileQuery, updateValues, (err) => {
                if (err) {
                    console.error('❌ Error updating profile:', err);
                    callback(err);
                } else {
                    console.log('✅ Profile updated');
                    callback(null);
                }
            });
        } else {
            callback(null);
        }
    };

    // Update user name first, then profile
    updateUserName((nameErr) => {
        if (responseSent) return;

        if (nameErr) {
            responseSent = true;
            return res.status(500).json({
                success: false,
                message: 'Failed to update user name'
            });
        }

        updateProfile((profileErr) => {
            if (responseSent) return;

            if (profileErr) {
                responseSent = true;
                return res.status(500).json({
                    success: false,
                    message: 'Failed to update profile'
                });
            }

            console.log('✅ Profile update completed for user:', userId);
            responseSent = true;
            res.json({
                success: true,
                message: 'Profile updated successfully'
            });
        });
    });
});

// ==================== TASKS ENDPOINTS ====================

// Get tasks endpoint
app.get('/api/tasks', authenticateToken, (req, res) => {
    const userId = req.user.userId;

    const query = 'SELECT * FROM tasks WHERE assigned_to = ? ORDER BY scheduled_time ASC';

    db.execute(query, [userId], (err, results) => {
        if (err) {
            console.error('❌ Error fetching tasks:', err);
            return res.status(500).json({
                success: false,
                message: 'Database error'
            });
        }

        res.json({
            success: true,
            data: results
        });
    });
});

// Update task status endpoint
app.put('/api/tasks/:taskId/status', authenticateToken, (req, res) => {
    const { taskId } = req.params;
    const { status, notes } = req.body;

    const query = 'UPDATE tasks SET status = ?, notes = ?, updated_at = NOW() WHERE id = ?';

    db.execute(query, [status, notes || null, taskId], (err, result) => {
        if (err) {
            console.error('❌ Error updating task:', err);
            return res.status(500).json({
                success: false,
                message: 'Failed to update task'
            });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Task not found'
            });
        }

        console.log('✅ Task status updated:', taskId);
        res.json({
            success: true,
            message: 'Task updated successfully'
        });
    });
});

// ==================== LEAVES ENDPOINTS ====================

// Apply leave endpoint
app.post('/api/leaves', authenticateToken, (req, res) => {
    const userId = req.user.userId;
    const { leave_type, from_date, to_date, notes } = req.body;

    if (!leave_type || !from_date || !to_date) {
        return res.status(400).json({
            success: false,
            message: 'Leave type, from date, and to date are required'
        });
    }

    const query = `
        INSERT INTO leaves (user_id, leave_type, from_date, to_date, notes, status, created_at) 
        VALUES (?, ?, ?, ?, ?, 'pending', NOW())
    `;

    db.execute(query, [userId, leave_type, from_date, to_date, notes || null], (err, result) => {
        if (err) {
            console.error('❌ Error applying leave:', err);
            return res.status(500).json({
                success: false,
                message: 'Failed to apply leave'
            });
        }

        console.log('✅ Leave application submitted by user:', userId);
        res.status(201).json({
            success: true,
            message: 'Leave application submitted successfully',
            data: {
                id: result.insertId
            }
        });
    });
});

// Get leaves endpoint
app.get('/api/leaves', authenticateToken, (req, res) => {
    const userId = req.user.userId;

    const query = 'SELECT * FROM leaves WHERE user_id = ? ORDER BY created_at DESC';

    db.execute(query, [userId], (err, results) => {
        if (err) {
            console.error('❌ Error fetching leaves:', err);
            return res.status(500).json({
                success: false,
                message: 'Database error'
            });
        }

        res.json({
            success: true,
            data: results
        });
    });
});

// ==================== MIDDLEWARE ====================

// JWT middleware
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

// Health check endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'Field Management API is running! 🚀',
        timestamp: new Date().toISOString(),
        version: '1.0.1',
        endpoints: {
            auth: {
                signup: 'POST /api/auth/signup',
                login: 'POST /api/auth/login'
            },
            user: {
                getProfile: 'GET /api/user/profile',
                updateProfile: 'PUT /api/user/profile'
            },
            tasks: {
                getTasks: 'GET /api/tasks',
                updateTaskStatus: 'PUT /api/tasks/:taskId/status'
            },
            leaves: {
                applyLeave: 'POST /api/leaves',
                getLeaves: 'GET /api/leaves'
            }
        }
    });
});

// Database test endpoint
app.get('/api/debug/db-test', (req, res) => {
    console.log('🔍 Testing database connection...');

    db.execute('SELECT 1 + 1 AS result', (err, results) => {
        if (err) {
            console.error('❌ Database test failed:', err);
            return res.status(500).json({
                success: false,
                message: 'Database connection failed',
                error: err.message
            });
        }

        console.log('✅ Database test successful');
        res.json({
            success: true,
            message: 'Database connection working',
            result: results[0].result
        });
    });
});

// Check tables endpoint
app.get('/api/debug/check-tables', (req, res) => {
    console.log('🔍 Checking database tables...');

    db.execute('SHOW TABLES', (err, results) => {
        if (err) {
            console.error('❌ Error checking tables:', err);
            return res.status(500).json({
                success: false,
                message: 'Failed to check tables',
                error: err.message
            });
        }

        const tables = results.map(row => Object.values(row)[0]);
        console.log('✅ Tables found:', tables);

        res.json({
            success: true,
            tables: tables,
            count: tables.length
        });
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('❌ Unhandled Error:', err);

    // Check if response has already been sent
    if (res.headersSent) {
        console.error('⚠️ Headers already sent, cannot send error response');
        return next(err);
    }

    res.status(500).json({
        success: false,
        message: err.message || 'Internal server error'
    });
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down gracefully...');
    db.end((err) => {
        if (err) {
            console.error('Error closing database connection:', err);
        } else {
            console.log('✅ Database connection closed');
        }
        process.exit(0);
    });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log('='.repeat(60));
    console.log('🚀 FIELD MANAGEMENT API SERVER STARTED');
    console.log('='.repeat(60));
    console.log(`📍 Port: ${PORT}`);
    console.log(`🏠 Local: http://localhost:${PORT}`);
    console.log(`🌐 Network: http://16.176.206.156:${PORT}`);
    console.log(`🏥 Health Check: http://16.176.206.156:${PORT}/`);
    console.log(`🔍 DB Test: http://16.176.206.156:${PORT}/api/debug/db-test`);
    console.log(`📊 Check Tables: http://16.176.206.156:${PORT}/api/debug/check-tables`);
    console.log('='.repeat(60));
    console.log('✅ Server is ready to accept connections');
    console.log('='.repeat(60));
});