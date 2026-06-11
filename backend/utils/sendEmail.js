const nodemailer = require('nodemailer');

const sendEmail = async (options) => {
  // Create a reusable transporter using default SMTP transport
  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: process.env.SMTP_PORT,
    secure: process.env.SMTP_PORT == 465, 
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

  const mailOptions = {
    from: `"The Curator" <${process.env.SMTP_USER}>`,
    to: options.email,
    subject: options.subject,
    text: options.message,
    html: `<b>${options.message}</b>`, 
  };

  await transporter.sendMail(mailOptions);
};

module.exports = sendEmail;