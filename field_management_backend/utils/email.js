// ============================================================
// UTILITY: Email Service
// Req #1: Forgot Password emails
// Req #7: "Mail It" - Send visit updates via email
// Req #11: Email integration
// ============================================================

const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: Number(process.env.EMAIL_PORT),
    secure: process.env.EMAIL_SECURE === 'true', // true for 465, false for other ports
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});


// ---- Send Password Reset Email (Req #1) ----
const sendPasswordResetEmail = async (toEmail, name, resetToken) => {
    const mailOptions = {
        from: process.env.EMAIL_FROM,
        to: toEmail,
        subject: 'Pegasos Field App - Password Reset OTP',
        html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
                <h2 style="color: #0F3A68; text-align: center;">Pegasos Field App</h2>
                <p>Hello <strong>${name}</strong>,</p>
                <p>You requested to reset your password. Please use the following 6-digit OTP code to proceed:</p>
                <div style="text-align: center; margin: 30px 0;">
                    <span style="display:inline-block; padding:15px 30px; background:#f4f7f6; color:#0F3A68; 
                           font-size: 28px; font-weight: bold; letter-spacing: 5px; border-radius:8px; border: 2px dashed #0F3A68;">
                        ${resetToken}
                    </span>
                </div>
                <p style="color:#666;">This OTP expires in <strong>10 minutes</strong>.</p>
                <p style="color:#666;">If you didn't request a password reset, please ignore this email.</p>
                <hr style="border:none; border-top:1px solid #eee; margin:24px 0;">
                <p style="color:#999; font-size:12px; text-align: center;">Pegasos Field App &copy; ${new Date().getFullYear()}</p>
            </div>
        `
    };

    await transporter.sendMail(mailOptions);
};

// ---- Send Visit Update Email (Req #7 "Mail It") ----
const sendVisitUpdateEmail = async (toEmail, toName, visitData) => {
    const mailOptions = {
        from: process.env.EMAIL_FROM,
        to: toEmail,
        subject: `Visit Update: ${visitData.title}`,
        html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <h2 style="color: #2563eb;">Pegasos Field App - Visit Update</h2>
                <p>Dear <strong>${toName}</strong>,</p>
                <p>Here is the update for your recent visit:</p>
                <table style="width:100%; border-collapse:collapse; margin:16px 0;">
                    <tr style="background:#f3f4f6;">
                        <td style="padding:10px; font-weight:bold; border:1px solid #e5e7eb;">Title</td>
                        <td style="padding:10px; border:1px solid #e5e7eb;">${visitData.title}</td>
                    </tr>
                    <tr>
                        <td style="padding:10px; font-weight:bold; border:1px solid #e5e7eb;">Executive</td>
                        <td style="padding:10px; border:1px solid #e5e7eb;">${visitData.executiveName}</td>
                    </tr>
                    <tr style="background:#f3f4f6;">
                        <td style="padding:10px; font-weight:bold; border:1px solid #e5e7eb;">Location</td>
                        <td style="padding:10px; border:1px solid #e5e7eb;">${visitData.location || 'N/A'}</td>
                    </tr>
                    <tr>
                        <td style="padding:10px; font-weight:bold; border:1px solid #e5e7eb;">Check-in Time</td>
                        <td style="padding:10px; border:1px solid #e5e7eb;">${visitData.checkinTime || 'N/A'}</td>
                    </tr>
                    <tr style="background:#f3f4f6;">
                        <td style="padding:10px; font-weight:bold; border:1px solid #e5e7eb;">Notes</td>
                        <td style="padding:10px; border:1px solid #e5e7eb;">${visitData.notes || 'No notes'}</td>
                    </tr>
                    <tr>
                        <td style="padding:10px; font-weight:bold; border:1px solid #e5e7eb;">Status</td>
                        <td style="padding:10px; border:1px solid #e5e7eb;">
                            <span style="color:#16a34a; font-weight:bold;">${visitData.status}</span>
                        </td>
                    </tr>
                </table>
                <hr style="border:none; border-top:1px solid #eee; margin:24px 0;">
                <p style="color:#999; font-size:12px;">Pegasos Field App</p>
            </div>
        `
    };

    await transporter.sendMail(mailOptions);
};

// ---- Send General Notification Email ----
const sendNotificationEmail = async (toEmail, toName, subject, message) => {
    const mailOptions = {
        from: process.env.EMAIL_FROM,
        to: toEmail,
        subject: `Pegasos Field App - ${subject}`,
        html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <h2 style="color: #2563eb;">Pegasos Field App</h2>
                <p>Hello <strong>${toName}</strong>,</p>
                <p>${message}</p>
                <hr style="border:none; border-top:1px solid #eee; margin:24px 0;">
                <p style="color:#999; font-size:12px;">Pegasos Field App</p>
            </div>
        `
    };

    await transporter.sendMail(mailOptions);
};

// ---- Send Employee ID Welcome Email (on new account creation) ----
const sendEmployeeIdEmail = async (toEmail, name, employeeId, role) => {
    const roleLabel = role === 'admin' ? 'Administrator' : 'Field Executive';
    const mailOptions = {
        from: process.env.EMAIL_FROM,
        to: toEmail,
        subject: 'Welcome to Pegasos Field App – Your Employee ID',
        html: `
            <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #f8fafc; border-radius: 12px; overflow: hidden; border: 1px solid #e2e8f0;">
                <div style="background: linear-gradient(135deg, #0F3A68 0%, #1a6bc7 100%); padding: 36px 40px; text-align: center;">
                    <h1 style="color: #ffffff; margin: 0; font-size: 26px; letter-spacing: 1px;">Welcome to Pegasos</h1>
                    <p style="color: #bfdbfe; margin: 8px 0 0; font-size: 14px;">Your account is ready</p>
                </div>
                <div style="padding: 36px 40px; background: #ffffff;">
                    <p style="margin: 0 0 16px; font-size: 16px; color: #1e293b;">Hello <strong>${name}</strong>,</p>
                    <p style="color: #475569; font-size: 14px; line-height: 1.6;">Your <strong>${roleLabel}</strong> account has been successfully created on the Pegasos Field Management App.</p>
                    <div style="background: #f0f7ff; border: 2px dashed #1a6bc7; border-radius: 10px; padding: 24px; text-align: center; margin: 24px 0;">
                        <p style="margin: 0 0 4px; font-size: 13px; color: #64748b; text-transform: uppercase; letter-spacing: 1px;">Your Employee ID</p>
                        <p style="margin: 0; font-size: 36px; font-weight: 800; color: #0F3A68; letter-spacing: 6px;">${employeeId}</p>
                    </div>
                    <p style="color: #64748b; font-size: 13px; background: #fefce8; border-left: 4px solid #eab308; padding: 12px 16px; border-radius: 4px; margin: 0 0 24px;">
                        Keep this safe: Your Employee ID is used to log in to the Pegasos app. Never share it with others.
                    </p>
                    <p style="color: #475569; font-size: 14px;">Use the password you set during registration to log in. If you forget your password, use the <strong>Forgot Password</strong> option in the app.</p>
                </div>
                <div style="padding: 20px 40px; background: #f8fafc; border-top: 1px solid #e2e8f0; text-align: center;">
                    <p style="color: #94a3b8; font-size: 12px; margin: 0;">Pegasos Field App &copy; ${new Date().getFullYear()} | This is an automated email, please do not reply.</p>
                </div>
            </div>
        `
    };
    await transporter.sendMail(mailOptions);
};

// ---- Send Manager Assignment Emails (Req Part 2) ----
const sendManagerAssignmentEmails = async (feEmail, feName, managerEmail, managerName) => {
    // 1. Email to Field Executive
    const feMailOptions = {
        from: process.env.EMAIL_FROM,
        to: feEmail,
        subject: 'Manager Assignment Notification',
        html: `
            <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #f8fafc; border-radius: 12px; overflow: hidden; border: 1px solid #e2e8f0;">
                <div style="background: linear-gradient(135deg, #0F3A68 0%, #1a6bc7 100%); padding: 36px 40px; text-align: center;">
                    <h1 style="color: #ffffff; margin: 0; font-size: 26px;">Manager Assigned</h1>
                </div>
                <div style="padding: 36px 40px; background: #ffffff;">
                    <p style="margin: 0 0 16px; font-size: 16px; color: #1e293b;">Hello <strong>${feName}</strong>,</p>
                    <p style="color: #475569; font-size: 14px; line-height: 1.6;">You have been assigned to Manager <strong>${managerName}</strong>.</p>
                    <p style="color: #475569; font-size: 14px; line-height: 1.6;">All reporting and work-related activities should be coordinated through this manager.</p>
                </div>
                <div style="padding: 20px 40px; background: #f8fafc; border-top: 1px solid #e2e8f0; text-align: center;">
                    <p style="color: #94a3b8; font-size: 12px; margin: 0;">Pegasos Field App</p>
                </div>
            </div>
        `
    };

    // 2. Email to Manager
    const managerMailOptions = {
        from: process.env.EMAIL_FROM,
        to: managerEmail,
        subject: 'New Field Executive Assigned',
        html: `
            <div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #f8fafc; border-radius: 12px; overflow: hidden; border: 1px solid #e2e8f0;">
                <div style="background: linear-gradient(135deg, #0F3A68 0%, #1a6bc7 100%); padding: 36px 40px; text-align: center;">
                    <h1 style="color: #ffffff; margin: 0; font-size: 26px;">New Team Member Assigned</h1>
                </div>
                <div style="padding: 36px 40px; background: #ffffff;">
                    <p style="margin: 0 0 16px; font-size: 16px; color: #1e293b;">Hello <strong>${managerName}</strong>,</p>
                    <p style="color: #475569; font-size: 14px; line-height: 1.6;">Field Executive <strong>${feName}</strong> has been assigned under your supervision.</p>
                </div>
                <div style="padding: 20px 40px; background: #f8fafc; border-top: 1px solid #e2e8f0; text-align: center;">
                    <p style="color: #94a3b8; font-size: 12px; margin: 0;">Pegasos Field App</p>
                </div>
            </div>
        `
    };

    try {
        await transporter.sendMail(feMailOptions);
        await transporter.sendMail(managerMailOptions);
    } catch (err) {
        console.error("Error sending assignment emails:", err);
    }
};

module.exports = { sendPasswordResetEmail, sendVisitUpdateEmail, sendNotificationEmail, sendEmployeeIdEmail, sendManagerAssignmentEmails };
