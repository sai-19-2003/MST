const Attendance = require("../models/Attendance");
const Employee = require("../models/Employee");
const { Parser } = require("json2csv"); // ✅ For CSV Export

/**
 * ✅ **Clock In**
 * @route   POST /api/attendance/clock-in
 * @access  Private (Employee)
 */
exports.clockIn = async (req, res) => {
  try {
    const { employeeId } = req.body;

    if (!employeeId) {
      return res.status(400).json({ success: false, message: "Employee ID is required" });
    }

    const existingAttendance = await Attendance.findOne({ employeeId, clockOut: null });

    if (existingAttendance) {
      return res.status(400).json({ success: false, message: "You have already clocked in" });
    }

    const newAttendance = new Attendance({ employeeId, clockIn: new Date() });
    await newAttendance.save();

    res.status(201).json({ success: true, message: "Clock-in successful", attendance: newAttendance });
  } catch (error) {
    res.status(500).json({ success: false, message: "Clock-in failed", error: error.message });
  }
};

/**
 * ✅ **Clock Out**
 * @route   POST /api/attendance/clock-out/:attendanceId
 * @access  Private (Employee)
 */
exports.clockOut = async (req, res) => {
  try {
    const { attendanceId } = req.params;

    const attendance = await Attendance.findById(attendanceId);
    if (!attendance) {
      return res.status(404).json({ success: false, message: "Attendance record not found" });
    }

    if (attendance.clockOut) {
      return res.status(400).json({ success: false, message: "You have already clocked out" });
    }

    attendance.clockOut = new Date();
    attendance.totalHours = (attendance.clockOut - attendance.clockIn) / (1000 * 60 * 60); // Convert to hours

    await attendance.save();
    res.status(200).json({ success: true, message: "Clock-out successful", attendance });
  } catch (error) {
    res.status(500).json({ success: false, message: "Clock-out failed", error: error.message });
  }
};

/**
 * ✅ **Get Employee Attendance**
 * @route   GET /api/attendance/:employeeId
 * @access  Private (Employee)
 */
exports.getEmployeeAttendance = async (req, res) => {
  try {
    const { employeeId } = req.params;
    const attendanceRecords = await Attendance.find({ employeeId });

    if (!attendanceRecords.length) {
      return res.status(404).json({ success: false, message: "No attendance records found" });
    }

    res.status(200).json({ success: true, attendance: attendanceRecords });
  } catch (error) {
    res.status(500).json({ success: false, message: "Failed to fetch attendance", error: error.message });
  }
};

/**
 * ✅ **Admin: View All Attendance (with filters)**
 * @route   GET /api/admin/attendance
 * @query   employeeId, startDate, endDate, sortBy
 * @access  Private (Admin Only)
 */
exports.getAllAttendance = async (req, res) => {
  try {
    let query = {};
    const { employeeId, startDate, endDate, sortBy } = req.query;

    if (employeeId) query.employeeId = employeeId;
    if (startDate && endDate) {
      query.clockIn = { $gte: new Date(startDate), $lte: new Date(endDate) };
    }

    let attendanceRecords = await Attendance.find(query).populate("employeeId", "name employeeId");
    
    // Sorting (Optional)
    if (sortBy) {
      const sortField = sortBy === "date" ? "clockIn" : "totalHours";
      attendanceRecords = attendanceRecords.sort((a, b) => a[sortField] - b[sortField]);
    }

    if (!attendanceRecords.length) {
      return res.status(404).json({ success: false, message: "No attendance records found" });
    }

    res.status(200).json({ success: true, attendance: attendanceRecords });
  } catch (error) {
    res.status(500).json({ success: false, message: "Failed to fetch attendance records", error: error.message });
  }
};

/**
 * ✅ **Admin: Manually Mark Employee Attendance**
 * @route   POST /api/admin/mark-attendance
 * @body    { employeeId, clockIn, clockOut (optional) }
 * @access  Private (Admin Only)
 */
exports.markAttendance = async (req, res) => {
  try {
    const { employeeId, clockIn, clockOut } = req.body;

    if (!employeeId || !clockIn) {
      return res.status(400).json({ success: false, message: "Employee ID and Clock-In time are required" });
    }

    const newAttendance = new Attendance({
      employeeId,
      clockIn: new Date(clockIn),
      clockOut: clockOut ? new Date(clockOut) : null,
      totalHours: clockOut ? (new Date(clockOut) - new Date(clockIn)) / (1000 * 60 * 60) : 0,
    });

    await newAttendance.save();

    res.status(201).json({ success: true, message: "Attendance marked successfully", attendance: newAttendance });
  } catch (error) {
    res.status(500).json({ success: false, message: "Failed to mark attendance", error: error.message });
  }
};

/**
 * ✅ **Admin: Export Attendance Records as CSV**
 * @route   GET /api/admin/export-attendance
 * @access  Private (Admin Only)
 */
exports.exportAttendance = async (req, res) => {
  try {
    const attendanceRecords = await Attendance.find().populate("employeeId", "name employeeId");

    if (!attendanceRecords.length) {
      return res.status(404).json({ success: false, message: "No attendance records found" });
    }

    // Convert Data to CSV
    const fields = ["Employee ID", "Name", "Clock In", "Clock Out", "Total Hours"];
    const data = attendanceRecords.map((record) => ({
      "Employee ID": record.employeeId.employeeId,
      Name: record.employeeId.name,
      "Clock In": record.clockIn.toISOString(),
      "Clock Out": record.clockOut ? record.clockOut.toISOString() : "N/A",
      "Total Hours": record.totalHours.toFixed(2),
    }));

    const json2csvParser = new Parser({ fields });
    const csvData = json2csvParser.parse(data);

    res.setHeader("Content-Type", "text/csv");
    res.setHeader("Content-Disposition", "attachment; filename=attendance_records.csv");
    res.status(200).end(csvData);
  } catch (error) {
    res.status(500).json({ success: false, message: "Failed to export attendance records", error: error.message });
  }
};
