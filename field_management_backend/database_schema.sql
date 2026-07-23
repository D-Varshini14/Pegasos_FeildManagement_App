-- ============================================================
-- PEGASOS FIELD APP - COMPLETE DATABASE SCHEMA
-- Version 2.0 | All 12 Requirements Covered
-- ============================================================

CREATE DATABASE IF NOT EXISTS field_management;
USE field_management;

-- ============================================================
-- 1. USERS TABLE (with role-based access)
-- ============================================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'manager', 'field_executive') DEFAULT 'field_executive',
    manager_id INT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================================
-- 2. PROFILE TABLE (extended with city/state for homepage)
-- ============================================================
CREATE TABLE profile (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    zone VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    role ENUM('admin', 'manager', 'field_executive') DEFAULT 'field_executive',
    profile_image VARCHAR(500),
    fcm_token VARCHAR(500),                    -- For push notifications
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- 3. PASSWORD RESET TOKENS TABLE (Req #1 - Forgot Password)
-- ============================================================
CREATE TABLE password_reset_tokens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- 4. CLIENTS TABLE (Req #6 - Auto-fetch client names)
-- ============================================================
CREATE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    company VARCHAR(150),
    address TEXT,
    city VARCHAR(100),
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================================
-- 5. TASKS TABLE (Req #5, #7, #10 - Dashboard, Title, Delete)
-- ============================================================
CREATE TABLE tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,                  -- Req #7: "Title" replaces "Purpose of Visit"
    description TEXT,
    type ENUM('site_evaluation', 'document_collection', 'follow_up', 'meeting') NOT NULL,
    assigned_to INT,
    assigned_by INT,                               -- Admin who assigned
    client_id INT,                                 -- Req #6: Link to client
    client_name VARCHAR(150),                      -- Cached client name
    location VARCHAR(255),
    scheduled_time DATETIME,
    status ENUM('pending', 'in_progress', 'completed', 'missed') DEFAULT 'pending',
    notes TEXT,
    avg_time_per_visit INT DEFAULT 0,
    customer_feedback DECIMAL(2,1) DEFAULT 0.0,
    is_deleted BOOLEAN DEFAULT FALSE,              -- Req #10: Soft delete
    deleted_at TIMESTAMP NULL,
    reminder_sent BOOLEAN DEFAULT FALSE,          -- Tracking for cron reminders
    start_notification_sent BOOLEAN DEFAULT FALSE, -- Tracking for start notifications
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL
);

-- ============================================================
-- 6. VISIT DETAILS TABLE (Req #7, #9, #11 - Visits with check-in)
-- ============================================================
CREATE TABLE visits (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT,
    executive_id INT NOT NULL,
    client_id INT,
    client_name VARCHAR(150),
    title VARCHAR(255) NOT NULL,                  -- Req #7: "Title"
    notes TEXT,
    checkin_lat DECIMAL(10, 8),                   -- Req #9: GPS check-in
    checkin_lng DECIMAL(11, 8),
    checkin_address VARCHAR(500),
    checkin_time TIMESTAMP NULL,
    checkout_time TIMESTAMP NULL,
    mail_sent BOOLEAN DEFAULT FALSE,              -- Req #7: "Mail It"
    mail_sent_at TIMESTAMP NULL,
    status ENUM('pending', 'checked_in', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE SET NULL,
    FOREIGN KEY (executive_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL
);

-- ============================================================
-- 7. LEADS TABLE (Req #8 - Lead Icon in navigation)
-- ============================================================
CREATE TABLE leads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    assigned_to INT,
    assigned_by INT,
    client_name VARCHAR(150) NOT NULL,
    client_email VARCHAR(100),
    client_phone VARCHAR(20),
    company VARCHAR(150),
    source VARCHAR(100),
    status ENUM('new', 'contacted', 'qualified', 'proposal', 'won', 'lost') DEFAULT 'new',
    classification ENUM('hot', 'warm', 'cold') DEFAULT NULL,
    notes TEXT,
    follow_up_date DATE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================================
-- 8. NOTIFICATIONS TABLE (Req #4 - Bell icon notifications)
-- ============================================================
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('task_assigned', 'task_update', 'leave_update', 'visit_reminder', 'lead_update', 'general') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    action_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- 9. LEAVES TABLE
-- ============================================================
CREATE TABLE leaves (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    leave_type ENUM('vacation', 'sick', 'personal', 'emergency') NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    notes TEXT,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    reviewed_by INT,
    reviewed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================================
-- SAMPLE DATA
-- ============================================================

-- Admin user (password: Admin@1234)
INSERT INTO users (employee_id, name, password, role) VALUES
('ADMIN001', 'Admin User', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

-- Field Executive (password: Exec@1234)
INSERT INTO users (employee_id, name, password, role) VALUES
('EMP001', 'Gunaseelan', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'field_executive');

INSERT INTO profile (user_id, email, phone, zone, city, state, role) VALUES
(1, 'admin@pegasos.com', '+91 99999 00001', 'HQ', 'Chennai', 'Tamil Nadu', 'admin'),
(2, 'guna@pegasos.com', '+91 98765 43210', 'T-Nagar', 'Chennai', 'Tamil Nadu', 'field_executive');

INSERT INTO clients (name, email, phone, company, city, created_by) VALUES
('Rajesh Kumar', 'rajesh@example.com', '+91 9876543210', 'ABC Corp', 'Chennai', 2),
('Priya Sharma', 'priya@example.com', '+91 9876543211', 'XYZ Ltd', 'Mumbai', 2),
('Venkatesh R', 'venkat@example.com', '+91 9876543212', 'PQR Pvt Ltd', 'Chennai', 2);

INSERT INTO tasks (title, type, assigned_to, assigned_by, client_id, client_name, location, scheduled_time, status) VALUES
('Site Evaluation - ABC Corp', 'site_evaluation', 2, 1, 1, 'Rajesh Kumar', 'Anna Nagar, Chennai', DATE_ADD(NOW(), INTERVAL 1 DAY), 'pending'),
('Document Collection', 'document_collection', 2, 1, 2, 'Priya Sharma', 'T. Nagar, Chennai', DATE_ADD(NOW(), INTERVAL 2 DAY), 'pending'),
('Follow Up Visit', 'follow_up', 2, 1, 3, 'Venkatesh R', 'Velachery, Chennai', DATE_SUB(NOW(), INTERVAL 1 DAY), 'completed'),
('Client Meeting', 'meeting', 2, 1, 1, 'Rajesh Kumar', 'Adyar, Chennai', DATE_SUB(NOW(), INTERVAL 2 DAY), 'missed');

INSERT INTO leads (assigned_to, assigned_by, client_name, client_email, client_phone, company, source, status) VALUES
(2, 1, 'Suresh Babu', 'suresh@example.com', '+91 9876500001', 'NewCo Ltd', 'referral', 'new'),
(2, 1, 'Meena Devi', 'meena@example.com', '+91 9876500002', 'StartUp Inc', 'website', 'contacted');

INSERT INTO notifications (user_id, title, message, type) VALUES
(2, 'New Task Assigned', 'You have been assigned a site evaluation task at Anna Nagar', 'task_assigned'),
(2, 'Follow-up Reminder', 'Your follow-up visit with Venkatesh R is scheduled for today', 'visit_reminder'),
(2, 'New Lead', 'A new lead has been assigned to you - Suresh Babu from NewCo Ltd', 'lead_update');
C R E A T E   T A B L E   l e a d _ p r o p o s a l s   (   i d   I N T   P R I M A R Y   K E Y   A U T O _ I N C R E M E N T ,   l e a d _ i d   I N T   N O T   N U L L ,   f i l e _ p a t h   V A R C H A R ( 5 0 0 )   N O T   N U L L ,   o r i g i n a l _ f i l e n a m e   V A R C H A R ( 2 5 5 )   N O T   N U L L ,   s t a t u s   E N U M ( ' p e n d i n g ' ,   ' w o n ' ,   ' l o s t ' )   D E F A U L T   ' p e n d i n g ' ,   c r e a t e d _ a t   T I M E S T A M P   D E F A U L T   C U R R E N T _ T I M E S T A M P ,   F O R E I G N   K E Y   ( l e a d _ i d )   R E F E R E N C E S   l e a d s ( i d )   O N   D E L E T E   C A S C A D E   ) ;  
 
-- ============================================================
-- 10. EXPENSE AND EXPENSE FORMS (Phase 9)
-- ============================================================
CREATE TABLE expenses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    total_amount_request DECIMAL(10,2) DEFAULT 0,
    amount_in_progress DECIMAL(10,2) DEFAULT 0,
    amount_claimed DECIMAL(10,2) DEFAULT 0,
    amount_pending DECIMAL(10,2) DEFAULT 0,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE expense_forms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    expense_id INT NOT NULL,
    category VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE CASCADE
);

CREATE TABLE expense_attachments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    expense_form_id INT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (expense_form_id) REFERENCES expense_forms(id) ON DELETE CASCADE
);

