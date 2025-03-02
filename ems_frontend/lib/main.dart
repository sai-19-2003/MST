import 'package:flutter/material.dart';
import 'package:ems_frontend/screens/home.dart';
import 'package:ems_frontend/screens/admin_registration.dart';
import 'package:ems_frontend/screens/admin_login_screen.dart';
import 'package:ems_frontend/screens/employee_registration.dart';
import 'package:ems_frontend/screens/employee_login_screen.dart';
import 'package:ems_frontend/screens/admin_dashboard.dart';
import 'package:ems_frontend/screens/employee_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MS TRANSPORT - Employee Management",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          elevation: 5,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(), // ✅ Splash screen first
        '/home': (context) => const HomeScreen(), // ✅ Home screen (fully integrated)
        '/admin_register': (context) => const AdminRegistrationScreen(),
        '/admin_login': (context) => const AdminLoginScreen(),
        '/employee_register': (context) => const EmployeeRegistrationScreen(),
        '/employee_login': (context) => const EmployeeLoginScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/employee_dashboard': (context) => const EmployeeDashboard(),
      },
    );
  }
}

/// ✅ **Splash Screen with Auto Redirect to Home**
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home'); // ✅ Redirect safely
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping_rounded, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "MS TRANSPORT",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
