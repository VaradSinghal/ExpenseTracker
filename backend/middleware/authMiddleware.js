const jwt = require("jsonwebtoken");
const cors = require("cors");

const authenticateUser = (req, res, next) => {
    const authHeader = req.header("Authorization");

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ error: "Access Denied: No Token Provided" });
    }

    const token = authHeader.split(" ")[1]; 

    try {
        const verified = jwt.verify(token, process.env.JWT_SECRET);
        req.user = verified; 
        console.log("Decoded user:", verified);
        next();
    } catch (error) {
        res.status(400).json({ error: "Invalid Token" });
    }
};

const errorHandler = (err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: err.message || "Internal Server Error" });
};

const corsOptions = {
    origin: "*", 
    methods: "GET,POST,PUT,DELETE",
    allowedHeaders: "Content-Type,Authorization",
};

module.exports = {
    authenticateUser,
    errorHandler,
    corsMiddleware: cors(corsOptions),
};