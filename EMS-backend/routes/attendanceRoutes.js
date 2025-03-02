const express = require("express");
const { authMiddleware } = require("../middleware/authMiddleware");
const {
  clockIn,
  clockOut,
  getEmployeeAttendance,
  getAllAttendance,
} = require("../controllers/attendanceController");

const router = express.Router();

// ✅ Employee: Clock In
router.post("/clock-in", authMiddleware, clockIn);

// ✅ Employee: Clock Out
router.put("/clock-out/:attendanceId", authMiddleware, clockOut);

// ✅ Employee: Get Own Attendance
router.get("/:employeeId", authMiddleware, getEmployeeAttendance);

// ✅ Admin: View All Attendance Records
router.get("/", authMiddleware, getAllAttendance);

module.exports = router;
