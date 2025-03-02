import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeLoginScreen extends StatefulWidget {
  const EmployeeLoginScreen({super.key});

  @override
  _EmployeeLoginScreenState createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends State<EmployeeLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isPasswordVisible = false; // ✅ Toggle password visibility

  /// **Login Function**
  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/employees/login'), // ✅ Correct API endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phoneController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]); // ✅ Save Token
        await prefs.setString("employeeId", data["employee"]["employeeId"]); // ✅ Save Employee ID

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Login Successful! Redirecting...")),
        );

        Navigator.pushReplacementNamed(context, "/employee_dashboard"); // ✅ Redirect to dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${data["message"]}")),
        );
      }
    } catch (error) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Network Error. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // ✅ Add form validation
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Phone Input Field
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Enter phone number" : null,
              ),
              const SizedBox(height: 15),

              // ✅ Password Input Field with Visibility Toggle
              TextFormField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) => value!.length < 6 ? "Enter at least 6 characters" : null,
              ),
              const SizedBox(height: 20),

              // ✅ Login Button with Loading State
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: loginUser,
                      child: const Text("Login"),
                    ),
              
              const SizedBox(height: 15),

              // ✅ Registration Link
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/register"),
                child: const Text("Don't have an account? Register here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
