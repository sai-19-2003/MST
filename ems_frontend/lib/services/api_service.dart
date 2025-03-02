import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:5000/api"; // Update this if needed

  /// ✅ **Login Employee**
  static Future<Map<String, dynamic>> loginEmployee(String phone, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/employees/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone, "password": password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", data["token"]);
      await prefs.setString("employeeId", data["employee"]["employeeId"]);
      return {"success": true, "message": "Login Successful", "data": data};
    } else {
      return {"success": false, "message": data["message"]};
    }
  }

  /// ✅ **Register Employee**
  static Future<Map<String, dynamic>> registerEmployee(String name, String phone, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/employees/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "phone": phone, "password": password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {"success": true, "message": "Registration Successful", "data": data};
    } else {
      return {"success": false, "message": data["message"]};
    }
  }

  /// ✅ **Get Employee Profile**
  static Future<Map<String, dynamic>> getEmployeeProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/employees/profile"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {"success": true, "data": data["employee"]};
    } else {
      return {"success": false, "message": data["message"]};
    }
  }

  /// ✅ **Update Employee Profile**
  static Future<Map<String, dynamic>> updateEmployeeProfile(String name, String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.put(
      Uri.parse("$baseUrl/employees/update"),
      headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
      body: jsonEncode({"name": name, "phone": phone}),
    );

    final data = jsonDecode(response.body);
    return response.statusCode == 200
        ? {"success": true, "message": "Profile Updated", "data": data["employee"]}
        : {"success": false, "message": data["message"]};
  }

  /// ✅ **Delete Employee Account**
  static Future<Map<String, dynamic>> deleteEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.delete(
      Uri.parse("$baseUrl/employees/delete"),
      headers: {"Authorization": "Bearer $token"},
    );

    final data = jsonDecode(response.body);
    return response.statusCode == 200
        ? {"success": true, "message": "Account Deleted"}
        : {"success": false, "message": data["message"]};
  }
}
