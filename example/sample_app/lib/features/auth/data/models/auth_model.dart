import '../../domain/entities/auth_entity.dart';

class AuthModel {
  const AuthModel({required this.id});

  final String id;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id};

  AuthEntity toEntity() => AuthEntity(id: id);

  factory AuthModel.fromEntity(AuthEntity entity) {
    return AuthModel(id: entity.id);
  }
}
