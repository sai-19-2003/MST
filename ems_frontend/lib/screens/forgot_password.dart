import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String phone = '';
  String newPassword = '';
  bool _isLoading = false;

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse("http://localhost:5000/api/auth/forgot-password");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone, "newPassword": newPassword}),
    );

    setState(() => _isLoading = false);
    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Password reset successful! Please login.")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${responseData['message']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Reset Your Password", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

              // Phone Input
              TextFormField(
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.length != 10 ? "Enter valid phone number" : null,
                onChanged: (value) => phone = value,
              ),

              // New Password Input
              TextFormField(
                decoration: InputDecoration(labelText: "New Password"),
                obscureText: true,
                validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
                onChanged: (value) => newPassword = value,
              ),

              SizedBox(height: 20),

              // Reset Button
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: resetPassword,
                      child: Text("Reset Password"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
