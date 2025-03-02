import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_screen.dart';
import 'employee_profile_screen.dart'; // ✅ Import Profile Screen

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  String employeeName = "Employee";
  String employeeId = "";

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  /// ✅ **Load Employee Name & ID from SharedPreferences**
  Future<void> _loadEmployeeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeName = prefs.getString("employeeName") ?? "Employee";
      employeeId = prefs.getString("employeeId") ?? "";
    });
  }

  /// ✅ **Logout Function with Confirmation**
  Future<void> logout(BuildContext context) async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout")),
        ],
      ),
    ) ?? false;

    if (confirmLogout) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Dashboard")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(employeeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              accountEmail: Text("ID: $employeeId"),
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person, size: 40)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmployeeProfileScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text("Attendance"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AttendanceScreen()),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard, size: 100, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text("Welcome, $employeeName!", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("Employee ID: $employeeId", style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
