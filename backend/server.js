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

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);

    console.log('--- Available Network Interfaces ---');
    const { networkInterfaces } = require('os');
    const nets = networkInterfaces();
    for (const name of Object.keys(nets)) {
        for (const net of nets[name]) {
            // Skip over non-IPv4 and internal (i.e. 127.0.0.1) addresses
            if (net.family === 'IPv4' && !net.internal) {
                console.log(`Interface: ${name} -> IP: ${net.address}`);
            }
        }
    }
    console.log('------------------------------------');
});
