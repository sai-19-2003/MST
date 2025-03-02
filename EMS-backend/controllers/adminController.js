const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const Admin = require("../models/Admin");
require("dotenv").config(); // Ensure dotenv is loaded

// ✅ **Admin Registration**
exports.registerAdmin = async (req, res) => {
  try {
    const { name, phone, password } = req.body;

    // 🔹 Check if all required fields are provided
    if (!name || !phone || !password) {
      return res.status(400).json({ success: false, message: "All fields are required" });
    }

    // 🔹 Check if phone number already exists
    const existingAdmin = await Admin.findOne({ phone });
    if (existingAdmin) {
      return res.status(400).json({ success: false, message: "Phone number already registered" });
    }

    // 🔹 Hash Password
    const hashedPassword = await bcrypt.hash(password, 10);

    // 🔹 Create New Admin
    const newAdmin = new Admin({
      name,
      phone,
      password: hashedPassword,
    });

    await newAdmin.save();

    res.status(201).json({
      success: true,
      message: "Admin registered successfully",
    });
  } catch (error) {
    console.error("❌ Registration error:", error);
    res.status(500).json({ success: false, message: "Admin registration failed", error: error.message });
  }
};

// ✅ **Admin Login**
exports.loginAdmin = async (req, res) => {
  try {
    const { phone, password } = req.body;

    // 🔹 Check if all required fields are provided
    if (!phone || !password) {
      return res.status(400).json({ success: false, message: "All fields are required" });
    }

    // 🔹 Check if admin exists
    const admin = await Admin.findOne({ phone });
    if (!admin) {
      return res.status(400).json({ success: false, message: "Admin not found" });
    }

    // 🔹 Validate password
    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: "Invalid credentials" });
    }

    // 🔹 Generate JWT Token
    const token = jwt.sign(
      { id: admin._id, role: "admin" },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    // 🔹 Send response with token and admin details
    res.status(200).json({
      success: true,
      message: "Login successful",
      token,
      admin: {
        name: admin.name,
        phone: admin.phone,
      },
    });
  } catch (error) {
    console.error("❌ Login error:", error);
    res.status(500).json({ success: false, message: "Login failed", error: error.message });
  }
};
