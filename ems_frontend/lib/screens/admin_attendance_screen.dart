import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  _AdminAttendanceScreenState createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  List<dynamic> _attendanceRecords = [];
  bool _isLoading = true;
  String _statusMessage = "Fetching attendance records...";

  @override
  void initState() {
    super.initState();
    fetchAttendanceRecords();
  }

  /// **Fetch All Attendance Records for Admin**
  Future<void> fetchAttendanceRecords() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Fetching attendance records...";
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = Uri.parse("http://localhost:5000/api/attendance/");
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _attendanceRecords = data["attendance"] ?? [];
          _isLoading = false;
          _statusMessage = _attendanceRecords.isEmpty ? "No attendance records found" : "";
        });
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = "Failed to fetch attendance records.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Error loading data. Check your connection.";
      });
    }
  }

  /// **Format Date & Time**
  String formatDateTime(String dateTime) {
    try {
      final DateTime parsedDate = DateTime.parse(dateTime).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Attendance")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attendanceRecords.isEmpty
              ? Center(child: Text(_statusMessage))
              : RefreshIndicator(
                  onRefresh: fetchAttendanceRecords,
                  child: ListView.builder(
                    itemCount: _attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = _attendanceRecords[index];

                      // Display Employee ID if Name is Missing
                      final String employeeInfo = record["employeeName"] ?? "Employee ID: ${record["employeeId"] ?? "Unknown"}";

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        child: ListTile(
                          title: Text(employeeInfo),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Clock In: ${formatDateTime(record['clockIn'])}"),
                              record["clockOut"] != null
                                  ? Text("Clock Out: ${formatDateTime(record['clockOut'])}")
                                  : const Text("Not yet clocked out", style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
