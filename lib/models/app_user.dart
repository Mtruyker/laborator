enum UserRole {
  admin,
  user;

  static UserRole fromDatabase(String value) {
    return value == admin.name ? admin : user;
  }

  String get title {
    switch (this) {
      case UserRole.admin:
        return 'Администратор';
      case UserRole.user:
        return 'Пользователь';
    }
  }

  bool get canCreateProducts => this == UserRole.admin;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final int id;
  final String name;
  final String email;
  final UserRole role;

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.fromDatabase(map['role'] as String),
    );
  }
}
