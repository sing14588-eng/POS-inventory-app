const Sale = require('../models/Sale');

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
            createdAt: { $gte: startOfDay, $lte: endOfDay }
        });

        const totalSales = sales.reduce((acc, sale) => acc + sale.totalAmount, 0);
        const totalVAT = sales.reduce((acc, sale) => acc + sale.vatAmount, 0);
        const creditSales = sales.filter(s => s.isCredit).reduce((acc, sale) => acc + sale.totalAmount, 0);

        // Return summary and can also return list if needed
        res.json({
            date: startOfDay.toDateString(),
            totalSales,
            totalVAT,
            creditSales,
            transactionCount: sales.length,
            sales: sales // Detailed list for table view
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getDailyReport };
