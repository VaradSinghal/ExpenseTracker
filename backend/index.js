require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

// ✅ Set Default Port
const PORT = process.env.PORT || 8000;

const app = express();

// ✅ Connect to MongoDB
connectDB();

// ✅ Middleware
app.use(cors()); // Allow frontend requests
app.use(express.json()); // Parse JSON body

// ✅ Test Route
app.get('/', (req, res) => {
    res.send("🚀 Server is Up & Running!");
});

// ✅ Import Routes
app.use('/api/auth', require('./routes/authRoutes')); // Connect Auth Routes

// ✅ Start Server
app.listen(PORT, () => {
    console.log(`✅ Server started on port: ${PORT}`);
});
