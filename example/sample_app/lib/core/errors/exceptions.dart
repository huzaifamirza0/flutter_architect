class ServerException implements Exception {
  const ServerException([this.message = 'A server error occurred']);
  final String message;

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  const CacheException([this.message = 'A cache error occurred']);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}
