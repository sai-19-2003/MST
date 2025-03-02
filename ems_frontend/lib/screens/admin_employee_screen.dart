import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminEmployeeScreen extends StatefulWidget {
  const AdminEmployeeScreen({super.key});

  @override
  _AdminEmployeeScreenState createState() => _AdminEmployeeScreenState();
}

class _AdminEmployeeScreenState extends State<AdminEmployeeScreen> {
  List<dynamic> employees = [];
  List<dynamic> filteredEmployees = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  /// **✅ Fetch All Employees**
  Future<void> fetchEmployees() async {
    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("adminToken");

      final response = await http.get(
        Uri.parse('http://localhost:5000/api/employees'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          employees = data["employees"];
          filteredEmployees = employees;
          isLoading = false;
        });
      } else {
        showMessage("❌ ${data["message"]}");
        setState(() => isLoading = false);
      }
    } catch (error) {
      showMessage("❌ Network Error. Try again.");
      setState(() => isLoading = false);
    }
  }

  /// **🔍 Search Employees**
  void searchEmployees(String query) {
    setState(() {
      searchQuery = query;
      filteredEmployees = employees
          .where((employee) =>
              employee["name"].toLowerCase().contains(query.toLowerCase()) ||
              employee["employeeId"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// **📝 Edit Employee Dialog**
  void editEmployee(String employeeId) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    final employee = employees.firstWhere((emp) => emp["employeeId"] == employeeId);

    nameController.text = employee["name"];
    phoneController.text = employee["phone"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Employee"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await updateEmployee(employeeId, nameController.text, phoneController.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// **🔄 Update Employee Details**
  Future<void> updateEmployee(String employeeId, String name, String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("adminToken");

    final response = await http.put(
      Uri.parse("http://localhost:5000/api/employees/update/$employeeId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": name, "phone": phone}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      showMessage("✅ Employee Updated Successfully!");
      await fetchEmployees();
    } else {
      showMessage("❌ ${data["message"]}");
    }
  }

  /// **🗑 Delete Employee Dialog**
  void deleteEmployeeDialog(String employeeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this employee?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await deleteEmployee(employeeId);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  /// **🗑 Delete Employee**
  Future<void> deleteEmployee(String employeeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("adminToken");

    final response = await http.delete(
      Uri.parse("http://localhost:5000/api/employees/delete/$employeeId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      showMessage("✅ Employee Deleted Successfully!");
      await fetchEmployees();
    } else {
      showMessage("❌ ${data["message"]}");
    }
  }

  /// **🔄 Reset Employee Password Dialog**
  void resetPasswordDialog(String employeeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: const Text("Are you sure you want to reset this employee's password?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await resetPassword(employeeId);
              Navigator.pop(context);
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  /// **🔄 Reset Employee Password**
  Future<void> resetPassword(String employeeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("adminToken");

    final response = await http.post(
      Uri.parse("http://localhost:5000/api/employees/reset-password/$employeeId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      showMessage("✅ Password Reset Successfully!");
    } else {
      showMessage("❌ ${data["message"]}");
    }
  }

  /// **📌 Show Message**
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Employees")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Search Employee",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: searchEmployees,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      return ListTile(
                        title: Text(employee["name"]),
                        subtitle: Text("ID: ${employee["employeeId"]} | Phone: ${employee["phone"]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit), onPressed: () => editEmployee(employee["employeeId"])),
                            IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteEmployeeDialog(employee["employeeId"])),
                            IconButton(icon: const Icon(Icons.lock_reset), onPressed: () => resetPasswordDialog(employee["employeeId"])),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
