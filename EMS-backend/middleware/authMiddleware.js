const jwt = require("jsonwebtoken");
require("dotenv").config();

/**
 * ✅ **Middleware to Authenticate All Users (Employee & Admin)**
 * Ensures token is valid and extracts user information.
 */
exports.authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.header("Authorization");

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ success: false, message: "No token provided or invalid format" });
    }

    const token = authHeader.replace("Bearer ", "").trim();
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    if (!decoded.id || !decoded.role) {
      return res.status(400).json({ success: false, message: "Invalid token: Missing user data" });
    }

    req.user = decoded; // Attach user info to the request object
    console.log(`🔹 Authenticated User: ${decoded.employeeId || decoded.adminId} - Role: ${decoded.role}`);
    next();
  } catch (error) {
    console.error("❌ Authentication Error:", error.message);
    return res.status(401).json({ success: false, message: "Invalid or expired token" });
  }
};

/**
 * ✅ **Middleware for Admin Authorization Only**
 * Ensures the user is authenticated and has the `admin` role.
 */
exports.adminAuthMiddleware = (req, res, next) => {
  try {
    const authHeader = req.header("Authorization");

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ success: false, message: "No token provided or invalid format" });
    }

    const token = authHeader.replace("Bearer ", "").trim();
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    if (!decoded.id || decoded.role !== "admin") {
      return res.status(403).json({ success: false, message: "Access denied. Admins only" });
    }

    req.user = decoded; // Attach user info to request object
    console.log(`🔹 Admin Authenticated: ${decoded.adminId}`);
    next();
  } catch (error) {
    console.error("❌ Admin Authentication Error:", error.message);
    return res.status(401).json({ success: false, message: "Invalid or expired token" });
  }
};
