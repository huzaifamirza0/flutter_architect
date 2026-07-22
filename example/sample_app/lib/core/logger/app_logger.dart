import 'dart:developer' as developer;

abstract class AppLogger {
  static void debug(String message, {String name = 'App'}) {
    developer.log(message, name: name, level: 500);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'App',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
