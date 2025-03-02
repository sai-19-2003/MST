const express = require("express");
const { register, login, forgotPassword } = require("../controllers/authController");

const router = express.Router();

// ✅ Register a new user (Admin or Employee)
router.post("/register", register);

// ✅ User login (Admin or Employee)
router.post("/login", login);

// ✅ Forgot Password Route
router.post("/forgot-password", forgotPassword);

module.exports = router;
