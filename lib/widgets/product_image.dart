import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    this.height = 120,
    this.width,
  });

  final String imageUrl;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: const Color(0xFFE7ECF4),
            alignment: Alignment.center,
            child: const Icon(Icons.inventory_2_outlined, size: 38),
          );
        },
      ),
    );
  }
}
