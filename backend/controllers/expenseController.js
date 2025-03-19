import Expense from "../models/Expense.js";
import User from "../models/User.js";

export const addExpense = async (req, res) => {
    try {
        const { title, amount } = req.body;
        const userId = req.userId;  // Extracted from middleware

        const expense = new Expense({ userId, title, amount });
        await expense.save();

        // Deduct from bank balance
        const user = await User.findById(userId);
        user.bankBalance -= amount;
        await user.save();

        res.status(201).json(expense);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
