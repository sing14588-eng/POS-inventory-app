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

module.exports = { getDailyReport, getGlobalStats };
