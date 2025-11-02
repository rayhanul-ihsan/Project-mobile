import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_fullstack/config/app_config.dart';
import 'package:project_fullstack/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductController {
  Future<String?> uploadImage(File image) async {
    final url = Uri.parse('${AppConfig.apiBase}/upload-image');
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
    var response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      if (data['image'] is String) {
        return data['image'];
      }
    }
    return null;
  }

  Future<http.Response> submitProduct({
    required String nama,
    required String kategori,
    required int stokAwal,
    required int harga,
    required String status,
    required String deskripsi,
    String image = "",
  }) async {
    final url = Uri.parse('${AppConfig.apiBase}/products/add');
    final body = {
      "image": image,
      "nama": nama,
      "kategori": kategori,
      "stokAwal": stokAwal,
      "stokPengurangan": 0,
      "stokPenambahan": 0,
      "harga": harga,
      "status": status,
      "deskripsi": deskripsi,
    };

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final url = Uri.parse('${AppConfig.apiBase}/products/delete/$productId');

      final headers = <String, String>{
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      };

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Delete failed (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }

  Future<List<ProductModel>> getProducts({
    String order = 'desc',
    String orderBy = 'created_at',
    int page = 1,
    int size = 10,
    String search = '',
    List<String> searchBy = const [],
  }) async {
    final url = Uri.parse('${AppConfig.apiBase}/products/getAll');

    // kirim parameter melalui body
    final body = jsonEncode({
      "search": search,
      "search_by": searchBy,
      "operator": "and",
      "orderBy": orderBy,
      "order": order,
      "page": page,
      "size": size,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception(
        'Gagal memuat produk (${response.statusCode}): ${response.body}',
      );
    }
  }
}
