import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/product.dart';
import '../state/warehouse_state.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  Product? _createdProduct;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавление товара')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Название',
              prefixIcon: Icon(Icons.inventory_2_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Описание',
              prefixIcon: Icon(Icons.description_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _imageController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Ссылка на картинку',
              prefixIcon: Icon(Icons.image_outlined),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isSubmitting ? null : _save,
            icon: _isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Сохранить и создать QR'),
          ),
          if (_createdProduct != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      _createdProduct!.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QrImageView(
                      data: _createdProduct!.qrPayload,
                      size: 220,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_createdProduct!.qrPayload),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSubmitting = true);

    try {
      final product = await context.read<WarehouseState>().addProduct(
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _imageController.text,
      );

      if (mounted) {
        setState(() => _createdProduct = product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Товар добавлен. QR-код создан.')),
        );
      }
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('FormatException: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
