import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import 'employee_login_screen.dart';

class EmployeeRegistrationScreen extends StatefulWidget {
  const EmployeeRegistrationScreen({super.key});

  @override
  _EmployeeRegistrationScreenState createState() => _EmployeeRegistrationScreenState();
}

class _EmployeeRegistrationScreenState extends State<EmployeeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // ✅ Function to Register Employee
  Future<void> registerEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final response = await http.post(
      Uri.parse('$baseUrl/employee/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "password": passwordController.text.trim(),
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Successful!")));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EmployeeLoginScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data["message"])));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employee Registration")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Full Name"),
                validator: (value) => value!.isEmpty ? "Name is required" : null,
              ),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Phone Number"),
                validator: (value) => value!.isEmpty ? "Phone number is required" : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: registerEmployee,
                      child: Text("Register"),
                    ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeLoginScreen())),
                child: Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
