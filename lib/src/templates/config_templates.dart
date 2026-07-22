abstract class ConfigTemplates {
  static String appConfig(String projectName, {required bool useFlavors}) {
    if (useFlavors) {
      return '''/// Global app configuration.
/// Call [bootstrap] from each flavor entrypoint before [runApp].
abstract class AppConfig {
  static const String appName = '$projectName';
  static const String appVersion = '1.0.0';

  static Environment _environment = Environment.development;

  static Environment get environment => _environment;

  static void bootstrap(Environment env) {
    _environment = env;
  }

  static bool get isProduction => environment == Environment.production;
  static bool get isStaging => environment == Environment.staging;
  static bool get isDevelopment => environment == Environment.development;
}

enum Environment {
  development,
  staging,
  production,
}
''';
    }

    return '''/// Global app configuration.
abstract class AppConfig {
  static const String appName = '$projectName';
  static const String appVersion = '1.0.0';

  static const Environment environment = Environment.development;

  static bool get isProduction => environment == Environment.production;
  static bool get isStaging => environment == Environment.staging;
  static bool get isDevelopment => environment == Environment.development;
}

enum Environment {
  development,
  staging,
  production,
}
''';
  }

  static const String envConfig = '''import 'app_config.dart';

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

  static String get graphqlUrl => '\$apiBaseUrl/graphql';

  static Duration get connectTimeout => const Duration(seconds: 10);
  static Duration get receiveTimeout => const Duration(seconds: 10);

  static bool get enableLogging => !AppConfig.isProduction;
}
''';
}
