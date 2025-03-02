import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  _EmployeeProfileScreenState createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  String employeeId = "";

  @override
  void initState() {
    super.initState();
    _fetchEmployeeProfile();
  }

  /// ✅ **Fetch Employee Profile from Backend**
  Future<void> _fetchEmployeeProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Authorization Error! Please log in again.")));
      return;
    }

    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse("http://localhost:5000/api/employees/profile"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        nameController.text = data["employee"]["name"];
        phoneController.text = data["employee"]["phone"];
        employeeId = data["employee"]["employeeId"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: ${jsonDecode(response.body)["message"]}")));
    }
  }

  /// ✅ **Update Employee Profile**
  Future<void> _updateProfile() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ All fields are required!")));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    setState(() => isLoading = true);

    final response = await http.put(
      Uri.parse("http://localhost:5000/api/employees/update"),
      headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
      body: jsonEncode({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Profile Updated Successfully!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: ${jsonDecode(response.body)["message"]}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Employee ID: $employeeId", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Phone"),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text("Update Profile"),
                  ),
                ],
              ),
            ),
    );
  }
}
