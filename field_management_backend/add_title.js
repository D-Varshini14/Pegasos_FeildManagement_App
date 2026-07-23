const db = require('./config/database'); 
db.query('ALTER TABLE expenses ADD COLUMN title VARCHAR(255) DEFAULT "Expense Claim"')
.then(() => { console.log("Added title"); process.exit(); })
.catch(e => { console.error(e); process.exit(1); });
