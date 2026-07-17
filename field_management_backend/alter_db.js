const db = require('./config/database');

async function runMigrations() {
    try {
        console.log("Altering 'users' table role ENUM...");
        await db.execute("ALTER TABLE users MODIFY COLUMN role ENUM('admin', 'manager', 'field_executive') DEFAULT 'field_executive'");
        
        console.log("Adding 'manager_id' to 'users'...");
        // Check if column exists first to avoid errors
        const [columns] = await db.execute("SHOW COLUMNS FROM users LIKE 'manager_id'");
        if (columns.length === 0) {
            await db.execute("ALTER TABLE users ADD COLUMN manager_id INT NULL");
            await db.execute("ALTER TABLE users ADD CONSTRAINT fk_users_manager FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE SET NULL");
        } else {
            console.log("manager_id already exists");
        }

        console.log("Altering 'profile' table role ENUM...");
        await db.execute("ALTER TABLE profile MODIFY COLUMN role ENUM('admin', 'manager', 'field_executive') DEFAULT 'field_executive'");

        console.log("Migration completed successfully.");
    } catch (e) {
        console.error("Migration failed:", e);
    } finally {
        process.exit(0);
    }
}

runMigrations();
