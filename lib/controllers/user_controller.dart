import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_fullstack/config/app_config.dart';
import 'package:project_fullstack/services/http_service.dart';

class UserController {
  final String usersBase = '${AppConfig.apiBase}/users';

  Future<http.Response> createUser({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String role,
    String? photoProfile,
  }) async {
    final url = Uri.parse('$usersBase/add');
    final body = {
      "username": username,
      "email": email,
      "password": password,
      "phone": phone,
      "role": role,
      if (photoProfile != null) "photo_profile": photoProfile,
    };

    return await HttpService.post(url, body: body, requiresAuth: false);
  }

  Future<List<Map<String, dynamic>>> getUsers({
    String order = 'desc',
    String orderBy = 'created_at',
    int page = 1,
    int size = 10,
    String search = '',
  }) async {
    try {
      final url = Uri.parse('$usersBase/getAll');
      final body = {
        "search": search,
        "orderBy": orderBy,
        "order": order,
        "page": page,
        "size": size,
      };

      final response = await HttpService.post(url, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load users: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final url = Uri.parse('$usersBase/get/$userId');
      final response = await HttpService.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final url = Uri.parse('$usersBase/update/$userId');
      final response = await HttpService.put(url, body: userData);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final url = Uri.parse('$usersBase/delete/$userId');
      final response = await HttpService.delete(url);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
