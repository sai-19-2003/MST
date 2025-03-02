import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceRecordsScreen extends StatefulWidget {
  const AttendanceRecordsScreen({super.key});

  @override
  _AttendanceRecordsScreenState createState() => _AttendanceRecordsScreenState();
}

class _AttendanceRecordsScreenState extends State<AttendanceRecordsScreen> {
  List<dynamic> attendanceRecords = [];
  bool isLoading = true;
  String searchQuery = "";
  String? token;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  /// ✅ **Load Admin Token & Fetch Attendance**
  Future<void> _loadAdminData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("adminToken");

    if (token == null) {
      showSnackBar("❌ Unauthorized. Please login again.");
      setState(() => isLoading = false);
    } else {
      fetchAllAttendance();
    }
  }

  /// ✅ **Fetch Attendance Records**
  Future<void> fetchAllAttendance() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/admin/attendance'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📢 API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          attendanceRecords = data["attendance"] ?? [];
          isLoading = false;
        });

        if (attendanceRecords.isEmpty) {
          showSnackBar("⚠️ No attendance records found.");
        }
      } else {
        handleErrorResponse(response);
      }
    } catch (error) {
      showSnackBar("❌ Failed to fetch attendance records.");
      setState(() => isLoading = false);
    }
  }

  /// ✅ **Delete Attendance Record**
  Future<void> deleteAttendance(String attendanceId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/admin/attendance/$attendanceId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        showSnackBar("✅ Attendance record deleted.");
        fetchAllAttendance(); // Refresh list after deletion
      } else {
        showSnackBar("❌ ${data["message"]}");
      }
    } catch (error) {
      showSnackBar("❌ Failed to delete record.");
    }
  }

  /// ✅ **Download Attendance as CSV**
  Future<void> exportAttendance() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/admin/export-attendance'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        showSnackBar("✅ Attendance records exported successfully!");
      } else {
        showSnackBar("❌ Failed to export records.");
      }
    } catch (error) {
      showSnackBar("❌ Export failed. Try again.");
    }
  }

  /// ✅ **Search Filter**
  List<dynamic> getFilteredRecords() {
    if (searchQuery.isEmpty) return attendanceRecords;
    return attendanceRecords.where((record) {
      return record["employeeId"].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  /// ✅ **Format Date & Time for Display**
  String formatDateTime(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime).toLocal();
    return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year} - ${parsedDate.hour}:${parsedDate.minute}";
  }

  /// ✅ **Show SnackBar Messages**
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// ✅ **Handle API Errors**
  void handleErrorResponse(http.Response response) {
    setState(() => isLoading = false);
    final data = jsonDecode(response.body);
    showSnackBar("❌ ${data["message"]}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Records"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: exportAttendance, // Export to CSV
          ),
        ],
      ),
      body: Column(
        children: [
          /// **🔍 Search Bar**
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search by Employee ID",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),

          /// **📄 Attendance List**
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) // ✅ Show Loading Indicator
                : getFilteredRecords().isNotEmpty
                    ? ListView.builder(
                        itemCount: getFilteredRecords().length,
                        itemBuilder: (context, index) {
                          var record = getFilteredRecords()[index];

                          return Card(
                            margin: const EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.deepPurple, width: 1),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                child: Text(record["employeeId"].substring(3)), // Last part of ID
                              ),
                              title: Text(
                                "Employee ID: ${record["employeeId"]}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Clock In: ${formatDateTime(record["clockIn"])}"),
                                  if (record.containsKey("clockOut"))
                                    Text("Clock Out: ${formatDateTime(record["clockOut"])}"),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Hours: ${record["totalHours"].toStringAsFixed(2)}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteAttendance(record["_id"]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          "⚠️ No attendance records found.",
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
