const bcrypt = require('bcryptjs');

async function hashPassword() {
    const password = 'your_test_password'; // Change this
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log('Hashed password:', hashedPassword);

    // Use this hashed password in your database INSERT query
    console.log(`
    UPDATE users SET password = '${hashedPassword}' WHERE employee_id = '123456';
    `);
}

hashPassword();