const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const Employee = require("../models/Employee");
const Admin = require("../models/Admin");

// ✅ Register User (Admin or Employee)
exports.register = async (req, res) => {
  try {
    const { name, phone, password, role } = req.body;

    if (!name || !phone || !password || !role) {
      return res.status(400).json({ success: false, message: "All fields are required" });
    }

    // Check if phone is already registered
    const existingUser = await (role === "admin" ? Admin : Employee).findOne({ phone });
    if (existingUser) {
      return res.status(400).json({ success: false, message: "Phone number already registered" });
    }

    // Hash Password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Save new user
    const newUser = new (role === "admin" ? Admin : Employee)({
      name,
      phone,
      password: hashedPassword,
    });

    await newUser.save();

    res.status(201).json({ success: true, message: "Registration successful" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Registration failed", error: error.message });
  }
};

// ✅ Login User (Admin or Employee)
exports.login = async (req, res) => {
  try {
    const { phone, password, role } = req.body;

    if (!phone || !password || !role) {
      return res.status(400).json({ success: false, message: "All fields are required" });
    }

    const user = await (role === "admin" ? Admin : Employee).findOne({ phone });
    if (!user) {
      return res.status(400).json({ success: false, message: "User not found" });
    }

    // Validate password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: "Invalid credentials" });
    }

    // Generate JWT Token
    const token = jwt.sign(
      { id: user._id, role },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.status(200).json({ success: true, message: "Login successful", token });
  } catch (error) {
    res.status(500).json({ success: false, message: "Login failed", error: error.message });
  }
};

// ✅ Forgot Password
exports.forgotPassword = async (req, res) => {
  try {
    const { phone, newPassword, role } = req.body;

    if (!phone || !newPassword || !role) {
      return res.status(400).json({ success: false, message: "All fields are required" });
    }

    const user = await (role === "admin" ? Admin : Employee).findOne({ phone });
    if (!user) {
      return res.status(400).json({ success: false, message: "User not found" });
    }

    // Hash new password and update
    user.password = await bcrypt.hash(newPassword, 10);
    await user.save();

    res.status(200).json({ success: true, message: "Password reset successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "Password reset failed", error: error.message });
  }
};
