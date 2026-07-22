abstract class CoreBoilerplateTemplates {
  static const String appConstants = '''/// Shared app-wide constants.
abstract class AppConstants {
  static const String appName = 'Flutter App';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';

  // Pagination
  static const int defaultPageSize = 20;
}
''';

  static const String appLogger = '''import 'dart:developer' as developer;

/// Lightweight logger for debug / error reporting.
abstract class AppLogger {
  static void debug(String message, {String name = 'App'}) {
    developer.log(message, name: name, level: 500);
  }

  static void info(String message, {String name = 'App'}) {
    developer.log(message, name: name, level: 800);
  }

  static void warning(String message, {String name = 'App'}) {
    developer.log(message, name: name, level: 900);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'App',
  }) {
    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
''';

  static const String loadingWidget = '''import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}
''';
}
