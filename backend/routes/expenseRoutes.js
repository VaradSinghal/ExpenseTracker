const express = require('express');
const router = express.Router();
const { authenticateUser } = require('../middleware/authMiddleware'); 
const {
    addExpense,
    deleteExpense,
    getRecentExpenses,
    getLast7DaysExpenses,
} = require('../controllers/expenseController');


router.use(authenticateUser);


router.post('/', addExpense);
router.delete('/:id', deleteExpense); 
router.get('/recent', getRecentExpenses); 
router.get('/last7days', getLast7DaysExpenses); 

module.exports = router;