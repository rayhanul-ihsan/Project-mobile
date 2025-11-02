import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_fullstack/config/app_config.dart';
import 'package:project_fullstack/services/http_service.dart';

class AuthController {
  final String usersBase = '${AppConfig.apiBase}/users';

  Future<String?> login(String username, String password) async {
    try {
      final url = Uri.parse('$usersBase/login');
      final body = {
        "username": username,
        "password": password,
      };

      final response = await HttpService.post(
        url,
        body: body,
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthData(data);
        return data['data']?['role'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['access_token'] ?? '');
    await prefs.setString('auth', jsonEncode(data));
    if (data['data'] != null) {
      await prefs.setString('user', jsonEncode(data['data']));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null && userStr.isNotEmpty) {
      return jsonDecode(userStr);
    }
    return null;
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
