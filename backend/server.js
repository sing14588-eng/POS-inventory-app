const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');

const authRoutes = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const saleRoutes = require('./routes/saleRoutes');
const pickerRoutes = require('./routes/pickerRoutes');
const reportRoutes = require('./routes/reportRoutes');

dotenv.config();

connectDB();

const app = express();

app.use(cors());
app.use(express.json());

// Request logger middleware
app.use((req, res, next) => {
    console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.url}`);
    next();
});

app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/sales', saleRoutes);
app.use('/api/picker', require('./routes/pickerRoutes'));
app.use('/api/restock', require('./routes/restockRoutes'));
app.use('/api/reports', reportRoutes);
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/companies', require('./routes/companyRoutes'));
app.use('/api/branches', require('./routes/branchRoutes'));
app.use('/api/audit', require('./routes/auditRoutes'));
app.use('/api/inventory', require('./routes/inventoryRoutes'));
app.use('/api/notifications', require('./routes/notificationRoutes'));

app.get('/', (req, res) => {
    res.send('POS Backend is running');
});

const path = require('path');
const fs = require('fs');

const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir);
}

app.use('/api/upload', require('./routes/uploadRoutes'));
app.use('/uploads', express.static(uploadsDir));

// Error Handling Middleware
app.use((err, req, res, next) => {
    console.error(`[Global Error Handler] ${err.stack || err}`);
    res.status(err.status || 500).json({
        message: err.message || 'Something went wrong on the server!'
    });
});

const PORT = process.env.PORT || 5050;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
