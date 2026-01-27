const Sale = require('../models/Sale');
const Product = require('../models/Product');

// @desc    Get visual analytics data
// @route   GET /api/reports/analytics
// @access  Private (Admin, Accountant)
const getAnalytics = async (req, res) => {
    try {
        const companyId = req.companyId;
        const branchId = req.branchId;

        // 1. 7-Day Sales Trend
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        const salesTrend = await Sale.aggregate([
            {
                $match: {
                    company: companyId,
                    ...(branchId && { branch: branchId }),
                    createdAt: { $gte: sevenDaysAgo }
                }
            },
            {
                $group: {
                    _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
                    total: { $sum: "$totalAmount" }
                }
            },
            { $sort: { "_id": 1 } }
        ]);

        // 2. Category Distribution (Stock Value weight or count)
        const categoryStats = await Product.aggregate([
            {
                $match: {
                    company: companyId,
                    ...(branchId && { branch: branchId })
                }
            },
            {
                $group: {
                    _id: "$category",
                    count: { $sum: 1 },
                    value: { $sum: { $multiply: ["$price", "$currentStock"] } }
                }
            }
        ]);

        // 3. Top 5 Selling Products (Quantity)
        // This is harder because items are in an array. Unwind required.
        const topProducts = await Sale.aggregate([
            {
                $match: {
                    company: companyId,
                    ...(branchId && { branch: branchId }),
                    createdAt: { $gte: sevenDaysAgo }
                }
            },
            { $unwind: "$items" },
            {
                $group: {
                    _id: "$items.productName",
                    totalQty: { $sum: "$items.quantity" },
                    revenue: { $sum: "$items.total" }
                }
            },
            { $sort: { totalQty: -1 } },
            { $limit: 5 }
        ]);

        res.json({
            salesTrend,
            categoryStats,
            topProducts
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getAnalytics };
