const mongoose = require("mongoose");

const AttendanceSchema = new mongoose.Schema(
  {
    employeeId: {
      type: String, // Changed from ObjectId to String (e.g., "MST1")
      required: true,
    },
    clockIn: {
      type: Date,
      required: true,
    },
    clockOut: {
      type: Date,
    },
    totalHours: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Attendance", AttendanceSchema);
