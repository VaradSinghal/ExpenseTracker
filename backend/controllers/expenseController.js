const Expense = require("../models/Expense.js");
const User = require("../models/User.js");

const addExpense = async (req, res) => {
    try {
        const { title, amount } = req.body;
        const userId = req.userId;

        const expense = new Expense({ userId, title, amount });
        await expense.save();

        const user = await User.findById(userId);
        user.bankBalance -= amount;
        await user.save();

        res.status(201).json(expense);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const deleteExpense = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.userId;

        const expense = await Expense.findOne({ _id: id, userId });
        if (!expense) {
            return res.status(404).json({ error: "Expense not found" });
        }

        const user = await User.findById(userId);
        user.bankBalance += expense.amount;
        await user.save();

        await Expense.deleteOne({ _id: id, userId });
        res.status(200).json({ message: "Expense deleted successfully" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const getRecentExpenses = async (req, res) => {
    try {
        const userId = req.userId;

        const startOfDay = new Date();
        startOfDay.setHours(0, 0, 0, 0);

        const endOfDay = new Date();
        endOfDay.setHours(23, 59, 59, 999);

        const expenses = await Expense.find({
            userId,
            timestamp: { $gte: startOfDay, $lte: endOfDay },
        }).sort({ timestamp: -1 });

        res.status(200).json(expenses);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const getLast7DaysExpenses = async (req, res) => {
    try {
        const userId = req.userId;
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        const expenses = await Expense.find({
            userId,
            timestamp: { $gte: sevenDaysAgo },
        }).sort({ timestamp: -1 });

        res.status(200).json(expenses);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

module.exports = {
    addExpense,
    deleteExpense,
    getRecentExpenses,
    getLast7DaysExpenses,
};