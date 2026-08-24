import '../../domain/entities/user_entity.dart';

/// Clean Architecture - Data Layer: Model
/// Data transfer object extending or converting to Domain Entity.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  UserEntity toEntity() => UserEntity(id: id, name: name, email: email, role: role);
}
