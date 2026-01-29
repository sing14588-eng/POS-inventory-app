const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');
const connectDB = require('./config/db');

dotenv.config();
connectDB();

const seedAdmin = async () => {
    try {
        await User.deleteMany({ email: 'admin@test.com' }); // Clean up if exists

        const adminUser = await User.create({
            name: 'Admin User',
            email: 'admin@test.com',
            password: '123456',
            roles: ['admin'] // Changed to roles array
        });

        const superAdmin = await User.create({
            name: 'Super Admin',
            email: 'singsongadisu@gmail.com',
            password: '123456',
            roles: ['super_admin']
        });

        console.log('Admin User Created:', adminUser.email);
        console.log('Super Admin Created:', superAdmin.email);
        process.exit();
    } catch (error) {
        console.error('Error seeding admin:', error);
        process.exit(1);
    }
};

seedAdmin();
