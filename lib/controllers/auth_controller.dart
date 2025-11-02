// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_fullstack/config/app_config.dart';

class AuthController {
  final String usersBase = '${AppConfig.apiBase}/users';

  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$usersBase/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Login success: $data");
        // Simpan token dan user data supaya header dapat membaca
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access_token'] ?? '');
        await prefs.setString('auth', jsonEncode(data)); // full response
        if (data['data'] != null) {
          await prefs.setString(
            'user',
            jsonEncode(data['data']),
          ); // user object
        }
        return data['data']?['role'];
      } else {
        print("Login failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // hapus semua key yang dipakai header untuk mendeteksi
    await prefs.remove('access_token');
    await prefs.remove('auth');
    await prefs.remove('user');
    await prefs.remove('user_data');
    await prefs.remove('authData');
    await prefs.remove('profile');
  }
}
