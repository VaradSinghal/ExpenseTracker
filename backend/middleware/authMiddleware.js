const jwt = require("jsonwebtoken");

// Authentication Middleware (Protects Routes)
const authenticateUser = (req, res, next) => {
  const token = req.header("Authorization");

  if (!token) {
    return res.status(401).json({ error: "Access Denied: No Token Provided" });
  }

  try {
    const verified = jwt.verify(token, process.env.JWT_SECRET); // Verify JWT
    req.user = verified; // Add user details to request
    next();
  } catch (error) {
    res.status(400).json({ error: "Invalid Token" });
  }
};

// Global Error Handling Middleware
const errorHandler = (err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: err.message || "Internal Server Error" });
};

// CORS Middleware (Allows Frontend Requests)
const cors = require("cors");

const corsOptions = {
  origin: "*", // Change to your Flutter app's domain for security
  methods: "GET,POST,PUT,DELETE",
  allowedHeaders: "Content-Type,Authorization",
};

module.exports = {
  authenticateUser,
  errorHandler,
  corsMiddleware: cors(corsOptions),
};
