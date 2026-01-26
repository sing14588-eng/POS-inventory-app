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

app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/sales', saleRoutes);
app.use('/api/picker', require('./routes/pickerRoutes'));
app.use('/api/restock', require('./routes/restockRoutes'));
app.use('/api/reports', reportRoutes);
app.use('/api/users', require('./routes/userRoutes'));

app.get('/', (req, res) => {
    res.send('POS Backend is running');
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
