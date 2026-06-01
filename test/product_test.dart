import 'package:flutter_test/flutter_test.dart';
import 'package:sklad_app/models/product.dart';

void main() {
  test('product QR payload contains warehouse prefix and id', () {
    const product = Product(
      id: 42,
      name: 'Тестовый товар',
      description: 'Описание тестового товара',
      imageUrl: 'https://example.com/image.jpg',
      isAvailable: true,
    );

    expect(product.qrPayload, 'warehouse-product:42');
  });
}
