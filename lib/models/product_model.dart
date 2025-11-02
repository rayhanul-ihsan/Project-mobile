import 'dart:ffi';

class ProductModel {
  final String id;
  final String image;
  final String name;
  final String category;
  final int stok;
  final int stokMenipis;
  final int stokPenambahan;
  final double price;
  final bool status;
  final String description;
  final double rating;

  ProductModel({
    required this.id,
    required this.image,
    required this.name,
    required this.category,
    required this.stok,
    required this.stokMenipis,
    required this.stokPenambahan,
    required this.price,
    required this.status,
    required this.description,
    this.rating = 0.0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      stok: (json['stok'] ?? 0).toInt(),
      stokMenipis: (json['stokMenipis'] ?? 0).toInt(),
      stokPenambahan: (json['stokPenambahan'] ?? 0).toInt(),
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] == true, // pastikan jadi boolean
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}
