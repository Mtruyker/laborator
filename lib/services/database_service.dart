import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import '../models/product.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();
  static const _databaseName = 'warehouse.db';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    _database = await openDatabase(path, version: 1, onCreate: _createDatabase);

    return _database!;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        image_url TEXT NOT NULL,
        is_available INTEGER NOT NULL,
        holder_name TEXT,
        taken_at TEXT
      )
    ''');

    await db.insert('users', {
      'name': 'Администратор склада',
      'email': 'admin@sklad.ru',
      'password': 'admin123',
      'role': UserRole.admin.name,
    });

    await db.insert('users', {
      'name': 'Иван Пользователь',
      'email': 'user@sklad.ru',
      'password': 'user123',
      'role': UserRole.user.name,
    });

    await db.insert('products', {
      'name': 'Ноутбук Lenovo ThinkPad',
      'description': 'Рабочий ноутбук для выездных задач и отчетности.',
      'image_url':
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=900',
      'is_available': 1,
    });

    await db.insert('products', {
      'name': 'Сканер штрихкодов',
      'description': 'Ручной USB-сканер для приемки и инвентаризации.',
      'image_url':
          'https://images.unsplash.com/photo-1580983561371-7f4b242d8ecb?w=900',
      'is_available': 1,
    });

    await db.insert('products', {
      'name': 'Набор инструментов',
      'description': 'Комплект для мелкого ремонта складского оборудования.',
      'image_url':
          'https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=900',
      'is_available': 0,
      'holder_name': 'Иван Пользователь',
      'taken_at': DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
    });
  }

  Future<AppUser?> findUserByCredentials(String email, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), password],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return AppUser.fromMap(rows.first);
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  Future<AppUser> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;
    final id = await db.insert('users', {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': UserRole.user.name,
    });

    return AppUser(
      id: id,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: UserRole.user,
    );
  }

  Future<List<Product>> loadProducts() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'id DESC');
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> findProductById(int id) async {
    final db = await database;
    final rows = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Product.fromMap(rows.first);
  }

  Future<int> createProduct({
    required String name,
    required String description,
    required String imageUrl,
  }) async {
    final db = await database;
    return db.insert('products', {
      'name': name.trim(),
      'description': description.trim(),
      'image_url': imageUrl.trim(),
      'is_available': 1,
      'holder_name': null,
      'taken_at': null,
    });
  }

  Future<void> updateProductStatus(Product product) async {
    final db = await database;
    await db.update(
      'products',
      {
        'is_available': product.isAvailable ? 1 : 0,
        'holder_name': product.holderName,
        'taken_at': product.takenAt?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }
}
