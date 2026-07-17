const db = require('./config/database');

async function run() {
  try {
    // 1. Create expenses table
    await db.query(`
      CREATE TABLE IF NOT EXISTS expenses (
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
    `);
    
    // 2. Create expense_forms table (hierarchical items)
    await db.query(`
      CREATE TABLE IF NOT EXISTS expense_forms (
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
    `);
    
    // 3. Create attachments table
    await db.query(`
      CREATE TABLE IF NOT EXISTS expense_attachments (
        id INT PRIMARY KEY AUTO_INCREMENT,
        expense_form_id INT NOT NULL,
        file_name VARCHAR(255) NOT NULL,
        file_path VARCHAR(500) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (expense_form_id) REFERENCES expense_forms(id) ON DELETE CASCADE
      );
    `);
    
    console.log('Expense tables created successfully');
  } catch (err) {
    console.error('Error creating tables', err);
  } finally {
    process.exit(0);
  }
}

run();
