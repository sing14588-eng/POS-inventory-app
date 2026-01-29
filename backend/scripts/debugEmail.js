const nodemailer = require('nodemailer');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../.env') });

const debugEmail = async () => {
    console.log('--- SMTP Debug ---');
    console.log('Host:', process.env.EMAIL_HOST);
    console.log('Port:', process.env.EMAIL_PORT);
    console.log('Secure:', process.env.EMAIL_SECURE);
    console.log('User:', process.env.EMAIL_USER);
    // password is omitted for security in logs

    const transporter = nodemailer.createTransport({
        host: process.env.EMAIL_HOST,
        port: parseInt(process.env.EMAIL_PORT),
        secure: process.env.EMAIL_SECURE === 'true',
        auth: {
            user: process.env.EMAIL_USER,
            pass: process.env.EMAIL_PASSWORD,
        },
        debug: true, // show debug output
        logger: true // log to console
    });

    try {
        console.log('Verifying connection...');
        const success = await transporter.verify();
        if (success) {
            console.log('✅ Connection verified successfully!');

            const mailOptions = {
                from: `${process.env.EMAIL_FROM} <${process.env.EMAIL_USER}>`,
                to: 'singsongadisu@gmail.com',
                subject: '🔍 FlowPos Debug Test',
                text: 'This is a debug email to verify connection and auth.'
            };

            console.log('Sending test email...');
            const info = await transporter.sendMail(mailOptions);
            console.log('✅ Email sent successfully!');
            console.log('Message ID:', info.messageId);
        }
    } catch (error) {
        console.error('❌ Debug Error:', error);
    }
};

debugEmail();
