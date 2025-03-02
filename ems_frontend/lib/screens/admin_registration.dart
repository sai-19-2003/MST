import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({super.key});

  @override
  _AdminRegistrationScreenState createState() => _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String phone = '';
  String password = '';
  bool _isLoading = false;

  // 🛠️ Register Admin Function
  Future<void> registerAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse("http://localhost:5000/api/admin/register"); // Update with your backend URL
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "phone": phone, "password": password}),
      );

      final responseData = json.decode(response.body);
      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Registration Successful! Please Login.")),
        );
        Navigator.pushReplacementNamed(context, '/admin_login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${responseData['message']}")),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Server error. Try again!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title: const Text(
          "Admin Registration",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🏢 MS TRANSPORTS Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          "assets/logo.png", // Ensure the logo exists in the assets folder
                          width: 100,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 📌 Admin Registration Title
                      const Text(
                        "Admin Registration",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // 📌 Name Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) => value!.isEmpty ? "Name is required" : null,
                        onChanged: (value) => name = value,
                      ),
                      const SizedBox(height: 10),

                      // 📌 Phone Number Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.length != 10 ? "Enter a valid phone number" : null,
                        onChanged: (value) => phone = value,
                      ),
                      const SizedBox(height: 10),

                      // 📌 Password Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        obscureText: true,
                        validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
                        onChanged: (value) => password = value,
                      ),
                      const SizedBox(height: 20),

                      // ✅ Register Button
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              icon: const Icon(Icons.app_registration),
                              label: const Text("Register"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: registerAdmin,
                            ),
                      const SizedBox(height: 10),

                      // 🔄 Redirect to Login
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/admin_login'),
                        child: const Text("Already have an account? Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
