const Sale = require('../models/Sale');
const Company = require('../models/Company');
const Product = require('../models/Product');
const User = require('../models/User');

// @desc    Get daily sales report
// @route   GET /api/reports/daily
// @access  Private (Accountant)
const getDailyReport = async (req, res) => {
    try {
        const startOfDay = new Date();
        startOfDay.setHours(0, 0, 0, 0);

        const endOfDay = new Date();
        endOfDay.setHours(23, 59, 59, 999);

        const sales = await Sale.find({
            company: req.companyId,
            createdAt: { $gte: startOfDay, $lte: endOfDay }
        });

        const totalSales = sales.reduce((acc, sale) => acc + sale.totalAmount, 0);
        const totalVAT = sales.reduce((acc, sale) => acc + sale.vatAmount, 0);
        const creditSales = sales.filter(s => s.isCredit).reduce((acc, sale) => acc + sale.totalAmount, 0);

        res.json({
            date: startOfDay.toDateString(),
            totalSales,
            totalVAT,
            creditSales,
            transactionCount: sales.length,
            sales: sales
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getGlobalStats = async (req, res) => {
    try {
        const companyCount = await Company.countDocuments();
        const productCount = await Product.countDocuments();
        const userCount = await User.countDocuments();

        const allSales = await Sale.find({});
        const totalRevenue = allSales.reduce((acc, s) => acc + s.totalAmount, 0);

        res.json({
            companyCount,
            productCount,
            userCount,
            totalRevenue,
            transactionCount: allSales.length
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getShopAdminStats = async (req, res) => {
    try {
        const startOfDay = new Date();
        startOfDay.setHours(0, 0, 0, 0);

        const startOfMonth = new Date();
        startOfMonth.setDate(1);
        startOfMonth.setHours(0, 0, 0, 0);

        // Fetch Today's Sales
        const todaySales = await Sale.find({
            company: req.companyId,
            createdAt: { $gte: startOfDay }
        });
        const totalToday = todaySales.reduce((acc, s) => acc + s.totalAmount, 0);

        // Fetch This Month's Sales
        const monthSales = await Sale.find({
            company: req.companyId,
            createdAt: { $gte: startOfMonth }
        });
        const totalMonth = monthSales.reduce((acc, s) => acc + s.totalAmount, 0);

        // Fetch Low Stock Count
        // For MVP, we'll check global currentStock vs minStockLevel or branch-based if possible.
        // Given Product.js was just updated, let's use the new minStockLevel.
        const lowStockProducts = await Product.find({
            company: req.companyId,
            $expr: { $lte: ["$currentStock", "$minStockLevel"] }
        });

        // Fetch Active Branches
        const Branch = require('../models/Branch');
        const activeBranches = await Branch.countDocuments({
            company: req.companyId,
            status: true
        });

        // Fetch Top Selling Product Today
        let topProduct = "None";
        if (todaySales.length > 0) {
            const productCounts = {};
            todaySales.forEach(sale => {
                sale.items.forEach(item => {
                    productCounts[item.name] = (productCounts[item.name] || 0) + item.quantity;
                });
            });
            const sorted = Object.entries(productCounts).sort((a, b) => b[1] - a[1]);
            if (sorted.length > 0) topProduct = sorted[0][0];
        }

        res.json({
            todaySales: totalToday,
            monthSales: totalMonth,
            lowStockCount: lowStockProducts.length,
            activeBranches,
            topProduct
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getDailyReport, getGlobalStats, getShopAdminStats };
