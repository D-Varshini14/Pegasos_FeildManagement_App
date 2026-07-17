const db = require('./config/database');

(async () => {
  try {
    // Get user IDs
    const [users] = await db.execute('SELECT id, employee_id, role FROM users');
    const admin = users.find(u => u.role === 'admin');
    const exec = users.find(u => u.role === 'field_executive');
    console.log('Admin ID:', admin.id, '| Exec ID:', exec.id);

    // Clear existing sample data to prevent duplication
    await db.execute('DELETE FROM tasks');
    await db.execute('DELETE FROM leads');
    await db.execute('DELETE FROM notifications');

    // Add sample tasks
    const taskInsert = `INSERT INTO tasks (title, description, type, assigned_to, assigned_by, client_name, location, scheduled_time, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`;
    
    await db.execute(taskInsert, ['Site Evaluation - ABC Corp', 'Evaluate the site for new branch', 'site_evaluation', exec.id, admin.id, 'Rajesh Kumar', 'Anna Nagar, Chennai', new Date(Date.now() + 86400000).toISOString().slice(0,19).replace('T',' '), 'pending']);
    await db.execute(taskInsert, ['Document Collection', 'Collect KYC documents from client', 'document_collection', exec.id, admin.id, 'Priya Sharma', 'T. Nagar, Chennai', new Date(Date.now() + 172800000).toISOString().slice(0,19).replace('T',' '), 'pending']);
    await db.execute(taskInsert, ['Follow Up Visit', 'Follow up on loan application', 'follow_up', exec.id, admin.id, 'Venkatesh R', 'Velachery, Chennai', new Date(Date.now() - 86400000).toISOString().slice(0,19).replace('T',' '), 'completed']);
    await db.execute(taskInsert, ['Client Meeting', 'Discuss investment options', 'meeting', exec.id, admin.id, 'Suresh Babu', 'Adyar, Chennai', new Date(Date.now() - 172800000).toISOString().slice(0,19).replace('T',' '), 'missed']);
    console.log('✅ 4 Tasks inserted');

    // Add sample leads
    const leadInsert = `INSERT INTO leads (assigned_to, assigned_by, client_name, client_email, client_phone, company, source, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`;
    
    await db.execute(leadInsert, [exec.id, admin.id, 'Suresh Babu', 'suresh@example.com', '+91 9876500001', 'NewCo Ltd', 'referral', 'new']);
    await db.execute(leadInsert, [exec.id, admin.id, 'Meena Devi', 'meena@example.com', '+91 9876500002', 'StartUp Inc', 'website', 'contacted']);
    await db.execute(leadInsert, [exec.id, admin.id, 'Arun Kumar', 'arun@example.com', '+91 9876500003', 'Tech Corp', 'walk-in', 'qualified']);
    console.log('✅ 3 Leads inserted');

    // Add sample notifications
    const notifInsert = `INSERT INTO notifications (user_id, title, message, type) VALUES (?, ?, ?, ?)`;
    
    await db.execute(notifInsert, [exec.id, 'New Task Assigned', 'You have been assigned a site evaluation task at Anna Nagar', 'task_assigned']);
    await db.execute(notifInsert, [exec.id, 'Follow-up Reminder', 'Your follow-up visit with Venkatesh R is due today', 'visit_reminder']);
    await db.execute(notifInsert, [exec.id, 'New Lead', 'A new lead has been assigned: Suresh Babu from NewCo Ltd', 'lead_update']);
    console.log('✅ 3 Notifications inserted');

    console.log('\n🎉 Sample data ready!');
    process.exit(0);
  } catch (e) {
    console.log('ERROR:', e.message);
    process.exit(1);
  }
})();
