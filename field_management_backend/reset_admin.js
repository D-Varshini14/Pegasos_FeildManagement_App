const db = require('./config/database');
const bcrypt = require('bcryptjs');

(async () => {
  try {
    const hashedPassword = await bcrypt.hash('admin123', 10);
    
    // Reset ADMIN001 password
    const [result] = await db.execute(
      'UPDATE users SET password = ?, is_active = 1 WHERE employee_id = ?',
      [hashedPassword, 'ADMIN001']
    );
    
    if (result.affectedRows > 0) {
      console.log('✅ Admin (ADMIN001) password reset to: admin123');
    } else {
      console.log('❌ User ADMIN001 not found.');
    }
    
    process.exit(0);
  } catch (e) {
    console.log('ERROR:', e.message);
    process.exit(1);
  }
})();
