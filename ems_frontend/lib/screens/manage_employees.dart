import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

class ManageEmployeesScreen extends StatefulWidget {
  const ManageEmployeesScreen({super.key});

  @override
  _ManageEmployeesScreenState createState() => _ManageEmployeesScreenState();
}

class _ManageEmployeesScreenState extends State<ManageEmployeesScreen> {
  List employees = [];
  bool isLoading = true;

  Future<void> fetchEmployees() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/employees'));
    if (response.statusCode == 200) {
      setState(() => employees = jsonDecode(response.body)["employees"]);
    }
    setState(() => isLoading = false);
  }

  Future<void> deleteEmployee(String id) async {
    await http.delete(Uri.parse('$baseUrl/admin/delete/$id'));
    fetchEmployees();
  }

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Employees")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(employees[index]["name"]),
                  subtitle: Text("Phone: ${employees[index]["phone"]}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteEmployee(employees[index]["_id"]),
                  ),
                );
              },
            ),
    );
  }
}
