import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:project_fullstack/models/product_model.dart';

class ProductInfo extends StatelessWidget {
  final ProductModel product;

  const ProductInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: const TextStyle(
            color: Color(0xFF050506),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp',
            decimalDigits: 0,
          ).format(product.price),
          style: const TextStyle(
            color: Color(0xFF050506),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: ShapeDecoration(
            color: const Color(0xFFF5F7FA),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFE6E9EF)),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          child: Text(
            product.category,
            style: const TextStyle(
              color: Color(0xFF050506),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text(
              'Stok: ',
              style: TextStyle(
                color: Color(0xFF5B5C63),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
            Text(
              '${product.stok}',
              style: const TextStyle(
                color: Color(0xFF050506),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                Icon(
                  PhosphorIconsFill.checkCircle,
                  size: 16,
                  color: Color(0xFFE6871A),
                ),
                const SizedBox(width: 4),
                Text(
                  product.status == true ? 'Aktif' : 'Non-Aktif',
                  style: const TextStyle(
                    color: Color(0xFFE6871A),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
