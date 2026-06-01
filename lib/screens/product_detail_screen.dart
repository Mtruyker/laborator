import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/product.dart';
import '../state/warehouse_state.dart';
import '../widgets/product_image.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context) {
    final products = context.watch<WarehouseState>().products;
    final product = products.firstWhere(
      (item) => item.id == productId,
      orElse: () => products.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Карточка товара')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProductImage(
            imageUrl: product.imageUrl,
            height: 220,
            width: double.infinity,
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusBadge(product: product),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.35),
          ),
          const SizedBox(height: 20),
          if (!product.isAvailable) _HolderInfo(product: product),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  QrImageView(
                    data: product.qrPayload,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    product.qrPayload,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF647086),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(product.isAvailable ? 'Свободен' : 'Занят'),
      avatar: Icon(
        product.isAvailable ? Icons.check_circle_outline : Icons.lock_clock,
        size: 18,
      ),
      backgroundColor: product.isAvailable
          ? const Color(0xFFE6F6EE)
          : const Color(0xFFFFF0D8),
      side: BorderSide.none,
    );
  }
}

class _HolderInfo extends StatelessWidget {
  const _HolderInfo({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final takenAt = product.takenAt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.assignment_ind_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Товар взял: ${product.holderName ?? 'неизвестно'}'
                '${takenAt == null ? '' : '\nДата: ${takenAt.day}.${takenAt.month}.${takenAt.year} ${takenAt.hour.toString().padLeft(2, '0')}:${takenAt.minute.toString().padLeft(2, '0')}'}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
