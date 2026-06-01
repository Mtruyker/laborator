import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../state/warehouse_state.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _manualCodeController = TextEditingController();
  bool _isHandlingCode = false;

  @override
  void dispose() {
    _scannerController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканирование QR')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Код из QR',
                    prefixIcon: Icon(Icons.qr_code_2),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                tooltip: 'Применить код',
                onPressed: () => _applyCode(_manualCodeController.text),
                icon: const Icon(Icons.check),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'При сканировании свободный товар помечается как взятый, занятый товар возвращается на склад.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF647086)),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue;
    if (code == null || _isHandlingCode) {
      return;
    }

    _applyCode(code);
  }

  Future<void> _applyCode(String code) async {
    if (_isHandlingCode) {
      return;
    }

    setState(() => _isHandlingCode = true);

    try {
      final product = await context.read<WarehouseState>().applyQrCode(code);
      if (!mounted) {
        return;
      }

      final message = product.isAvailable
          ? 'Товар возвращен: ${product.name}'
          : 'Товар выдан: ${product.name}';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop();
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
        setState(() => _isHandlingCode = false);
      }
    }
  }
}
