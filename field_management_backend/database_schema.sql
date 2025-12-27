CREATE DATABASE field_management;
USE field_management;

-- Users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    role ENUM('field_executive', 'manager', 'admin') DEFAULT 'field_executive',
    zone VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tasks table
CREATE TABLE tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type ENUM('site_evaluation', 'document_collection', 'follow_up', 'meeting') NOT NULL,
    assigned_to INT,
    location VARCHAR(255),
    scheduled_time DATETIME,
    status ENUM('pending', 'in_progress', 'completed', 'missed') DEFAULT 'pending',
    notes TEXT,
    avg_time_per_visit INT DEFAULT 0,
    customer_feedback DECIMAL(2,1) DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE CASCADE
);

-- Leaves table
CREATE TABLE leaves (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    leave_type ENUM('vacation', 'sick', 'personal', 'emergency') NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    notes TEXT,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Notifications table
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('task_assigned', 'task_update', 'leave_update', 'message') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert sample data
INSERT INTO users (employee_id, name, email, phone, password, role, zone) VALUES
('123456', 'Arun Kumar', 'arun.kumar@gmail.com', '+91 98765 43210', '$2b$10$example_hashed_password', 'field_executive', 'T-nagar, Chennai');

INSERT INTO tasks (title, description, type, assigned_to, location, scheduled_time, status, avg_time_per_visit, customer_feedback) VALUES
('Site Evaluation', 'Evaluate the site for potential setup', 'site_evaluation', 1, 'Anna Nagar', '2025-08-19 14:30:00', 'pending', 32, 4.8),
('Collect Documents', 'Collect required documents from client', 'document_collection', 1, 'T. Nagar', '2025-08-19 16:00:00', 'pending', 25, 4.5),
('Follow Up - Visit', 'Follow up visit with existing client', 'follow_up', 1, 'Velachery', '2025-08-19 17:15:00', 'pending', 20, 4.2),
('Follow Up - Visit', 'Follow up visit with existing client', 'follow_up', 1, 'Velachery', '2025-08-19 18:00:00', 'missed', 30, 4.0);