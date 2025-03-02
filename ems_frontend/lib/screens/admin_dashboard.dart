import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_records.dart'; // Updated for Attendance Management
import 'admin_employee_screen.dart'; // Employee Management

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String adminName = "Admin";
  String adminId = "";

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  /// ✅ **Load Admin Name & ID from SharedPreferences**
  Future<void> _loadAdminData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString("adminName") ?? "Admin";
      adminId = prefs.getString("adminId") ?? "";
    });
  }

  /// ✅ **Logout Function (Redirects Correctly)**
  Future<void> logout(BuildContext context) async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    ) ?? false;

    if (confirmLogout) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("adminToken");
      await prefs.remove("adminId");
      await prefs.remove("adminName");

      Navigator.pushReplacementNamed(context, "/admin_login"); // ✅ Redirect to Admin Login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(adminName, style: const TextStyle(fontSize: 18)),
              accountEmail: Text("ID: $adminId"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.deepPurple),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.access_time_filled),
              title: const Text("Manage Attendance"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AttendanceRecordsScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Manage Employees"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminEmployeeScreen()),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text("Manage Salaries"),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Salary Management Coming Soon...")),
                );
              },
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Admin Controls",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// **Manage Attendance**
            AdminButton(
              title: "Manage Attendance",
              icon: Icons.access_time_filled,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AttendanceRecordsScreen()),
              ),
            ),
            const SizedBox(height: 15),

            /// **Manage Employees**
            AdminButton(
              title: "Manage Employees",
              icon: Icons.people,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminEmployeeScreen()),
              ),
            ),
            const SizedBox(height: 15),

            /// **Manage Salaries**
            AdminButton(
              title: "Manage Salaries",
              icon: Icons.monetization_on,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Salary Management Coming Soon...")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ **Reusable Admin Dashboard Button**
class AdminButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const AdminButton({super.key, required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        textStyle: const TextStyle(fontSize: 18),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 24),
      label: Text(title),
      onPressed: onTap,
    );
  }
}
