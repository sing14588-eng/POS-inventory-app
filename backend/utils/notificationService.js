const Notification = require('../models/Notification');

const sendNotification = async ({ company, branch, user, roles, title, message, type, data }) => {
    try {
        await Notification.create({
            company,
            branch,
            user,
            roles,
            title,
            message,
            type,
            data
        });
        // Note: If we had Socket.io, we would emit the event here for real-time update
    } catch (error) {
        console.error('Notification Error:', error);
    }
};

module.exports = { sendNotification };
