const User = require("../models/User");

const setBankBalance = async (req, res) => {
  try {
    const { bankBalance } = req.body;
    const userId = req.user.userId;

    if (bankBalance < 0) {
      return res.status(400).json({ error: "Bank balance cannot be negative" });
    }

    await User.findByIdAndUpdate(userId, { 
      bankBalance, 
      hasSetBankBalance: true 
    });

    res.json({ message: "Bank balance updated successfully", bankBalance });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Server error" });
  }
};

const getUserInfo = async (req, res) => {
  try {
    const user = await User.findById(req.user.userId);
    if (!user) return res.status(404).json({ error: "User not found" });

    res.json({
      bankBalance: user.bankBalance,
      hasSetBankBalance: user.hasSetBankBalance,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Server error" });
  }
};

module.exports = {
  setBankBalance,
  getUserInfo
};
