require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

const PORT = process.env.PORT || 8000;

const app = express();


connectDB();

app.use(cors()); 
app.use(express.json()); 


app.get('/', (req, res) => {
    res.send("🚀 Server is Up & Running!");
});


app.use('/api/auth', require('./routes/authRoutes')); 
app.use('/api/user',require('./routes/userRoutes'))
app.use('/api/expenses', require('./routes/expenseRoutes'));
app.listen(PORT, () => {
    console.log(`✅ Server started on port: ${PORT}`);
});
