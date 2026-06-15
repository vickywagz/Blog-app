const nodemailer = require("nodemailer");
const dns = require("dns");

// 1. Configure the transporter to explicitly force IPv4 lookups
const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 587,
  secure: false, // Must be false for Port 587
  // 🟢 FORCES IPv4: Tells Node's DNS resolver to skip IPv6 resolution completely
  lookup: (hostname, options, callback) => {
    dns.lookup(hostname, { family: 4 }, (err, address, family) => {
      callback(err, address, family);
    });
  },
  auth: {
    user: process.env.EMAIL_USER, 
    pass: process.env.EMAIL_PASS, 
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