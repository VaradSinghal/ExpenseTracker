const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  bankBalance: { type: Number, default: 1000 }, 
});

module.exports = mongoose.model("User", userSchema);
