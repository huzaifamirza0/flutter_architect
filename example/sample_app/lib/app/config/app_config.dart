/// Global app configuration.
/// Call [bootstrap] from each flavor entrypoint before [runApp].
abstract class AppConfig {
  static const String appName = 'sample_app';
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
