const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Company = require('../models/Company');
const User = require('../models/User');
const Product = require('../models/Product');
const Sale = require('../models/Sale');
const RestockRequest = require('../models/RestockRequest');
const Branch = require('../models/Branch');

dotenv.config();

const migrate = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('MongoDB Connected for Migration...');

        // 1. Create Default Company
        let defaultCompany = await Company.findOne({ name: 'Default POS Shop' });
        if (!defaultCompany) {
            defaultCompany = await Company.create({
                name: 'Default POS Shop',
                email: 'main@pos.com',
                plan: 'premium',
                primaryColor: '#6C63FF',
                currencySymbol: '$'
            });
            console.log('Created Default Company:', defaultCompany._id);
        }

        // 2. Update Users (excluding super_admin)
        const userResult = await User.updateMany(
            { company: { $exists: false }, roles: { $ne: 'super_admin' } },
            { $set: { company: defaultCompany._id } }
        );
        console.log(`Updated ${userResult.modifiedCount} users.`);

        // 3. Update Products
        const productResult = await Product.updateMany(
            { company: { $exists: false } },
            { $set: { company: defaultCompany._id } }
        );
        console.log(`Updated ${productResult.modifiedCount} products.`);

        // 4. Update Sales
        const saleResult = await Sale.updateMany(
            { company: { $exists: false } },
            { $set: { company: defaultCompany._id } }
        );
        console.log(`Updated ${saleResult.modifiedCount} sales.`);

        // 5. Update Restock Requests
        const restockResult = await RestockRequest.updateMany(
            { company: { $exists: false } },
            { $set: { company: defaultCompany._id } }
        );
        console.log(`Updated ${restockResult.modifiedCount} restock requests.`);

        // 6. Branch Migration
        const companies = await Company.find({});
        for (const comp of companies) {
            let mainBranch = await Branch.findOne({ company: comp._id, name: 'Main Branch' });
            if (!mainBranch) {
                mainBranch = await Branch.create({
                    company: comp._id,
                    name: 'Main Branch',
                    address: comp.address || 'Central Headquarters'
                });
                console.log(`Created Main Branch for ${comp.name}: ${mainBranch._id}`);
            }

            // Move data to this branch if it has none
            await User.updateMany(
                { company: comp._id, branch: { $exists: false }, roles: { $ne: 'super_admin' } },
                { $set: { branch: mainBranch._id } }
            );
            await Product.updateMany(
                { company: comp._id, branch: { $exists: false } },
                { $set: { branch: mainBranch._id } }
            );
            await Sale.updateMany(
                { company: comp._id, branch: { $exists: false } },
                { $set: { branch: mainBranch._id } }
            );
            await RestockRequest.updateMany(
                { company: comp._id, branch: { $exists: false } },
                { $set: { branch: mainBranch._id } }
            );
        }

        console.log('Migration Completed Successfully!');
        process.exit();
    } catch (error) {
        console.error('Migration Failed:', error);
        process.exit(1);
    }
};

migrate();
