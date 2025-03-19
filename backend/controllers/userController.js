const User = require("../models/User");

exports.setBankBalance = async (req, res) => {
  try {
    const { bankBalance } = req.body;
    const userId = req.user.userId; 

    if (bankBalance < 0) {
      return res.status(400).json({ error: "Bank balance cannot be negative" });
    }

    await User.findByIdAndUpdate(userId, { bankBalance });

    res.json({ message: "Bank balance updated successfully", bankBalance });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Server error" });
  }
};
