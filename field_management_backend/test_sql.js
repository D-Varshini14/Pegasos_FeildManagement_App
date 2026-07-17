const mysql = require('mysql2/promise'); async function check() {
    const db = await mysql.createConnection({ host: '127.0.0.1', port: 3307, user: 'root', database: 'field_management' });
    const [totals] = await db.execute(`SELECT COUNT(*) AS total, SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed, SUM(CASE WHEN status = 'pending' OR status = 'in_progress' THEN 1 ELSE 0 END) AS pending, SUM(CASE WHEN status = 'missed' THEN 1 ELSE 0 END) AS missed, SUM(CASE WHEN DATE(scheduled_time) = CURDATE() THEN 1 ELSE 0 END) AS today FROM tasks`); console.log('Raw DB output:', totals[0]); console.log('Parsed:', parseInt(totals[0].total) || 0, parseInt(totals[0].completed) || 0, parseInt(totals[0].pending) || 0, parseInt(totals[0].missed) || 0); process.exit(0);
} check();
