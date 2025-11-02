import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_fullstack/config/app_config.dart';
import 'package:project_fullstack/models/product_model.dart';
import 'package:project_fullstack/widgets/product/product_carousel.dart';
import 'package:project_fullstack/widgets/product/product_description.dart';
import 'package:project_fullstack/widgets/product/product_detail_info.dart';
import 'package:project_fullstack/widgets/product/product_footer.dart';
import 'package:project_fullstack/widgets/product/product_shipping.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  String _resolveImageUrl(String imagePath) {
    if (imagePath.isEmpty) return 'https://via.placeholder.com/600';
    if (imagePath.startsWith('http')) return imagePath;

    final apiBase = AppConfig.apiBase.replaceAll(RegExp(r'/$'), '');
    String hostBase = apiBase;
    final apiIndex = apiBase.indexOf('/api');
    if (apiIndex != -1) hostBase = apiBase.substring(0, apiIndex);

    final normalizedPath = imagePath.replaceAll(RegExp(r'^/'), '');
    final useHost = imagePath.startsWith('/uploads');
    return useHost ? '$hostBase/$normalizedPath' : '$apiBase/$normalizedPath';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(product.image);
    final price = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(product.price);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          product.name,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: "Inter",
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProductCarousel(imageUrl: imageUrl),

            ProductDetailInfo(
              name: product.name,
              rating: product.rating.toStringAsFixed(1),
              soldCount: '${product.stokMenipis}',
              // category: product.kategori,
              // status: product.status,
            ),

            const SizedBox(height: 8),
            const ProductShipping(),
            const SizedBox(height: 8),

            ProductDescription(
              description: product.description.isNotEmpty
                  ? product.description
                  : 'Tidak ada description produk.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ProductFooter(price: price, discount: null),
      ),
    );
  }
}
