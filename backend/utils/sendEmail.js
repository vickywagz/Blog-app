const nodemailer = require("nodemailer");

// 1. Configure the email transporter using environment variables
const transporter = nodemailer.createTransport({
  service: "gmail",
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
      to: email, // 🟢 Maps to the parameter key your controller expects
      subject: subject,
      text: message, // Standard text mode
      // Optional: If you want to use rich HTML templates later, uncomment below:
      // html: `<p>${message}</p>`, 
    });

    console.log(`📧 Real verification email safely dispatched to: ${email}`);
  } catch (error) {
    console.error("❌ NODEMAILER EMAIL DELIVERY CRASH:", error);
    throw error; // Rethrow so your controller catch block can capture failures
  }
};

module.exports = sendEmail;