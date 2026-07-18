abstract class ErrorTemplates {
  static const String failures = '''import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}
''';

  static const String exceptions = '''class ServerException implements Exception {
  const ServerException([this.message = 'A server error occurred']);
  final String message;
  
  @override
  String toString() => 'ServerException: \$message';
}

class CacheException implements Exception {
  const CacheException([this.message = 'A cache error occurred']);
  final String message;

  @override
  String toString() => 'CacheException: \$message';
}
''';
}
