import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_fullstack/config/app_config.dart';
import 'package:project_fullstack/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final ImageProvider imageProvider;
    if (product.image.isEmpty) {
      imageProvider = const AssetImage('assets/images/DummyProduct.png');
    } else if (product.image.startsWith('http')) {
      imageProvider = NetworkImage(product.image);
    } else {
      final apiBase = AppConfig.apiBase.replaceAll(RegExp(r'/$'), '');
      String hostBase = apiBase;
      final apiIndex = apiBase.indexOf('/api');
      if (apiIndex != -1) hostBase = apiBase.substring(0, apiIndex);

      final normalizedPath = product.image.replaceAll(RegExp(r'^/'), '');
      final useHost = product.image.startsWith('/uploads');
      final imageUrl = useHost
          ? '$hostBase/$normalizedPath'
          : '$apiBase/$normalizedPath';
      imageProvider = NetworkImage(imageUrl);
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              width: double.infinity,
              decoration: ShapeDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Color(0xFF050506),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp',
                          decimalDigits: 0,
                        ).format(product.price),
                        style: const TextStyle(
                          color: Color(0xFFFF7900),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF5B5C63),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const ShapeDecoration(
                          color: Color(0xFFE6E9EF),
                          shape: OvalBorder(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.stokMenipis} Terjual',
                        style: const TextStyle(
                          color: Color(0xFF5B5C63),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
