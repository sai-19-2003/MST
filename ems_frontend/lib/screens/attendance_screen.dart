import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isClockedIn = false;
  String? _attendanceId;
  String? _employeeId;
  List<dynamic> _attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  /// **Load Employee ID & Token from SharedPreferences**
  Future<void> _loadEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _employeeId = prefs.getString("employeeId");
    });
    fetchAttendanceRecords();
  }

  /// **Clock-In Function**
  Future<void> clockIn() async {
    if (_employeeId == null) {
      showError("⚠️ Error: Employee ID missing. Please login again.");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse("http://localhost:5000/api/attendance/clock-in");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"employeeId": _employeeId}),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 201) {
      setState(() {
        _isClockedIn = true;
        _attendanceId = data["attendance"]["_id"];
      });
      showSuccess("✅ Clock-In Successful");
      fetchAttendanceRecords();
    } else {
      showError("❌ ${data["message"]}");
    }
  }

  /// **Clock-Out Function**
  Future<void> clockOut() async {
    if (_attendanceId == null) {
      showError("⚠️ No active clock-in found");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse("http://localhost:5000/api/attendance/clock-out/$_attendanceId");
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _isClockedIn = false;
        _attendanceId = null;
      });
      showSuccess("✅ Clock-Out Successful");
      fetchAttendanceRecords();
    } else {
      showError("❌ ${data["message"]}");
    }
  }

  /// **Fetch Attendance Records**
  Future<void> fetchAttendanceRecords() async {
    if (_employeeId == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse("http://localhost:5000/api/attendance/$_employeeId");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _attendanceRecords = data["attendance"] ?? [];
        _isClockedIn = _attendanceRecords.isNotEmpty && _attendanceRecords.last["clockOut"] == null;
        _attendanceId = _isClockedIn ? _attendanceRecords.last["_id"] : null;
      });
    } else {
      showError("❌ ${data["message"]}");
    }
  }

  /// **Helper Functions to Show Messages**
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
    );
  }

  /// **Format Date & Time**
  String formatDateTime(String dateTime) {
    try {
      final DateTime parsedDate = DateTime.parse(dateTime).toLocal();
      return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}, ${parsedDate.hour}:${parsedDate.minute}";
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isClockedIn ? clockOut : clockIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isClockedIn ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(_isClockedIn ? "Clock Out" : "Clock In"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Attendance Records",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _attendanceRecords.isEmpty
                  ? const Center(child: Text("No attendance records found"))
                  : ListView.builder(
                      itemCount: _attendanceRecords.length,
                      itemBuilder: (context, index) {
                        final record = _attendanceRecords[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          child: ListTile(
                            title: Text("Clock In: ${formatDateTime(record['clockIn'])}"),
                            subtitle: record["clockOut"] != null
                                ? Text("Clock Out: ${formatDateTime(record['clockOut'])}\nTotal Hours: ${record['totalHours'] ?? 'N/A'}")
                                : const Text("Not yet clocked out", style: TextStyle(color: Colors.red)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
