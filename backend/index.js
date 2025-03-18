require('dotenv').config()
const express = require('express')
const connectDB = require('./db/connection')

const PORT = process.eventNames.PORT || 8000;

const app = express()

connectDB()

app.get('/', (req,res)=>{
    res.send("Server is Up")
})

app.listen(PORT, ()=>{
    console.log("Server started at port:", PORT);
    
})