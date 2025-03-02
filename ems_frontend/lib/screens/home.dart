import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange, // Updated to orange for a vibrant UI
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "MS TRANSPORT",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          _buildNavButton(context, "Admin Register", "/admin_register"),
          _buildNavButton(context, "Employee Register", "/employee_register"),
          _buildNavButton(context, "Admin Login", "/admin_login"),
          _buildOutlinedButton(context, "Employee Login", "/employee_login"),
          const SizedBox(width: 15),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Text(
              "Welcome to MS TRANSPORT",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Manage your transport operations efficiently with our powerful tools.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            _buildFeatureCard(Icons.track_changes, "Live Tracking", "Monitor vehicle movement in real-time."),
            _buildFeatureCard(Icons.attach_money, "Expense Management", "Keep track of all transport expenses."),
            _buildFeatureCard(Icons.schedule, "Easy Scheduling", "Assign and manage employee shifts effortlessly."),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String text, String route) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, route),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, String text, String route) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, color: Colors.deepOrange, size: 30),
          title: Text(title, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text(description, style: const TextStyle(color: Colors.black54)),
        ),
      ),
    );
  }
}
