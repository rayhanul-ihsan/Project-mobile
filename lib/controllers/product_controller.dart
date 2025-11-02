import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_fullstack/config/app_config.dart';
import 'package:project_fullstack/models/product_model.dart';
import 'package:project_fullstack/services/http_service.dart';

class ProductController {
  Future<String?> uploadImage(File image) async {
    try {
      final url = Uri.parse('${AppConfig.apiBase}/upload-image');
      final request = await HttpService.multipartRequest('POST', url);

      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        if (data['image'] is String) {
          return data['image'];
        }
      }
      return null;
    } catch (e) {
      print('Upload image error: $e');
      return null;
    }
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

    return await HttpService.post(url, body: body);
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      final url = Uri.parse('${AppConfig.apiBase}/products/delete/$productId');
      final response = await HttpService.delete(url);

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
    try {
      final url = Uri.parse('${AppConfig.apiBase}/products/getAll');
      final body = {
        "search": search,
        "search_by": searchBy,
        "operator": "and",
        "orderBy": orderBy,
        "order": order,
        "page": page,
        "size": size,
      };

      final response = await HttpService.post(url, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['data'];
        return data.map((e) => ProductModel.fromJson(e)).toList();
      } else {
        throw Exception(
          'Gagal memuat produk (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('Get products error: $e');
      rethrow;
    }
  }
}
