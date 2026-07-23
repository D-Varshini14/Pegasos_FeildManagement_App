const bcrypt = require('bcryptjs');

async function generateTestPassword() {
    const password = 'admin123';
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log('Use this password to login:', password);
    console.log('Run this SQL in phpMyAdmin:');
    console.log(`UPDATE users SET password = '${hashedPassword}' WHERE employee_id = '123456';`);
}

generateTestPassword();