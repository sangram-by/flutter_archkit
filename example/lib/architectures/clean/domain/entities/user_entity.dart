/// Clean Architecture - Domain Layer: Entity
/// Pure Dart class representing core business concepts, independent of UI & Frameworks.
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}
