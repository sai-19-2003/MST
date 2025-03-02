import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  /// ✅ **Admin Login Function**
  Future<void> loginAdmin() async {
    if (!_formKey.currentState!.validate()) return; // Validate form before submitting

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/admin/login'), // ✅ Check API URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phoneController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      final data = jsonDecode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("adminToken", data["token"]);
        await prefs.setString("adminName", data["admin"]["name"]);
        await prefs.setString("adminPhone", data["admin"]["phone"]);

        print("✅ Admin Token Saved: ${data["token"]}");
        print("✅ Admin Name: ${data["admin"]["name"]}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Login Successful! Redirecting...")),
        );

        // ✅ Navigate to Admin Dashboard
        Navigator.pushReplacementNamed(context, "/admin_dashboard");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${data["message"]}")),
        );
      }
    } catch (error) {
      print("❌ Network Error: $error");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Network Error. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// ✅ **Phone Input**
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Enter phone number" : null,
              ),
              const SizedBox(height: 15),

              /// ✅ **Password Input**
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => value!.length < 6 ? "Enter at least 6 characters" : null,
              ),
              const SizedBox(height: 20),

              /// ✅ **Login Button**
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: loginAdmin,
                      child: const Text("Login"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
