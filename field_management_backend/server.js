// // const express = require('express');
// // const cors = require('cors');
// // const bcrypt = require('bcryptjs');
// // const jwt = require('jsonwebtoken');
// // const mysql = require('mysql2');
// // require('dotenv').config();

// // const app = express();
// // const PORT = process.env.PORT || 3000;

// // // Database connection
// // const db = mysql.createConnection({
// //     host: process.env.DB_HOST,
// //     user: process.env.DB_USER,
// //     password: process.env.DB_PASSWORD,
// //     database: process.env.DB_NAME
// // });

// // db.connect((err) => {
// //     if (err) {
// //         console.error('Database connection failed:', err);
// //         return;
// //     }
// //     console.log('Connected to MySQL database');
// // });

// // // Middleware
// // app.use(cors());
// // app.use(express.json());

// // // Simplified login endpoint - only name, userId, password
// // app.post('/api/auth/login', async (req, res) => {
// //     try {
// //         const { name, userId, password } = req.body;

// //         if (!name || !userId || !password) {
// //             return res.status(400).json({
// //                 success: false,
// //                 message: 'Name, User ID and password are required'
// //             });
// //         }

// //         // Check if user exists with both employee_id and name
// //         const checkUserQuery = 'SELECT * FROM users WHERE employee_id = ? AND name = ?';

// //         db.execute(checkUserQuery, [userId, name], async (err, results) => {
// //             if (err) {
// //                 console.error('Database error:', err);
// //                 return res.status(500).json({
// //                     success: false,
// //                     message: 'Database connection error'
// //                 });
// //             }

// //             if (results.length > 0) {
// //                 // User exists - verify password
// //                 const user = results[0];

// //                 try {
// //                     const isValidPassword = await bcrypt.compare(password, user.password);

// //                     if (!isValidPassword) {
// //                         return res.status(401).json({
// //                             success: false,
// //                             message: 'Invalid name, user ID or password'
// //                         });
// //                     }

// //                     // Generate token for existing user
// //                     const token = jwt.sign(
// //                         {
// //                             userId: user.id,
// //                             employeeId: user.employee_id,
// //                             name: user.name
// //                         },
// //                         process.env.JWT_SECRET,
// //                         { expiresIn: '24h' }
// //                     );

// //                     console.log(`Existing user logged in: ${user.name} (${user.employee_id})`);

// //                     res.json({
// //                         success: true,
// //                         message: 'Login successful',
// //                         data: {
// //                             token,
// //                             user: {
// //                                 id: user.id,
// //                                 name: user.name,
// //                                 employeeId: user.employee_id
// //                             }
// //                         }
// //                     });
// //                 } catch (bcryptError) {
// //                     console.error('Password comparison error:', bcryptError);
// //                     return res.status(500).json({
// //                         success: false,
// //                         message: 'Authentication error'
// //                     });
// //                 }
// //             } else {
// //                 // User doesn't exist - create new user (simplified)
// //                 try {
// //                     const hashedPassword = await bcrypt.hash(password, 10);

// //                     const insertUserQuery = `
// //                         INSERT INTO users (employee_id, name, password, created_at) 
// //                         VALUES (?, ?, ?, NOW())
// //                     `;

// //                     db.execute(insertUserQuery, [userId, name.trim(), hashedPassword],
// //                         (insertErr, insertResult) => {
// //                             if (insertErr) {
// //                                 console.error('Error creating user:', insertErr);
// //                                 return res.status(500).json({
// //                                     success: false,
// //                                     message: 'Failed to create user account'
// //                                 });
// //                             }

// //                             // Generate token for new user
// //                             const newUserId = insertResult.insertId;
// //                             const token = jwt.sign(
// //                                 {
// //                                     userId: newUserId,
// //                                     employeeId: userId,
// //                                     name: name.trim()
// //                                 },
// //                                 process.env.JWT_SECRET,
// //                                 { expiresIn: '24h' }
// //                             );

// //                             console.log(`New user created and logged in: ${name.trim()} (${userId})`);

// //                             res.json({
// //                                 success: true,
// //                                 message: 'Account created and login successful',
// //                                 data: {
// //                                     token,
// //                                     user: {
// //                                         id: newUserId,
// //                                         name: name.trim(),
// //                                         employeeId: userId
// //                                     }
// //                                 }
// //                             });
// //                         });
// //                 } catch (hashError) {
// //                     console.error('Password hashing error:', hashError);
// //                     return res.status(500).json({
// //                         success: false,
// //                         message: 'Failed to process password'
// //                     });
// //                 }
// //             }
// //         });
// //     } catch (error) {
// //         console.error('Login error:', error);
// //         res.status(500).json({
// //             success: false,
// //             message: 'Internal server error'
// //         });
// //     }
// // });

// // // Get user profile endpoint (simplified)
// // app.get('/api/user/profile', authenticateToken, (req, res) => {
// //     const userId = req.user.userId;

// //     const query = 'SELECT id, employee_id, name FROM users WHERE id = ?';

// //     db.execute(query, [userId], (err, results) => {
// //         if (err) {
// //             return res.status(500).json({
// //                 success: false,
// //                 message: 'Database error'
// //             });
// //         }

// //         if (results.length === 0) {
// //             return res.status(404).json({
// //                 success: false,
// //                 message: 'User not found'
// //             });
// //         }

// //         const user = results[0];
// //         res.json({
// //             success: true,
// //             data: {
// //                 id: user.id,
// //                 name: user.name,
// //                 employeeId: user.employee_id
// //             }
// //         });
// //     });
// // });

// // // JWT middleware
// // function authenticateToken(req, res, next) {
// //     const authHeader = req.headers['authorization'];
// //     const token = authHeader && authHeader.split(' ')[1];

// //     if (!token) {
// //         return res.status(401).json({
// //             success: false,
// //             message: 'Access token required'
// //         });
// //     }

// //     jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
// //         if (err) {
// //             return res.status(403).json({
// //                 success: false,
// //                 message: 'Invalid or expired token'
// //             });
// //         }
// //         req.user = user;
// //         next();
// //     });
// // }

// // // Health check endpoint
// // app.get('/', (req, res) => {
// //     res.json({ message: 'Simplified Field Management API is running!' });
// // });

// // app.listen(PORT, () => {
// //     console.log(`Server running on port ${PORT}`);
// // });



// const express = require('express');
// const cors = require('cors');
// const bcrypt = require('bcryptjs');
// const jwt = require('jsonwebtoken');
// const mysql = require('mysql2');
// const multer = require('multer');
// const path = require('path');
// const fs = require('fs');
// require('dotenv').config();

// const app = express();
// const PORT = process.env.PORT || 3000;

// // Create uploads directory if it doesn't exist
// const uploadsDir = path.join(__dirname, 'uploads', 'profiles');
// if (!fs.existsSync(uploadsDir)) {
//     fs.mkdirSync(uploadsDir, { recursive: true });
// }

// // Configure multer for file uploads
// const storage = multer.diskStorage({
//     destination: (req, file, cb) => {
//         cb(null, uploadsDir);
//     },
//     filename: (req, file, cb) => {
//         const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
//         cb(null, 'profile-' + uniqueSuffix + path.extname(file.originalname));
//     }
// });

// const upload = multer({
//     storage: storage,
//     limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
//     fileFilter: (req, file, cb) => {
//         const filetypes = /jpeg|jpg|png/;
//         const mimetype = filetypes.test(file.mimetype);
//         const extname = filetypes.test(path.extname(file.originalname).toLowerCase());

//         if (mimetype && extname) {
//             return cb(null, true);
//         }
//         cb(new Error('Only image files are allowed!'));
//     }
// });

// // Database connection
// const db = mysql.createConnection({
//     host: process.env.DB_HOST,
//     user: process.env.DB_USER,
//     password: process.env.DB_PASSWORD,
//     database: process.env.DB_NAME
// });

// db.connect((err) => {
//     if (err) {
//         console.error('Database connection failed:', err);
//         return;
//     }
//     console.log('Connected to MySQL database');
// });

// // Middleware
// app.use(cors());
// app.use(express.json());
// app.use('/uploads', express.static('uploads'));

// // Function to generate next Employee ID
// function generateEmployeeId(callback) {
//     const query = 'SELECT employee_id FROM users ORDER BY id DESC LIMIT 1';

//     db.execute(query, (err, results) => {
//         if (err) {
//             callback(err, null);
//             return;
//         }

//         let nextNumber = 1;

//         if (results.length > 0 && results[0].employee_id) {
//             const lastId = results[0].employee_id;
//             const lastNumber = parseInt(lastId.replace('EMP', ''));
//             nextNumber = lastNumber + 1;
//         }

//         const newEmployeeId = 'EMP' + String(nextNumber).padStart(3, '0');
//         callback(null, newEmployeeId);
//     });
// }

// // Signup endpoint
// app.post('/api/auth/signup', upload.single('profileImage'), async (req, res) => {
//     try {
//         const { name, email, phone, zone, role, password } = req.body;

//         console.log('Signup request received:', { name, email, phone, zone, role });

//         // Validate required fields
//         if (!name || !email || !password) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'Name, email, and password are required'
//             });
//         }

//         // Check if email already exists
//         const checkEmailQuery = 'SELECT * FROM users WHERE email = ?';
//         db.execute(checkEmailQuery, [email], async (err, results) => {
//             if (err) {
//                 console.error('Database error:', err);
//                 return res.status(500).json({
//                     success: false,
//                     message: 'Database error'
//                 });
//             }

//             if (results.length > 0) {
//                 return res.status(400).json({
//                     success: false,
//                     message: 'Email already exists'
//                 });
//             }

//             // Generate Employee ID
//             generateEmployeeId(async (empErr, employeeId) => {
//                 if (empErr) {
//                     console.error('Error generating employee ID:', empErr);
//                     return res.status(500).json({
//                         success: false,
//                         message: 'Failed to generate employee ID'
//                     });
//                 }

//                 try {
//                     // Hash password
//                     const hashedPassword = await bcrypt.hash(password, 10);

//                     // Get profile image path if uploaded
//                     const profileImagePath = req.file ? `/uploads/profiles/${req.file.filename}` : null;

//                     // Insert new user
//                     const insertQuery = `
//                         INSERT INTO users (employee_id, name, email, phone, password, role, zone, profile_image, created_at) 
//                         VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
//                     `;

//                     const values = [
//                         employeeId,
//                         name.trim(),
//                         email.trim(),
//                         phone || null,
//                         hashedPassword,
//                         role || 'field_executive',
//                         zone || null,
//                         profileImagePath
//                     ];

//                     db.execute(insertQuery, values, (insertErr, insertResult) => {
//                         if (insertErr) {
//                             console.error('Error creating user:', insertErr);
//                             return res.status(500).json({
//                                 success: false,
//                                 message: 'Failed to create account'
//                             });
//                         }

//                         console.log(`✅ New user created: ${name} (${employeeId})`);

//                         res.status(201).json({
//                             success: true,
//                             message: 'Account created successfully',
//                             data: {
//                                 id: insertResult.insertId,
//                                 name: name.trim(),
//                                 employeeId: employeeId,
//                                 email: email.trim(),
//                                 phone: phone || null,
//                                 role: role || 'field_executive',
//                                 zone: zone || null
//                             }
//                         });
//                     });
//                 } catch (hashError) {
//                     console.error('Password hashing error:', hashError);
//                     return res.status(500).json({
//                         success: false,
//                         message: 'Failed to process password'
//                     });
//                 }
//             });
//         });
//     } catch (error) {
//         console.error('Signup error:', error);
//         res.status(500).json({
//             success: false,
//             message: 'Internal server error'
//         });
//     }
// });

// // Login endpoint
// app.post('/api/auth/login', async (req, res) => {
//     try {
//         const { name, userId, password } = req.body;

//         if (!name || !userId || !password) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'Name, User ID and password are required'
//             });
//         }

//         const checkUserQuery = 'SELECT * FROM users WHERE employee_id = ? AND name = ?';

//         db.execute(checkUserQuery, [userId, name], async (err, results) => {
//             if (err) {
//                 console.error('Database error:', err);
//                 return res.status(500).json({
//                     success: false,
//                     message: 'Database connection error'
//                 });
//             }

//             if (results.length > 0) {
//                 const user = results[0];

//                 try {
//                     const isValidPassword = await bcrypt.compare(password, user.password);

//                     if (!isValidPassword) {
//                         return res.status(401).json({
//                             success: false,
//                             message: 'Invalid name, user ID or password'
//                         });
//                     }

//                     const token = jwt.sign(
//                         {
//                             userId: user.id,
//                             employeeId: user.employee_id,
//                             name: user.name
//                         },
//                         process.env.JWT_SECRET,
//                         { expiresIn: '24h' }
//                     );

//                     console.log(`✅ User logged in: ${user.name} (${user.employee_id})`);

//                     res.json({
//                         success: true,
//                         message: 'Login successful',
//                         data: {
//                             token,
//                             user: {
//                                 id: user.id,
//                                 name: user.name,
//                                 employeeId: user.employee_id,
//                                 email: user.email,
//                                 phone: user.phone,
//                                 role: user.role,
//                                 zone: user.zone
//                             }
//                         }
//                     });
//                 } catch (bcryptError) {
//                     console.error('Password comparison error:', bcryptError);
//                     return res.status(500).json({
//                         success: false,
//                         message: 'Authentication error'
//                     });
//                 }
//             } else {
//                 return res.status(401).json({
//                     success: false,
//                     message: 'Invalid name, user ID or password'
//                 });
//             }
//         });
//     } catch (error) {
//         console.error('Login error:', error);
//         res.status(500).json({
//             success: false,
//             message: 'Internal server error'
//         });
//     }
// });

// // Get user profile endpoint
// app.get('/api/user/profile', authenticateToken, (req, res) => {
//     const userId = req.user.userId;

//     const query = 'SELECT id, employee_id, name, email, phone, role, zone, profile_image FROM users WHERE id = ?';

//     db.execute(query, [userId], (err, results) => {
//         if (err) {
//             return res.status(500).json({
//                 success: false,
//                 message: 'Database error'
//             });
//         }

//         if (results.length === 0) {
//             return res.status(404).json({
//                 success: false,
//                 message: 'User not found'
//             });
//         }

//         const user = results[0];
//         res.json({
//             success: true,
//             data: {
//                 id: user.id,
//                 name: user.name,
//                 employeeId: user.employee_id,
//                 email: user.email,
//                 phone: user.phone,
//                 role: user.role,
//                 zone: user.zone,
//                 profileImage: user.profile_image
//             }
//         });
//     });
// });

// // JWT middleware
// function authenticateToken(req, res, next) {
//     const authHeader = req.headers['authorization'];
//     const token = authHeader && authHeader.split(' ')[1];

//     if (!token) {
//         return res.status(401).json({
//             success: false,
//             message: 'Access token required'
//         });
//     }

//     jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
//         if (err) {
//             return res.status(403).json({
//                 success: false,
//                 message: 'Invalid or expired token'
//             });
//         }
//         req.user = user;
//         next();
//     });
// }

// // Health check endpoint
// app.get('/', (req, res) => {
//     res.json({
//         message: 'Field Management API is running!',
//         timestamp: new Date().toISOString()
//     });
// });

// // Error handling middleware
// app.use((err, req, res, next) => {
//     console.error('Error:', err);
//     res.status(500).json({
//         success: false,
//         message: err.message || 'Internal server error'
//     });
// });

// app.listen(PORT, () => {
//     console.log(`🚀 Server running on port ${PORT}`);
//     console.log(`📍 API endpoint: http://localhost:${PORT}/api`);
// });

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

// Database connection
const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

db.connect((err) => {
    if (err) {
        console.error('Database connection failed:', err);
        return;
    }
    console.log('✅ Connected to MySQL database');
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
            callback(err, null);
            return;
        }

        let nextNumber = 1;

        if (results.length > 0 && results[0].employee_id) {
            const lastId = results[0].employee_id;
            const lastNumber = parseInt(lastId.replace('EMP', ''));
            nextNumber = lastNumber + 1;
        }

        const newEmployeeId = 'EMP' + String(nextNumber).padStart(3, '0');
        callback(null, newEmployeeId);
    });
}

// Signup endpoint
app.post('/api/auth/signup', upload.single('profileImage'), async (req, res) => {
    try {
        const { name, email, phone, zone, role, password } = req.body;

        console.log('📝 Signup request received:', { name, email, phone, zone, role });

        // Validate required fields
        if (!name || !email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Name, email, and password are required'
            });
        }

        // Check if email already exists in profile table
        const checkEmailQuery = 'SELECT * FROM profile WHERE email = ?';
        db.execute(checkEmailQuery, [email], async (err, results) => {
            if (err) {
                console.error('❌ Database error:', err);
                return res.status(500).json({
                    success: false,
                    message: 'Database error'
                });
            }

            if (results.length > 0) {
                return res.status(400).json({
                    success: false,
                    message: 'Email already exists'
                });
            }

            // Generate Employee ID
            generateEmployeeId(async (empErr, employeeId) => {
                if (empErr) {
                    console.error('❌ Error generating employee ID:', empErr);
                    return res.status(500).json({
                        success: false,
                        message: 'Failed to generate employee ID'
                    });
                }

                try {
                    // Hash password
                    const hashedPassword = await bcrypt.hash(password, 10);

                    // Get profile image path if uploaded
                    const profileImagePath = req.file ? `/uploads/profiles/${req.file.filename}` : null;

                    // Insert into users table first
                    const insertUserQuery = `
                        INSERT INTO users (employee_id, name, password, created_at) 
                        VALUES (?, ?, ?, NOW())
                    `;

                    db.execute(insertUserQuery, [employeeId, name.trim(), hashedPassword], (userErr, userResult) => {
                        if (userErr) {
                            console.error('❌ Error creating user:', userErr);
                            return res.status(500).json({
                                success: false,
                                message: 'Failed to create account'
                            });
                        }

                        const userId = userResult.insertId;

                        // Insert into profile table
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

                        db.execute(insertProfileQuery, profileValues, (profileErr, profileResult) => {
                            if (profileErr) {
                                console.error('❌ Error creating profile:', profileErr);
                                // Rollback: Delete the user if profile creation fails
                                db.execute('DELETE FROM users WHERE id = ?', [userId], () => {});
                                return res.status(500).json({
                                    success: false,
                                    message: 'Failed to create profile'
                                });
                            }

                            console.log(`✅ New user created: ${name} (${employeeId})`);

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
                    console.error('❌ Password hashing error:', hashError);
                    return res.status(500).json({
                        success: false,
                        message: 'Failed to process password'
                    });
                }
            });
        });
    } catch (error) {
        console.error('❌ Signup error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Login endpoint
app.post('/api/auth/login', async (req, res) => {
    try {
        const { name, userId, password } = req.body;

        console.log('🔐 Login attempt:', { name, userId });

        if (!name || !userId || !password) {
            return res.status(400).json({
                success: false,
                message: 'Name, User ID and password are required'
            });
        }

        const checkUserQuery = 'SELECT * FROM users WHERE employee_id = ? AND name = ?';

        db.execute(checkUserQuery, [userId, name], async (err, results) => {
            if (err) {
                console.error('❌ Database error:', err);
                return res.status(500).json({
                    success: false,
                    message: 'Database connection error'
                });
            }

            if (results.length > 0) {
                const user = results[0];

                try {
                    const isValidPassword = await bcrypt.compare(password, user.password);

                    if (!isValidPassword) {
                        console.log('❌ Invalid password for:', name);
                        return res.status(401).json({
                            success: false,
                            message: 'Invalid name, user ID or password'
                        });
                    }

                    // Fetch profile data
                    const profileQuery = 'SELECT * FROM profile WHERE user_id = ?';
                    db.execute(profileQuery, [user.id], (profileErr, profileResults) => {
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
                        }

                        const token = jwt.sign(
                            {
                                userId: user.id,
                                employeeId: user.employee_id,
                                name: user.name
                            },
                            process.env.JWT_SECRET,
                            { expiresIn: '24h' }
                        );

                        console.log(`✅ User logged in: ${user.name} (${user.employee_id})`);

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
                    console.error('❌ Password comparison error:', bcryptError);
                    return res.status(500).json({
                        success: false,
                        message: 'Authentication error'
                    });
                }
            } else {
                console.log('❌ User not found:', { name, userId });
                return res.status(401).json({
                    success: false,
                    message: 'Invalid name, user ID or password'
                });
            }
        });
    } catch (error) {
        console.error('❌ Login error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// Get user profile endpoint
app.get('/api/user/profile', authenticateToken, (req, res) => {
    const userId = req.user.userId;

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

// Update user profile endpoint
app.put('/api/user/profile', authenticateToken, upload.single('profileImage'), async (req, res) => {
    try {
        const userId = req.user.userId;
        const { name, email, phone, zone } = req.body;

        console.log('📝 Profile update request for user:', userId);

        // Update users table (name)
        if (name) {
            const updateUserQuery = 'UPDATE users SET name = ? WHERE id = ?';
            db.execute(updateUserQuery, [name.trim(), userId], (err) => {
                if (err) {
                    console.error('❌ Error updating user name:', err);
                }
            });
        }

        // Update profile table
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

        if (updateFields.length > 0) {
            updateProfileQuery += updateFields.join(',') + ' WHERE user_id = ?';
            updateValues.push(userId);

            db.execute(updateProfileQuery, updateValues, (err) => {
                if (err) {
                    console.error('❌ Error updating profile:', err);
                    return res.status(500).json({
                        success: false,
                        message: 'Failed to update profile'
                    });
                }

                console.log('✅ Profile updated for user:', userId);
                res.json({
                    success: true,
                    message: 'Profile updated successfully'
                });
            });
        } else {
            res.json({
                success: true,
                message: 'No changes to update'
            });
        }
    } catch (error) {
        console.error('❌ Profile update error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

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

// Health check endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'Field Management API is running! 🚀',
        timestamp: new Date().toISOString(),
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

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('❌ Error:', err);
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

app.listen(PORT, () => {
    console.log('='.repeat(50));
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`📍 API endpoint: http://localhost:${PORT}/api`);
    console.log(`🏥 Health check: http://localhost:${PORT}/`);
    console.log('='.repeat(50));
});