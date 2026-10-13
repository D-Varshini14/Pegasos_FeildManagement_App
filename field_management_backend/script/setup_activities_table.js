const db = require('../config/database');

async function createActivitiesTable() {
    try {
        console.log("Creating 'activities' table if it doesn't exist...");
        const createTableQuery = `
            CREATE TABLE IF NOT EXISTS activities (
                id INT PRIMARY KEY AUTO_INCREMENT,
                user_id INT NOT NULL,
                type ENUM('sign_in', 'sign_out') NOT NULL,
                timestamp DATETIME NOT NULL,
                date VARCHAR(50) NOT NULL,
                day VARCHAR(20) NOT NULL,
                location VARCHAR(255),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            )
        `;
        await db.execute(createTableQuery);
        console.log("Activities table created successfully.");
    } catch (e) {
        console.error("Failed to create activities table:", e);
    } finally {
        process.exit(0);
    }
}

createActivitiesTable();
