const nodemailer = require("nodemailer");

// 1. Configure the email transporter using explicit host/port configs to bypass cloud firewalls
const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 587,
  secure: false,
  auth: {
    user: process.env.EMAIL_USER, // Your Gmail address
    pass: process.env.EMAIL_PASS, // Your Gmail App Password
  },
});

/**
 * Dispatches an automated system email
 * @param {Object} options
 * @param {string} options.email - Recipient address
 * @param {string} options.subject - Subject line text
 * @param {string} options.message - Text-fallback content or structural layout text
 */
const sendEmail = async ({ email, subject, message }) => {
  try {
    await transporter.sendMail({
      from: `"The Curator" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: subject,
      text: message,
    });

    console.log(`📧 Real verification email safely dispatched to: ${email}`);
  } catch (error) {
    console.error("❌ NODEMAILER EMAIL DELIVERY CRASH:", error);
    throw error;
  }
};

module.exports = sendEmail;
