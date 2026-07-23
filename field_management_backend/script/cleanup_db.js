const db = require('../config/database');

async function cleanupDatabase() {
    console.log('--- Starting Database Cleanup ---');
    try {
        console.log('Connected to database.');

        // 1. Drop the legacy 'visits' table
        console.log('Checking for legacy "visits" table...');
        const [tables] = await db.execute("SHOW TABLES LIKE 'visits'");
        if (tables.length > 0) {
            console.log('Found "visits" table. Dropping...');
            await db.execute("DROP TABLE visits");
            console.log('Dropped "visits" table successfully.');
        } else {
            console.log('"visits" table does not exist. Skipping.');
        }

        // 2. Cleanup old soft-deleted tasks
        console.log('Cleaning up soft-deleted tasks older than 30 days...');
        const [taskResult] = await db.execute(
            "DELETE FROM tasks WHERE is_deleted = TRUE AND deleted_at < DATE_SUB(NOW(), INTERVAL 30 DAY)"
        );
        console.log(`Deleted ${taskResult.affectedRows} old tasks.`);

        // 3. Cleanup old soft-deleted leads
        console.log('Cleaning up soft-deleted leads older than 30 days...');
        const [leadResult] = await db.execute(
            "DELETE FROM leads WHERE is_deleted = TRUE AND updated_at < DATE_SUB(NOW(), INTERVAL 30 DAY)"
        );
        console.log(`Deleted ${leadResult.affectedRows} old leads.`);

        console.log('--- Database Cleanup Completed Successfully ---');
        process.exit(0);
    } catch (error) {
        console.error('Error during cleanup:', error.message);
        process.exit(1);
    }
}

cleanupDatabase();
