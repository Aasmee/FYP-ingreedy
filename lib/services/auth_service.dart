import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ingreedy_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setInt('uid', data['uid']);
      await prefs.setString('username', data['username']);
      return null;
    } else {
      return jsonDecode(response.body)['error'] ?? 'Login failed';
    }
  }

  Future<String?> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return null;
    } else {
      return jsonDecode(response.body)['error'] ?? 'Registration failed';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
