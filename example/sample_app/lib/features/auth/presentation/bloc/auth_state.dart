import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoaded extends AuthState {
  const AuthLoaded({required this.items});

  final List<AuthEntity> items;

  @override
  List<Object?> get props => [items];
}

class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
