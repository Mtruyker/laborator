import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class WarehouseState extends ChangeNotifier {
  WarehouseState({DatabaseService? database})
    : _database = database ?? DatabaseService.instance;

  final DatabaseService _database;

  AppUser? currentUser;
  List<Product> products = [];
  bool isLoading = true;
  String? errorMessage;

  bool get canCreateProducts => currentUser?.role.canCreateProducts ?? false;

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    products = await _database.loadProducts();

    isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _validateEmail(email);

    if (password.trim().isEmpty) {
      throw FormatException('Введите пароль.');
    }

    final user = await _database.findUserByCredentials(email, password);
    if (user == null) {
      throw FormatException('Неверный email или пароль.');
    }

    currentUser = user;
    products = await _database.loadProducts();
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordRepeat,
  }) async {
    if (name.trim().length < 2) {
      throw FormatException('Имя должно содержать минимум 2 символа.');
    }

    _validateEmail(email);

    if (password.length < 6) {
      throw FormatException('Пароль должен содержать минимум 6 символов.');
    }

    if (password != passwordRepeat) {
      throw FormatException('Пароли не совпадают.');
    }

    if (await _database.emailExists(email)) {
      throw FormatException('Пользователь с таким email уже есть.');
    }

    currentUser = await _database.createUser(
      name: name,
      email: email,
      password: password,
    );
    products = await _database.loadProducts();
    notifyListeners();
  }

  Future<Product> addProduct({
    required String name,
    required String description,
    required String imageUrl,
  }) async {
    if (!canCreateProducts) {
      throw StateError('Только администратор может добавлять товары.');
    }

    if (name.trim().length < 2) {
      throw FormatException('Название должно содержать минимум 2 символа.');
    }

    if (description.trim().length < 8) {
      throw FormatException('Описание должно содержать минимум 8 символов.');
    }

    final parsedImageUrl = Uri.tryParse(imageUrl.trim());
    if (imageUrl.trim().isNotEmpty &&
        (parsedImageUrl == null ||
            !parsedImageUrl.hasScheme ||
            parsedImageUrl.host.isEmpty)) {
      throw FormatException('Введите корректную ссылку на картинку.');
    }

    final id = await _database.createProduct(
      name: name,
      description: description,
      imageUrl: imageUrl.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=900'
          : imageUrl,
    );

    products = await _database.loadProducts();
    notifyListeners();

    return products.firstWhere((product) => product.id == id);
  }

  Future<Product> applyQrCode(String rawCode) async {
    if (currentUser == null) {
      throw StateError('Сначала войдите в приложение.');
    }

    final productId = _extractProductId(rawCode);
    if (productId == null) {
      throw FormatException('QR-код не относится к этому приложению.');
    }

    final product = await _database.findProductById(productId);
    if (product == null) {
      throw StateError('Товар с таким QR-кодом не найден.');
    }

    final updatedProduct = product.isAvailable
        ? product.copyWith(
            isAvailable: false,
            holderName: currentUser!.name,
            takenAt: DateTime.now(),
          )
        : Product(
            id: product.id,
            name: product.name,
            description: product.description,
            imageUrl: product.imageUrl,
            isAvailable: true,
          );

    await _database.updateProductStatus(updatedProduct);
    products = await _database.loadProducts();
    notifyListeners();

    return updatedProduct;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  static void _validateEmail(String email) {
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email.trim())) {
      throw FormatException('Введите корректный email.');
    }
  }

  static int? _extractProductId(String rawCode) {
    final trimmed = rawCode.trim();
    if (trimmed.startsWith('warehouse-product:')) {
      return int.tryParse(trimmed.replaceFirst('warehouse-product:', ''));
    }

    return int.tryParse(trimmed);
  }
}
