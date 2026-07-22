import 'app_config.dart';

/// Environment-specific values (API URLs, keys, feature flags).
abstract class EnvConfig {
  static String get apiBaseUrl {
    switch (AppConfig.environment) {
      case Environment.development:
        return 'https://dev-api.example.com';
      case Environment.staging:
        return 'https://staging-api.example.com';
      case Environment.production:
        return 'https://api.example.com';
    }
  }

  static String get graphqlUrl => '$apiBaseUrl/graphql';

  static Duration get connectTimeout => const Duration(seconds: 10);
  static Duration get receiveTimeout => const Duration(seconds: 10);

  static bool get enableLogging => !AppConfig.isProduction;
}
