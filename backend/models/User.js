const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  bankBalance: { type: Number, default: 0 },
  hasSetBankBalance: { type: Boolean, default: false }, // Track if balance is set
});

module.exports = mongoose.model("User", userSchema);
