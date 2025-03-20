const Expense = require("../models/Expense.js");
const User = require("../models/User.js");

const addExpense = async (req, res) => {
    try {
        const { title, amount } = req.body;
        const userId = req.user.userId;

        if (!userId) {
            return res.status(400).json({ error: "UserId is missing in the token" });
        }

        if (typeof amount !== "number" || amount < 0) {
            return res.status(400).json({ error: "Invalid amount" });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        if (user.bankBalance < amount) {
            return res.status(400).json({ error: "Insufficient bank balance" });
        }

        const expense = new Expense({ userId, title, amount, timestamp: new Date() });
        await expense.save();

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
        const userId = req.user.userId;

        const expense = await Expense.findOne({ _id: id, userId });
        if (!expense) {
            return res.status(404).json({ error: "Expense not found" });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

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
        const userId = req.user.userId;
        const { page = 1, limit = 10 } = req.query;

        const startOfDay = new Date();
        startOfDay.setHours(0, 0, 0, 0);

        const endOfDay = new Date();
        endOfDay.setHours(23, 59, 59, 999);

        const expenses = await Expense.find({
            userId,
            timestamp: { $gte: startOfDay, $lte: endOfDay },
        })
            .sort({ timestamp: -1 })
            .limit(limit * 1)
            .skip((page - 1) * limit);

        res.status(200).json(expenses);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const getLast7DaysExpenses = async (req, res) => {
    try {
        const userId = req.user.userId;
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