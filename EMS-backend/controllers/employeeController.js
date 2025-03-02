const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const Employee = require("../models/Employee");
require("dotenv").config();

/**
 * ✅ **Register Employee**
 * @route POST /api/employees/register
 * @access Public
 */
const registerEmployee = async (req, res) => {
  try {
    const { name, phone, password } = req.body;
    if (!name || !phone || !password) {
      return res.status(400).json({ success: false, message: "❌ All fields are required" });
    }

    const existingEmployee = await Employee.findOne({ phone });
    if (existingEmployee) {
      return res.status(400).json({ success: false, message: "❌ Phone number already registered" });
    }

    const lastEmployee = await Employee.findOne().sort({ createdAt: -1 });
    const lastIdNumber = lastEmployee ? parseInt(lastEmployee.employeeId.replace("MST", "")) : 0;
    const newEmployeeId = `MST${lastIdNumber + 1}`;

    const hashedPassword = await bcrypt.hash(password, 12);

    const newEmployee = new Employee({
      employeeId: newEmployeeId,
      name,
      phone,
      password: hashedPassword,
    });

    await newEmployee.save();
    res.status(201).json({
      success: true,
      message: "✅ Employee registered successfully",
      employee: { employeeId: newEmployeeId, name, phone },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: "❌ Employee registration failed", error: error.message });
  }
};

/**
 * ✅ **Employee Login**
 * @route POST /api/employees/login
 * @access Public
 */
const loginEmployee = async (req, res) => {
  try {
    const { phone, password } = req.body;

    if (!phone || !password) {
      return res.status(400).json({ success: false, message: "❌ All fields are required" });
    }

    const employee = await Employee.findOne({ phone });
    if (!employee) {
      return res.status(400).json({ success: false, message: "❌ Employee not found" });
    }

    const isMatch = await bcrypt.compare(password, employee.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: "❌ Invalid credentials" });
    }

    const token = jwt.sign(
      { id: employee._id, employeeId: employee.employeeId, role: "employee" },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    // ✅ Ensure name is correctly retrieved from employee object
    res.status(200).json({
      success: true,
      message: "✅ Login successful",
      token,
      employee: { employeeId: employee.employeeId, name: employee.name, phone: employee.phone },
    });
  } catch (error) {
    console.error("❌ Login Error:", error);
    res.status(500).json({ success: false, message: "❌ Login failed", error: error.message });
  }
};


/**
 * ✅ **Get Employee Profile**
 * @route GET /api/employees/profile
 * @access Private (Employee Only)
 */
const getEmployeeProfile = async (req, res) => {
  try {
    const employee = await Employee.findOne({ employeeId: req.user.employeeId }).select("-password");
    if (!employee) {
      return res.status(404).json({ success: false, message: "❌ Employee not found" });
    }
    res.json({ success: true, employee });
  } catch (error) {
    res.status(500).json({ success: false, message: "❌ Failed to fetch profile", error: error.message });
  }
};

/**
 * ✅ **Admin: Get All Employees**
 * @route GET /api/employees
 * @access Private (Admin Only)
 */
const getAllEmployees = async (req, res) => {
  try {
    const employees = await Employee.find().select("-password");
    res.json({ success: true, employees });
  } catch (error) {
    res.status(500).json({ success: false, message: "❌ Failed to fetch employees", error: error.message });
  }
};

/**
 * ✅ **Admin: Get Employee by ID**
 * @route GET /api/employees/:employeeId
 * @access Private (Admin Only)
 */
const getEmployeeById = async (req, res) => {
  try {
    const employee = await Employee.findOne({ employeeId: req.params.employeeId }).select("-password");
    if (!employee) return res.status(404).json({ success: false, message: "Employee not found" });
    res.json({ success: true, employee });
  } catch (error) {
    res.status(500).json({ success: false, message: "❌ Failed to fetch employee", error: error.message });
  }
};

/**
 * ✅ **Admin: Update Employee Details**
 * @route PUT /api/employees/update/:employeeId
 * @access Private (Admin Only)
 */
const adminUpdateEmployee = async (req, res) => {
  try {
    const { employeeId } = req.params;
    const { name, phone } = req.body;

    const employee = await Employee.findOne({ employeeId });
    if (!employee) return res.status(404).json({ success: false, message: "Employee not found" });

    employee.name = name || employee.name;
    employee.phone = phone || employee.phone;
    await employee.save();

    res.json({ success: true, message: "Employee updated successfully", employee });
  } catch (error) {
    res.status(500).json({ success: false, message: "❌ Error updating employee", error: error.message });
  }
};

/**
 * ✅ **Admin: Delete Employee**
 * @route DELETE /api/employees/delete/:employeeId
 * @access Private (Admin Only)
 */
const adminDeleteEmployee = async (req, res) => {
  try {
    await Employee.deleteOne({ employeeId: req.params.employeeId });
    res.json({ success: true, message: "✅ Employee deleted successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "❌ Error deleting employee", error: error.message });
  }
};

/**
 * ✅ **Admin: Reset Employee Password**
 * @route POST /api/employees/reset-password/:employeeId
 * @access Private (Admin Only)
 */
const adminResetEmployeePassword = async (req, res) => {
  try {
    const { employeeId } = req.params;
    const { newPassword } = req.body;

    if (!newPassword || newPassword.length < 6) return res.status(400).json({ success: false, message: "❌ Password must be at least 6 characters" });

    const employee = await Employee.findOne({ employeeId });
    if (!employee) return res.status(404).json({ success: false, message: "Employee not found" });

    const hashedPassword = await bcrypt.hash(newPassword, 12);
    employee.password = hashedPassword;
    await employee.save();

    res.json({ success: true, message: "✅ Employee password reset successfully" });
  } catch (error) {
    res.status(500).json({ success: false, message: "❌ Error resetting password", error: error.message });
  }
};

// ✅ Export All Functions
module.exports = {
  registerEmployee,
  loginEmployee,
  getEmployeeProfile,
  getAllEmployees,
  getEmployeeById,
  adminUpdateEmployee,
  adminDeleteEmployee,
  adminResetEmployeePassword,
};
