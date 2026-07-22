import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  const AuthEntity({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
