const mongoose = require('mongoose')

const connectDB = async () => {

    try {
        mongoose.connect(process.env.MONGO_URL)
        console.log("DB connected");
        
    } catch (error) {
        console.log("error", error);
        
        
    }
}
module.exports = connectDB