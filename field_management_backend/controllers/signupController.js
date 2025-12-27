const bcrypt = require('bcryptjs');
const db = require('../config/database');

const signup = async (req, res) => {
    try {
        const { name, email, phone, zone, role, password } = req.body;

        // Validate input
        if (!name || !email || !phone || !zone || !role || !password) {
            return res.status(400).json({
                success: false,
                message: 'All fields are required'
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

        // Validate password length
        if (password.length < 6) {
            return res.status(400).json({
                success: false,
                message: 'Password must be at least 6 characters'
            });
        }

        // Check if email already exists
        const checkEmailQuery = 'SELECT id FROM users WHERE email = ?';
        db.execute(checkEmailQuery, [email], async (err, results) => {
            if (err) {
                console.error('Database error:', err);
                return res.status(500).json({
                    success: false,
                    message: 'Database connection error'
                });
            }

            if (results.length > 0) {
                return res.status(409).json({
                    success: false,
                    message: 'Email already registered'
                });
            }

            try {
                // Generate auto-increment employee ID
                const getMaxIdQuery = 'SELECT MAX(CAST(SUBSTRING(employee_id, 2) AS UNSIGNED)) as max_id FROM users';

                db.execute(getMaxIdQuery, [], async (err, maxResults) => {
                    if (err) {
                        console.error('Error generating employee ID:', err);
                        return res.status(500).json({
                            success: false,
                            message: 'Error generating employee ID'
                        });
                    }

                    // Generate new employee ID (format: E000001, E000002, etc.)
                    const maxId = maxResults[0].max_id || 0;
                    const newEmployeeId = `E${String(maxId + 1).padStart(6, '0')}`;

                    // Hash password
                    const hashedPassword = await bcrypt.hash(password, 10);

                    // Insert new user
                    const insertQuery = `
                        INSERT INTO users (employee_id, name, email, phone, password, role, zone, created_at)
                        VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
                    `;

                    db.execute(
                        insertQuery,
                        [newEmployeeId, name, email, phone, hashedPassword, role, zone],
                        (err, result) => {
                            if (err) {
                                console.error('Error creating user:', err);
                                return res.status(500).json({
                                    success: false,
                                    message: 'Error creating user account'
                                });
                            }

                            res.status(201).json({
                                success: true,
                                message: 'Account created successfully',
                                data: {
                                    employeeId: newEmployeeId,
                                    name: name,
                                    email: email,
                                    role: role,
                                    zone: zone
                                }
                            });
                        }
                    );
                });
            } catch (bcryptError) {
                console.error('Password hashing error:', bcryptError);
                return res.status(500).json({
                    success: false,
                    message: 'Error processing request'
                });
            }
        });
    } catch (error) {
        console.error('Signup error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

module.exports = { signup };