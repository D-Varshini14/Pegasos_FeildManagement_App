// // // // const bcrypt = require('bcryptjs');
// // // // const jwt = require('jsonwebtoken');
// // // // const db = require('../config/database');

// // // // const login = async (req, res) => {
// // // //     try {
// // // //         const { userId, password } = req.body;

// // // //         const query = 'SELECT * FROM users WHERE employee_id = ?';
// // // //         db.execute(query, [userId], async (err, results) => {
// // // //             if (err) {
// // // //                 return res.status(500).json({ error: 'Database error' });
// // // //             }

// // // //             if (results.length === 0) {
// // // //                 return res.status(401).json({ error: 'Invalid credentials' });
// // // //             }

// // // //             const user = results[0];
// // // //             const isValidPassword = await bcrypt.compare(password, user.password);

// // // //             if (!isValidPassword) {
// // // //                 return res.status(401).json({ error: 'Invalid credentials' });
// // // //             }

// // // //             const token = jwt.sign(
// // // //                 { userId: user.id, employeeId: user.employee_id },
// // // //                 process.env.JWT_SECRET,
// // // //                 { expiresIn: '24h' }
// // // //             );

// // // //             res.json({
// // // //                 token,
// // // //                 user: {
// // // //                     id: user.id,
// // // //                     name: user.name,
// // // //                     email: user.email,
// // // //                     employeeId: user.employee_id,
// // // //                     role: user.role,
// // // //                     zone: user.zone
// // // //                 }
// // // //             });
// // // //         });
// // // //     } catch (error) {
// // // //         res.status(500).json({ error: 'Server error' });
// // // //     }
// // // // };

// // // // module.exports = { login };

// // // const bcrypt = require('bcryptjs');
// // // const jwt = require('jsonwebtoken');
// // // const db = require('../config/database');

// // // const login = async (req, res) => {
// // //     try {
// // //         const { userId, password } = req.body;

// // //         // Validate input
// // //         if (!userId || !password) {
// // //             return res.status(400).json({
// // //                 success: false,
// // //                 message: 'User ID and password are required'
// // //             });
// // //         }

// // //         const query = 'SELECT * FROM users WHERE employee_id = ?';

// // //         db.execute(query, [userId], async (err, results) => {
// // //             if (err) {
// // //                 console.error('Database error:', err);
// // //                 return res.status(500).json({
// // //                     success: false,
// // //                     message: 'Database connection error'
// // //                 });
// // //             }

// // //             if (results.length === 0) {
// // //                 return res.status(401).json({
// // //                     success: false,
// // //                     message: 'Invalid user ID or password'
// // //                 });
// // //             }

// // //             const user = results[0];

// // //             try {
// // //                 const isValidPassword = await bcrypt.compare(password, user.password);

// // //                 if (!isValidPassword) {
// // //                     return res.status(401).json({
// // //                         success: false,
// // //                         message: 'Invalid user ID or password'
// // //                     });
// // //                 }

// // //                 // Generate JWT token
// // //                 const token = jwt.sign(
// // //                     {
// // //                         userId: user.id,
// // //                         employeeId: user.employee_id,
// // //                         role: user.role
// // //                     },
// // //                     process.env.JWT_SECRET,
// // //                     { expiresIn: '24h' }
// // //                 );

// // //                 // Return success response
// // //                 res.json({
// // //                     success: true,
// // //                     message: 'Login successful',
// // //                     data: {
// // //                         token,
// // //                         user: {
// // //                             id: user.id,
// // //                             name: user.name,
// // //                             email: user.email,
// // //                             employeeId: user.employee_id,
// // //                             role: user.role,
// // //                             zone: user.zone,
// // //                             phone: user.phone
// // //                         }
// // //                     }
// // //                 });
// // //             } catch (bcryptError) {
// // //                 console.error('Password comparison error:', bcryptError);
// // //                 return res.status(500).json({
// // //                     success: false,
// // //                     message: 'Authentication error'
// // //                 });
// // //             }
// // //         });
// // //     } catch (error) {
// // //         console.error('Login error:', error);
// // //         res.status(500).json({
// // //             success: false,
// // //             message: 'Internal server error'
// // //         });
// // //     }
// // // };

// // // // Optional: Logout endpoint (for token blacklisting if needed)
// // // const logout = (req, res) => {
// // //     res.json({
// // //         success: true,
// // //         message: 'Logged out successfully'
// // //     });
// // // };

// // // // Optional: Token validation endpoint
// // // const validateToken = (req, res) => {
// // //     // This endpoint uses the authenticateToken middleware
// // //     res.json({
// // //         success: true,
// // //         message: 'Token is valid',
// // //         user: req.user
// // //     });
// // // };

// // // module.exports = { login, logout, validateToken };

// // const bcrypt = require('bcryptjs');
// // const jwt = require('jsonwebtoken');
// // const db = require('../config/database');

// // const login = async (req, res) => {
// //     try {
// //         const { userId, password } = req.body;

// //         // Validate input
// //         if (!userId || !password) {
// //             return res.status(400).json({
// //                 success: false,
// //                 message: 'User ID and password are required'
// //             });
// //         }

// //         const query = 'SELECT * FROM users WHERE employee_id = ?';

// //         db.execute(query, [userId], async (err, results) => {
// //             if (err) {
// //                 console.error('Database error:', err);
// //                 return res.status(500).json({
// //                     success: false,
// //                     message: 'Database connection error'
// //                 });
// //             }

// //             if (results.length === 0) {
// //                 return res.status(401).json({
// //                     success: false,
// //                     message: 'Invalid user ID or password'
// //                 });
// //             }

// //             const user = results[0];

// //             try {
// //                 const isValidPassword = await bcrypt.compare(password, user.password);

// //                 if (!isValidPassword) {
// //                     return res.status(401).json({
// //                         success: false,
// //                         message: 'Invalid user ID or password'
// //                     });
// //                 }

// //                 // Generate JWT token
// //                 const token = jwt.sign(
// //                     {
// //                         userId: user.id,
// //                         employeeId: user.employee_id,
// //                         role: user.role
// //                     },
// //                     process.env.JWT_SECRET,
// //                     { expiresIn: '24h' }
// //                 );

// //                 // Return success response
// //                 res.json({
// //                     success: true,
// //                     message: 'Login successful',
// //                     data: {
// //                         token,
// //                         user: {
// //                             id: user.id,
// //                             name: user.name,
// //                             email: user.email,
// //                             employeeId: user.employee_id,
// //                             role: user.role,
// //                             zone: user.zone,
// //                             phone: user.phone
// //                         }
// //                     }
// //                 });
// //             } catch (bcryptError) {
// //                 console.error('Password comparison error:', bcryptError);
// //                 return res.status(500).json({
// //                     success: false,
// //                     message: 'Authentication error'
// //                 });
// //             }
// //         });
// //     } catch (error) {
// //         console.error('Login error:', error);
// //         res.status(500).json({
// //             success: false,
// //             message: 'Internal server error'
// //         });
// //     }
// // };

// // const logout = (req, res) => {
// //     res.json({
// //         success: true,
// //         message: 'Logged out successfully'
// //     });
// // };

// // const validateToken = (req, res) => {
// //     res.json({
// //         success: true,
// //         message: 'Token is valid',
// //         user: req.user
// //     });
// // };

// // module.exports = { login, logout, validateToken };


// const bcrypt = require('bcryptjs');
// const jwt = require('jsonwebtoken');
// const db = require('../config/database');

// const login = async (req, res) => {
//     try {
//         const { name, userId, password } = req.body;

//         // Validate input
//         if (!name || !userId || !password) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'Name, User ID and password are required'
//             });
//         }

//         // Query to check both employee_id and name
//         const query = 'SELECT * FROM users WHERE employee_id = ? AND name = ?';

//         db.execute(query, [userId, name], async (err, results) => {
//             if (err) {
//                 console.error('Database error:', err);
//                 return res.status(500).json({
//                     success: false,
//                     message: 'Database connection error'
//                 });
//             }

//             if (results.length === 0) {
//                 return res.status(401).json({
//                     success: false,
//                     message: 'Invalid name, user ID or password'
//                 });
//             }

//             const user = results[0];

//             try {
//                 const isValidPassword = await bcrypt.compare(password, user.password);

//                 if (!isValidPassword) {
//                     return res.status(401).json({
//                         success: false,
//                         message: 'Invalid name, user ID or password'
//                     });
//                 }

//                 // Generate JWT token
//                 const token = jwt.sign(
//                     {
//                         userId: user.id,
//                         employeeId: user.employee_id,
//                         role: user.role,
//                         name: user.name
//                     },
//                     process.env.JWT_SECRET,
//                     { expiresIn: '24h' }
//                 );

//                 // Return success response
//                 res.json({
//                     success: true,
//                     message: 'Login successful',
//                     data: {
//                         token,
//                         user: {
//                             id: user.id,
//                             name: user.name,
//                             email: user.email,
//                             employeeId: user.employee_id,
//                             role: user.role,
//                             zone: user.zone,
//                             phone: user.phone
//                         }
//                     }
//                 });
//             } catch (bcryptError) {
//                 console.error('Password comparison error:', bcryptError);
//                 return res.status(500).json({
//                     success: false,
//                     message: 'Authentication error'
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
// };

// const logout = (req, res) => {
//     res.json({
//         success: true,
//         message: 'Logged out successfully'
//     });
// };

// const validateToken = (req, res) => {
//     res.json({
//         success: true,
//         message: 'Token is valid',
//         user: req.user
//     });
// };

// module.exports = { login, logout, validateToken };

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

const login = async (req, res) => {
    try {
        const { name, userId, password } = req.body;

        // Validate input
        if (!name || !userId || !password) {
            return res.status(400).json({
                success: false,
                message: 'Name, User ID and password are required'
            });
        }

        // Query to check employee_id and name (only select needed fields)
        const query = 'SELECT id, name, employee_id, password FROM users WHERE employee_id = ? AND name = ?';

        db.execute(query, [userId, name], async (err, results) => {
            if (err) {
                console.error('Database error:', err);
                return res.status(500).json({
                    success: false,
                    message: 'Database connection error'
                });
            }

            if (results.length === 0) {
                return res.status(401).json({
                    success: false,
                    message: 'Invalid name, user ID or password'
                });
            }

            const user = results[0];

            try {
                const isValidPassword = await bcrypt.compare(password, user.password);

                if (!isValidPassword) {
                    return res.status(401).json({
                        success: false,
                        message: 'Invalid name, user ID or password'
                    });
                }

                // Generate JWT token with minimal data
                const token = jwt.sign(
                    {
                        userId: user.id,
                        employeeId: user.employee_id,
                        name: user.name
                    },
                    process.env.JWT_SECRET,
                    { expiresIn: '24h' }
                );

                // Return success response with only essential data
                res.json({
                    success: true,
                    message: 'Login successful',
                    data: {
                        token,
                        user: {
                            id: user.id,
                            name: user.name,
                            employeeId: user.employee_id
                        }
                    }
                });
            } catch (bcryptError) {
                console.error('Password comparison error:', bcryptError);
                return res.status(500).json({
                    success: false,
                    message: 'Authentication error'
                });
            }
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

const logout = (req, res) => {
    res.json({
        success: true,
        message: 'Logged out successfully'
    });
};

const validateToken = (req, res) => {
    res.json({
        success: true,
        message: 'Token is valid',
        user: req.user
    });
};

module.exports = { login, logout, validateToken };