# Backend Implementation Guide for Auto-Generated Employee IDs

This guide provides the complete backend implementation for your Flutter field management app with auto-generated Employee IDs.

## Database Schema

### Users Table
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    zone VARCHAR(100),
    role ENUM('field_executive', 'manager', 'admin') DEFAULT 'field_executive',
    password VARCHAR(255) NOT NULL,
    profile_image VARCHAR(500),
    monthly_tasks_completed INT DEFAULT 0,
    avg_time_per_visit INT DEFAULT 0,
    target_completion INT DEFAULT 0,
    customer_feedback DECIMAL(3,1) DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Employee ID Counter Table
```sql
CREATE TABLE employee_id_counter (
    id INT AUTO_INCREMENT PRIMARY KEY,
    last_employee_number INT DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert initial counter
INSERT INTO employee_id_counter (last_employee_number) VALUES (0);
```

## Backend Implementation (Node.js/Express)

### 1. Database Connection Setup

```javascript
// config/database.js
const mysql = require('mysql2/promise');

const dbConfig = {
    host: 'localhost',
    user: 'your_username',
    password: 'your_password',
    database: 'field_management_db',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

const pool = mysql.createPool(dbConfig);

module.exports = pool;
```

### 2. Auth Controller

```javascript
// controllers/authController.js
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const db = require('../config/database');

// Configure multer for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/profiles/');
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
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('Only image files are allowed'));
        }
    }
});

// Function to generate next Employee ID
async function generateEmployeeId() {
    try {
        // Start transaction
        await db.execute('START TRANSACTION');
        
        // Get current counter with row lock
        const [counterRows] = await db.execute(
            'SELECT last_employee_number FROM employee_id_counter FOR UPDATE'
        );
        
        const currentNumber = counterRows[0].last_employee_number;
        const nextNumber = currentNumber + 1;
        
        // Update counter
        await db.execute(
            'UPDATE employee_id_counter SET last_employee_number = ?',
            [nextNumber]
        );
        
        // Commit transaction
        await db.execute('COMMIT');
        
        // Generate Employee ID in format EMP001, EMP002, etc.
        const employeeId = `EMP${nextNumber.toString().padStart(3, '0')}`;
        return employeeId;
        
    } catch (error) {
        // Rollback transaction on error
        await db.execute('ROLLBACK');
        throw error;
    }
}

// Signup endpoint
const signup = async (req, res) => {
    try {
        const { name, email, phone, zone, role, password } = req.body;
        
        // Validate required fields
        if (!name || !email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Name, email, and password are required'
            });
        }
        
        // Check if email already exists
        const [existingUser] = await db.execute(
            'SELECT id FROM users WHERE email = ?',
            [email]
        );
        
        if (existingUser.length > 0) {
            return res.status(400).json({
                success: false,
                message: 'Email already exists'
            });
        }
        
        // Generate Employee ID
        const employeeId = await generateEmployeeId();
        
        // Hash password
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password, saltRounds);
        
        // Handle profile image
        let profileImagePath = null;
        if (req.file) {
            profileImagePath = req.file.path;
        }
        
        // Insert user into database
        const [result] = await db.execute(
            `INSERT INTO users (employee_id, name, email, phone, zone, role, password, profile_image) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [employeeId, name, email, phone, zone, role, hashedPassword, profileImagePath]
        );
        
        // Get the created user (without password)
        const [newUser] = await db.execute(
            `SELECT id, employee_id, name, email, phone, zone, role, profile_image, 
                    monthly_tasks_completed, avg_time_per_visit, target_completion, customer_feedback
             FROM users WHERE id = ?`,
            [result.insertId]
        );
        
        // Generate JWT token
        const token = jwt.sign(
            { userId: result.insertId, employeeId: employeeId },
            process.env.JWT_SECRET || 'your-secret-key',
            { expiresIn: '7d' }
        );
        
        res.status(201).json({
            success: true,
            message: 'Account created successfully',
            data: {
                user: newUser[0],
                token: token
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

// Login endpoint
const login = async (req, res) => {
    try {
        const { name, userId, password } = req.body;
        
        // Validate required fields
        if (!name || !userId || !password) {
            return res.status(400).json({
                success: false,
                message: 'Name, User ID, and password are required'
            });
        }
        
        // Find user by Employee ID
        const [users] = await db.execute(
            `SELECT id, employee_id, name, email, phone, zone, role, password, profile_image,
                    monthly_tasks_completed, avg_time_per_visit, target_completion, customer_feedback
             FROM users WHERE employee_id = ? AND name = ?`,
            [userId, name]
        );
        
        if (users.length === 0) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }
        
        const user = users[0];
        
        // Verify password
        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }
        
        // Generate JWT token
        const token = jwt.sign(
            { userId: user.id, employeeId: user.employee_id },
            process.env.JWT_SECRET || 'your-secret-key',
            { expiresIn: '7d' }
        );
        
        // Remove password from response
        delete user.password;
        
        res.json({
            success: true,
            message: 'Login successful',
            data: {
                user: user,
                token: token
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

// Get user profile endpoint
const getUserProfile = async (req, res) => {
    try {
        const userId = req.user.userId;
        
        const [users] = await db.execute(
            `SELECT id, employee_id, name, email, phone, zone, role, profile_image,
                    monthly_tasks_completed, avg_time_per_visit, target_completion, customer_feedback
             FROM users WHERE id = ?`,
            [userId]
        );
        
        if (users.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }
        
        res.json({
            success: true,
            data: users[0]
        });
        
    } catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
};

module.exports = {
    signup,
    login,
    getUserProfile,
    upload
};
```

### 3. Auth Routes

```javascript
// routes/auth.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');

// Signup route
router.post('/signup', authController.upload.single('profileImage'), authController.signup);

// Login route
router.post('/login', authController.login);

// Get user profile route
router.get('/profile', auth, authController.getUserProfile);

module.exports = router;
```

### 4. Authentication Middleware

```javascript
// middleware/auth.js
const jwt = require('jsonwebtoken');
const db = require('../config/database');

const auth = async (req, res, next) => {
    try {
        const token = req.header('Authorization')?.replace('Bearer ', '');
        
        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'No token provided'
            });
        }
        
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
        
        // Verify user still exists
        const [users] = await db.execute(
            'SELECT id FROM users WHERE id = ?',
            [decoded.userId]
        );
        
        if (users.length === 0) {
            return res.status(401).json({
                success: false,
                message: 'User not found'
            });
        }
        
        req.user = decoded;
        next();
        
    } catch (error) {
        res.status(401).json({
            success: false,
            message: 'Invalid token'
        });
    }
};

module.exports = auth;
```

### 5. Main App Setup

```javascript
// app.js
const express = require('express');
const cors = require('cors');
const path = require('path');
const authRoutes = require('./routes/auth');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api/auth', authRoutes);

// Error handling middleware
app.use((error, req, res, next) => {
    if (error instanceof multer.MulterError) {
        if (error.code === 'LIMIT_FILE_SIZE') {
            return res.status(400).json({
                success: false,
                message: 'File too large'
            });
        }
    }
    
    res.status(500).json({
        success: false,
        message: 'Internal server error'
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
```

## Package.json Dependencies

```json
{
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.0",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "multer": "^1.4.5-lts.1",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  }
}
```

## Environment Variables (.env)

```env
DB_HOST=localhost
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=field_management_db
JWT_SECRET=your-super-secret-jwt-key
PORT=3000
```

## Key Features Implemented

1. **Auto-Generated Employee IDs**: Uses database transactions to ensure unique, sequential Employee IDs (EMP001, EMP002, etc.)

2. **Secure Authentication**: 
   - Password hashing with bcrypt
   - JWT token-based authentication
   - Protected routes with middleware

3. **Profile Image Upload**: 
   - Multer configuration for file uploads
   - Image validation and size limits
   - Static file serving

4. **Database Transactions**: 
   - Ensures Employee ID uniqueness
   - Prevents race conditions during concurrent registrations

5. **Error Handling**: 
   - Comprehensive error responses
   - Input validation
   - Database error handling

## Testing the Implementation

1. **Start the server**: `npm start`
2. **Test signup**: POST to `/api/auth/signup` with form data
3. **Test login**: POST to `/api/auth/login` with Employee ID
4. **Test profile**: GET `/api/auth/profile` with Bearer token

The backend will automatically generate Employee IDs in the format EMP001, EMP002, EMP003, etc., and the Flutter app will display this ID to users for login purposes.
