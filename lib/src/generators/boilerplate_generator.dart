import 'dart:io';
import '../models/setup_config.dart';
import '../templates/networking_templates.dart';
import '../templates/di_templates.dart';
import '../templates/error_templates.dart';
import '../templates/router_templates.dart';
import '../templates/base_templates.dart';
import '../templates/theme_templates.dart';
import '../templates/config_templates.dart';
import '../templates/core_boilerplate_templates.dart';
import '../templates/l10n_templates.dart';
import '../templates/flavor_templates.dart';
import '../templates/cicd_templates.dart';
import '../utils/pubspec_utils.dart';

class BoilerplateGenerator {
  BoilerplateGenerator(this.config, this.root);

  final SetupConfig config;
  final String root;

  late final String libPath = '$root/lib';
  bool get _isMvvm => config.architecture == ArchitectureType.mvvm;
  bool get _useRest =>
      config.networking == NetworkingType.rest ||
      config.networking == NetworkingType.both;

  void generate() {
    if (!_isMvvm) {
      _generateBase();
    }
    _generateConfig();
    _generateTheme();
    _generateCoreHelpers();
    _generateNetworking();
    _generateDI();
    _generateErrors();
    _generateRouter();
    if (config.useLocalization) {
      _generateL10n();
    }
    if (config.useFlavors) {
      _generateFlavors();
    }
    _generateCicd();
    _generateAppAndMain();
  }

  void _generateBase() {
    _write('$libPath/core/base/usecase.dart', BaseTemplates.useCase);
  }

  void _generateConfig() {
    _write(
      '$libPath/app/config/app_config.dart',
      ConfigTemplates.appConfig(
        config.projectName,
        useFlavors: config.useFlavors,
      ),
    );
    _write('$libPath/app/config/env_config.dart', ConfigTemplates.envConfig);
  }

  void _generateTheme() {
    _write('$libPath/app/themes/app_colors.dart', ThemeTemplates.appColors);
    _write(
        '$libPath/app/themes/app_text_styles.dart', ThemeTemplates.appTextStyles);
    _write('$libPath/app/themes/app_theme.dart', ThemeTemplates.appTheme);
  }

  void _generateCoreHelpers() {
    _write(
      '$libPath/core/constants/app_constants.dart',
      CoreBoilerplateTemplates.appConstants,
    );
    _write(
      '$libPath/core/logger/app_logger.dart',
      CoreBoilerplateTemplates.appLogger,
    );
    _write(
      '$libPath/core/widgets/app_loading.dart',
      CoreBoilerplateTemplates.loadingWidget,
    );
  }

  void _generateNetworking() {
    _write(
        '$libPath/core/network/network_info.dart', NetworkingTemplates.networkInfo);
    if (_useRest) {
      _write('$libPath/core/network/api_client.dart', NetworkingTemplates.dioClient);
    }
    if (config.networking == NetworkingType.graphQL ||
        config.networking == NetworkingType.both) {
      _write(
        '$libPath/core/network/graphql_client.dart',
        NetworkingTemplates.graphqlClient,
      );
    }
  }

  void _generateDI() {
    if (config.useGetIt) {
      _write(
        '$libPath/app/di/service_locator.dart',
        DiTemplates.getItLocator(registerApiClient: _useRest),
      );
    }
  }

  void _generateErrors() {
    _write('$libPath/core/errors/failures.dart', ErrorTemplates.failures);
    _write('$libPath/core/errors/exceptions.dart', ErrorTemplates.exceptions);
  }

  void _generateRouter() {
    if (config.router == RouterType.goRouter) {
      _write('$libPath/app/router/app_router.dart', RouterTemplates.goRouter);
    } else if (config.router == RouterType.autoRoute) {
      _write('$libPath/app/router/app_router.dart', RouterTemplates.autoRoute);
    }
  }

  void _generateL10n() {
    _write('$root/l10n.yaml', L10nTemplates.l10nYaml);
    for (final locale in config.locales) {
      _write(
        '$libPath/l10n/app_$locale.arb',
        L10nTemplates.arb(locale, config.projectName),
      );
    }
    PubspecUtils.enableLocalization(root);
  }

  void _generateFlavors() {
    final useRiverpod = config.stateManagement == StateManagement.riverpod;
    final useProvider = config.stateManagement == StateManagement.provider;

    for (final entry in {
      'development': 'development',
      'staging': 'staging',
      'production': 'production',
    }.entries) {
      _write(
        '$libPath/main_${entry.key}.dart',
        FlavorTemplates.flavorMain(
          flavor: entry.key,
          environmentEnum: entry.value,
          useGetIt: config.useGetIt,
          useRiverpod: useRiverpod,
          useProvider: useProvider,
        ),
        overwrite: true,
      );
    }

    _write(
      '$root/.env.development',
      FlavorTemplates.envFile(
        'development',
        apiUrl: 'https://dev-api.example.com',
      ),
    );
    _write(
      '$root/.env.staging',
      FlavorTemplates.envFile(
        'staging',
        apiUrl: 'https://staging-api.example.com',
      ),
    );
    _write(
      '$root/.env.production',
      FlavorTemplates.envFile(
        'production',
        apiUrl: 'https://api.example.com',
      ),
    );

    _write(
      '$root/.vscode/launch.json',
      FlavorTemplates.launchJson(config.projectName),
    );
  }

  void _generateCicd() {
    final gh = config.useFlavors
        ? CicdTemplates.githubActionsWithFlavors
        : CicdTemplates.githubActions;
    final cm = config.useFlavors
        ? CicdTemplates.codemagicWithFlavors
        : CicdTemplates.codemagic;

    switch (config.cicd) {
      case CicdProvider.githubActions:
        _write('$root/.github/workflows/flutter_ci.yml', gh);
      case CicdProvider.codemagic:
        _write('$root/codemagic.yaml', cm);
      case CicdProvider.both:
        _write('$root/.github/workflows/flutter_ci.yml', gh);
        _write('$root/codemagic.yaml', cm);
      case CicdProvider.none:
        break;
    }
  }

  void _generateAppAndMain() {
    final useGoRouter = config.router == RouterType.goRouter;
    final useAutoRoute = config.router == RouterType.autoRoute;
    final useRiverpod = config.stateManagement == StateManagement.riverpod;
    final useProvider = config.stateManagement == StateManagement.provider;

    final l10nImport = config.useLocalization
        ? "import 'package:flutter_localizations/flutter_localizations.dart';\n"
            "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n"
        : '';

    final l10nProps = config.useLocalization
        ? '''
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
'''
        : '';

    final themeImports = '''import 'config/app_config.dart';
import 'themes/app_theme.dart';
''';

    String appContent;
    if (useGoRouter) {
      appContent = '''import 'package:flutter/material.dart';
${l10nImport}import 'router/app_router.dart';
$themeImports
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,$l10nProps
      routerConfig: appRouter,
    );
  }
}
''';
    } else if (useAutoRoute) {
      appContent = '''import 'package:flutter/material.dart';
${l10nImport}import 'router/app_router.dart';
$themeImports
class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,$l10nProps
      routerConfig: _appRouter.config(),
    );
  }
}
''';
    } else {
      appContent = '''import 'package:flutter/material.dart';
$l10nImport$themeImports
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,$l10nProps
      home: const Scaffold(
        body: Center(child: Text('Hello, flutter_architect!')),
      ),
    );
  }
}
''';
    }
    _write('$libPath/app/app.dart', appContent, overwrite: true);

    // Default main.dart — points at development when flavors enabled.
    if (config.useFlavors) {
      _write(
        '$root/lib/main.dart',
        '''import 'main_development.dart' as development;

/// Default entrypoint — forwards to the development flavor.
/// Prefer running a flavor target explicitly:
///   flutter run -t lib/main_development.dart
///   flutter run -t lib/main_staging.dart
///   flutter run -t lib/main_production.dart
void main() => development.main();
''',
        overwrite: true,
      );
    } else {
      String mainContent;
      final diSetup = config.useGetIt ? '\n  await setupLocator();' : '';
      final diImport =
          config.useGetIt ? "\nimport 'app/di/service_locator.dart';" : '';

      if (useRiverpod) {
        mainContent = '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';$diImport

void main() async {
  WidgetsFlutterBinding.ensureInitialized();$diSetup
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
''';
      } else if (useProvider) {
        mainContent = '''import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';$diImport

void main() async {
  WidgetsFlutterBinding.ensureInitialized();$diSetup
  runApp(
    MultiProvider(
      providers: [
        // Feature providers are typically created at the page level.
      ],
      child: const App(),
    ),
  );
}
''';
      } else {
        mainContent = '''import 'package:flutter/material.dart';
import 'app/app.dart';$diImport

void main() async {
  WidgetsFlutterBinding.ensureInitialized();$diSetup
  runApp(const App());
}
''';
      }
      _write('$root/lib/main.dart', mainContent, overwrite: true);
    }
  }

  void _write(String path, String content, {bool overwrite = false}) {
    final file = File(path);
    if (!overwrite && file.existsSync()) {
      return;
    }
    file.createSync(recursive: true);
    file.writeAsStringSync(content);

    var shown = path.replaceAll('\\', '/');
    final rootNorm = root.replaceAll('\\', '/');
    if (shown.startsWith(rootNorm)) {
      shown = shown.substring(rootNorm.length);
      if (shown.startsWith('/')) shown = shown.substring(1);
    }
    stdout.writeln('  \x1B[32m✓\x1B[0m  $shown');
  }
}
