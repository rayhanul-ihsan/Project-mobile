import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpService {
  static Future<Map<String, String>> _getHeaders({
    bool requiresAuth = true,
    bool isMultipart = false,
  }) async {
    final headers = <String, String>{};

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (requiresAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<void> _handleUnauthorized(http.Response response) async {
    if (response.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  static Future<http.Response> get(
    Uri url, {
    bool requiresAuth = true,
  }) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final response = await http.get(url, headers: headers);
    await _handleUnauthorized(response);
    return response;
  }

  static Future<http.Response> post(
    Uri url, {
    Object? body,
    bool requiresAuth = true,
  }) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final response = await http.post(
      url,
      headers: headers,
      body: body is String ? body : jsonEncode(body),
    );
    await _handleUnauthorized(response);
    return response;
  }

  static Future<http.Response> put(
    Uri url, {
    Object? body,
    bool requiresAuth = true,
  }) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final response = await http.put(
      url,
      headers: headers,
      body: body is String ? body : jsonEncode(body),
    );
    await _handleUnauthorized(response);
    return response;
  }

  static Future<http.Response> delete(
    Uri url, {
    bool requiresAuth = true,
  }) async {
    final headers = await _getHeaders(requiresAuth: requiresAuth);
    final response = await http.delete(url, headers: headers);
    await _handleUnauthorized(response);
    return response;
  }

  static Future<http.MultipartRequest> multipartRequest(
    String method,
    Uri url, {
    bool requiresAuth = true,
  }) async {
    final request = http.MultipartRequest(method, url);
    final headers = await _getHeaders(
      requiresAuth: requiresAuth,
      isMultipart: true,
    );
    request.headers.addAll(headers);
    return request;
  }
}
