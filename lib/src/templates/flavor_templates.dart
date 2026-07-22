abstract class FlavorTemplates {
  static String envFile(String flavor, {required String apiUrl}) => '''
# Environment: $flavor
# Reference file — wire with flutter_dotenv or keep using EnvConfig in Dart.
APP_NAME=MyApp
API_BASE_URL=$apiUrl
ENABLE_LOGGING=${flavor == 'production' ? 'false' : 'true'}
'''.trimLeft();

  static String flavorMain({
    required String flavor,
    required String environmentEnum,
    required bool useGetIt,
    required bool useRiverpod,
    required bool useProvider,
  }) {
    final diImport =
        useGetIt ? "\nimport 'app/di/service_locator.dart';" : '';
    final diSetup = useGetIt ? '\n  await setupLocator();' : '';

    String runAppBlock;
    if (useRiverpod) {
      runAppBlock = '''
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );''';
    } else if (useProvider) {
      runAppBlock = '''
  runApp(
    MultiProvider(
      providers: const [],
      child: const App(),
    ),
  );''';
    } else {
      runAppBlock = '\n  runApp(const App());';
    }

    final extraImports = StringBuffer();
    if (useRiverpod) {
      extraImports.writeln(
          "import 'package:flutter_riverpod/flutter_riverpod.dart';");
    }
    if (useProvider) {
      extraImports.writeln("import 'package:provider/provider.dart';");
    }

    return '''import 'package:flutter/material.dart';
${extraImports}import 'app/app.dart';
import 'app/config/app_config.dart';$diImport

/// Entry point for the **$flavor** flavor.
///
/// Run with:
///   flutter run -t lib/main_$flavor.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.bootstrap(Environment.$environmentEnum);$diSetup$runAppBlock
}
''';
  }

  static String launchJson(String projectName) => '''
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "$projectName (dev)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_development.dart"
    },
    {
      "name": "$projectName (staging)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_staging.dart"
    },
    {
      "name": "$projectName (production)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_production.dart"
    }
  ]
}
'''.trimLeft();
}
