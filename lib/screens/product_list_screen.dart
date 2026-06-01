import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../screens/add_product_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/scanner_screen.dart';
import '../state/warehouse_state.dart';
import '../widgets/product_image.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WarehouseState>();
    final user = state.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Товары на складе'),
        actions: [
          IconButton(
            tooltip: 'Сканировать QR',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ScannerScreen()));
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
          IconButton(
            tooltip: 'Выйти',
            onPressed: state.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: state.initialize,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            _UserHeader(name: user.name, role: user.role.title),
            const SizedBox(height: 14),
            if (state.products.isEmpty)
              const _EmptyCatalog()
            else
              ...state.products.map(
                (product) => _ProductTile(product: product),
              ),
          ],
        ),
      ),
      floatingActionButton: state.canCreateProducts
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
              },
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Товар'),
            )
          : null,
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.name, required this.role});

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1E6EF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.person_outline),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    role,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF647086),
                    ),
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

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImage(imageUrl: product.imageUrl, width: 94, height: 94),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        _StatusChip(isAvailable: product.isAvailable),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF4B5668),
                      ),
                    ),
                    if (!product.isAvailable && product.holderName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Взял: ${product.holderName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8A4B12),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(isAvailable ? 'Свободен' : 'Занят'),
      avatar: Icon(
        isAvailable ? Icons.check_circle_outline : Icons.schedule,
        size: 18,
      ),
      backgroundColor: isAvailable
          ? const Color(0xFFE6F6EE)
          : const Color(0xFFFFF0D8),
      side: BorderSide.none,
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Каталог пуст',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
