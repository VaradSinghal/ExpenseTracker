const express = require("express");
const { setBankBalance } = require("../controllers/userController");
const authMiddleware = require("../middleware/authMiddleware"); 

const router = express.Router();

router.put("/set-bank-balance", authMiddleware, setBankBalance);

module.exports = router;
