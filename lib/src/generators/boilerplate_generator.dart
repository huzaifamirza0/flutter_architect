import 'dart:io';
import '../models/setup_config.dart';
import '../templates/networking_templates.dart';
import '../templates/di_templates.dart';
import '../templates/error_templates.dart';
import '../templates/router_templates.dart';
import '../templates/base_templates.dart';

class BoilerplateGenerator {
  BoilerplateGenerator(this.config, this.root);

  final SetupConfig config;
  final String root;

  late final String libPath = '$root/lib';

  void generate() {
    _generateBase();
    _generateNetworking();
    _generateDI();
    _generateErrors();
    _generateRouter();
    _generateAppAndMain();
  }

  void _generateBase() {
    _write('$libPath/core/base/usecase.dart', BaseTemplates.useCase);
  }

  void _generateNetworking() {
    _write('$libPath/core/network/network_info.dart', NetworkingTemplates.networkInfo);
    if (config.networking == NetworkingType.rest || config.networking == NetworkingType.both) {
      _write('$libPath/core/network/api_client.dart', NetworkingTemplates.dioClient);
    }
    if (config.networking == NetworkingType.graphQL || config.networking == NetworkingType.both) {
      _write('$libPath/core/network/graphql_client.dart', NetworkingTemplates.graphqlClient);
    }
  }

  void _generateDI() {
    if (config.useGetIt) {
      _write('$libPath/app/di/service_locator.dart', DiTemplates.getItLocator);
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

  void _generateAppAndMain() {
    final useGoRouter = config.router == RouterType.goRouter;
    final useAutoRoute = config.router == RouterType.autoRoute;
    final useRiverpod = config.stateManagement == StateManagement.riverpod;
    final useBloc = config.stateManagement == StateManagement.bloc;
    final useProvider = config.stateManagement == StateManagement.provider;

    // --- Generate app.dart ---
    String appContent;
    if (useGoRouter) {
      appContent = '''import 'package:flutter/material.dart';
import 'router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '${config.projectName}',
      routerConfig: appRouter,
    );
  }
}
''';
    } else if (useAutoRoute) {
      appContent = '''import 'package:flutter/material.dart';
import 'router/app_router.dart';

class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '${config.projectName}',
      routerConfig: _appRouter.config(),
    );
  }
}
''';
    } else {
      appContent = '''import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '${config.projectName}',
      home: Scaffold(
        body: Center(child: Text('Hello, flutter_architect!')),
      ),
    );
  }
}
''';
    }
    _write('$libPath/app/app.dart', appContent, overwrite: true);

    // --- Generate main.dart ---
    String mainContent;
    String diSetup = config.useGetIt ? '\n  await setupLocator();' : '';
    String diImport = config.useGetIt ? "\nimport 'app/di/service_locator.dart';" : '';

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
    } else if (useBloc) {
      mainContent = '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';$diImport

void main() async {
  WidgetsFlutterBinding.ensureInitialized();$diSetup
  runApp(
    MultiBlocProvider(
      providers: [
        // BlocProvider(create: (context) => sl<AuthBloc>()),
      ],
      child: const App(),
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
        // ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
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

  void _write(String path, String content, {bool overwrite = false}) {
    final file = File(path);
    if (!overwrite && file.existsSync()) {
      return;
    }
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
    final display = path.replaceAll('$root/', '');
    stdout.writeln('  \x1B[32m✓\x1B[0m  $display');
  }
}
