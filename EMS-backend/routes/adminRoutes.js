const express = require("express");
const { registerAdmin, loginAdmin } = require("../controllers/adminController");
const {
  getAllAttendance,
  markAttendance,
  exportAttendance
} = require("../controllers/attendanceController"); // ✅ Import attendance controllers
const { authMiddleware, adminAuthMiddleware } = require("../middleware/authMiddleware");

const router = express.Router();

/**
 * ✅ **Admin Registration**
 * @route   POST /api/admin/register
 * @access  Public
 */
router.post("/register", registerAdmin);

/**
 * ✅ **Admin Login**
 * @route   POST /api/admin/login
 * @access  Public
 */
router.post("/login", loginAdmin);

/**
 * ✅ **Admin Dashboard (Protected)**
 * @route   GET /api/admin/dashboard
 * @access  Private (Admin Only)
 */
router.get("/dashboard", adminAuthMiddleware, (req, res) => {
  res.json({ success: true, message: "Welcome to Admin Dashboard", user: req.user });
});

/**
 * ✅ **Get All Attendance Records with Filters**
 * @route   GET /api/admin/attendance
 * @query   employeeId, startDate, endDate, sortBy
 * @access  Private (Admin Only)
 */
router.get("/attendance", adminAuthMiddleware, getAllAttendance);

/**
 * ✅ **Manually Mark Employee Attendance**
 * @route   POST /api/admin/mark-attendance
 * @body    { employeeId, clockInTime, clockOutTime (optional) }
 * @access  Private (Admin Only)
 */
router.post("/mark-attendance", adminAuthMiddleware, markAttendance);

/**
 * ✅ **Export Attendance Report as CSV**
 * @route   GET /api/admin/export-attendance
 * @access  Private (Admin Only)
 */
router.get("/export-attendance", adminAuthMiddleware, exportAttendance);

module.exports = router;
