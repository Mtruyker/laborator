class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.isAvailable,
    this.holderName,
    this.takenAt,
  });

  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isAvailable;
  final String? holderName;
  final DateTime? takenAt;

  String get qrPayload => 'warehouse-product:$id';

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isAvailable,
    String? holderName,
    DateTime? takenAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      holderName: holderName,
      takenAt: takenAt,
    );
  }

  factory Product.fromMap(Map<String, Object?> map) {
    final takenAtValue = map['taken_at'] as String?;

    return Product(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      imageUrl: map['image_url'] as String,
      isAvailable: (map['is_available'] as int) == 1,
      holderName: map['holder_name'] as String?,
      takenAt: takenAtValue == null ? null : DateTime.parse(takenAtValue),
    );
  }

  Map<String, Object?> toMapForInsert() {
    return {
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'is_available': isAvailable ? 1 : 0,
      'holder_name': holderName,
      'taken_at': takenAt?.toIso8601String(),
    };
  }
}
