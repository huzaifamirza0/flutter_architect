import 'dart:io';
import 'package:args/command_runner.dart';
import '../prompts/setup_prompts.dart';
import '../models/setup_config.dart';
import '../generators/boilerplate_generator.dart';
import '../utils/validation_utils.dart';
import 'create/feature_creator.dart';

class InitCommand extends Command<void> {
  @override
  final String name = 'init';

  @override
  final String description =
      'Generate the base architecture folder structure inside the current Flutter project.';

  InitCommand() {
    argParser.addFlag(
      'dry-run',
      abbr: 'n',
      negatable: false,
      help: 'Print what would be created without writing anything to disk.',
    );
    argParser.addFlag(
      'no-interaction',
      negatable: false,
      help: 'Disable interactive prompts and use default configuration.',
    );
  }

  @override
  Future<void> run() async {
    final dryRun = argResults!['dry-run'] as bool;
    final noInteraction = argResults!['no-interaction'] as bool;
    final root = Directory.current.path;
    final libPath = '$root/lib';

    _printBanner();

    SetupConfig? config;
    if (!dryRun && !noInteraction) {
      try {
        config = SetupPrompts.run();
      } catch (e) {
        stdout.writeln('\n\x1B[31mSetup aborted.\x1B[0m');
        exit(1);
      }
    }

    final isMvvm = config?.architecture == ArchitectureType.mvvm;
    final archLabel = isMvvm ? 'MVVM' : 'Clean Architecture';

    if (config != null) {
      stdout.writeln('\n\x1B[36mConfiguration collected:\x1B[0m');
      stdout.writeln('  Architecture: $archLabel');
      stdout.writeln('  Project Name: ${config.projectName}');
      stdout.writeln('  State Management: ${config.stateManagement.name}');
      stdout.writeln('  Router: ${config.router.name}');
      stdout.writeln('  Networking: ${config.networking.name}');
      stdout.writeln('  Firebase: ${config.useFirebase}');
      stdout.writeln('  Hive: ${config.useHive}');
      stdout.writeln('  GetIt: ${config.useGetIt}');
      stdout.writeln('  Freezed: ${config.useFreezed}');
      stdout.writeln('  Equatable: ${config.useEquatable}');
      stdout.writeln('  Auth Module: ${config.generateAuth}');
      stdout.writeln('  Sample Feature: ${config.generateSample}');
    }

    // ── Shared folders (both architectures) ──────────────────────
    final folders = [
      '$libPath/app/router',
      '$libPath/app/themes',
      '$libPath/app/config',
      '$libPath/app/di',
      '$libPath/core/network',
      '$libPath/core/services',
      '$libPath/core/utils',
      '$libPath/core/constants',
      '$libPath/core/errors',
      '$libPath/core/extensions',
      '$libPath/core/widgets',
      '$libPath/core/storage',
      '$libPath/core/logger',
      if (!isMvvm) '$libPath/core/base',
      '$libPath/features',
      '$libPath/shared',
    ];

    stdout.writeln('\nScaffolding $archLabel at: $libPath\n');

    var created = 0;
    for (final folder in folders) {
      final dir = Directory(folder);
      final displayPath = folder.replaceAll('$root/', '');

      if (dir.existsSync()) {
        stdout.writeln('  \x1B[33m~\x1B[0m  $displayPath (already exists)');
        continue;
      }

      if (dryRun) {
        stdout.writeln('  \x1B[36m+\x1B[0m  $displayPath');
        created++;
      } else {
        dir.createSync(recursive: true);
        File('$folder/.gitkeep').writeAsStringSync('');
        stdout.writeln('  \x1B[32m✓\x1B[0m  $displayPath');
        created++;
      }
    }

    if (!dryRun && config != null) {
      // Save architecture choice for future create commands
      ValidationUtils.saveArchitecture(root, config.architecture.name);

      stdout.writeln('\n\x1B[36mGenerating Boilerplate Files...\x1B[0m');
      BoilerplateGenerator(config, root).generate();

      if (config.generateAuth) {
        stdout.writeln('\n\x1B[36mGenerating Auth Module...\x1B[0m');
        final runner = CommandRunner<void>('sub', 'sub')
          ..addCommand(FeatureCreatorCommand());
        await runner.run(
            ['feature', 'auth', '--state-management', config.stateManagement.name]);
      }

      if (config.generateSample) {
        stdout.writeln('\n\x1B[36mGenerating Sample Feature...\x1B[0m');
        final runner = CommandRunner<void>('sub', 'sub')
          ..addCommand(FeatureCreatorCommand());
        await runner.run(
            ['feature', 'todo', '--state-management', config.stateManagement.name]);
      }
    }

    stdout.writeln('');
    if (dryRun) {
      stdout.writeln('\x1B[36m[dry-run] Would create $created directories.\x1B[0m');
    } else {
      stdout.writeln('\x1B[32m✅  Done! $archLabel is ready.\x1B[0m');

      if (config != null) {
        // Build required packages list
        final packages = <String>[];
        if (!isMvvm) packages.add('dartz'); // only needed for Clean
        if (config.useEquatable) packages.add('equatable');
        if (config.useGetIt) packages.add('get_it');
        if (config.networking == NetworkingType.rest ||
            config.networking == NetworkingType.both) {
          packages.add('dio');
        }
        if (config.networking == NetworkingType.graphQL ||
            config.networking == NetworkingType.both) {
          packages.add('graphql_flutter');
        }
        if (config.stateManagement == StateManagement.bloc) packages.add('flutter_bloc');
        if (config.stateManagement == StateManagement.riverpod) packages.add('flutter_riverpod');
        if (config.stateManagement == StateManagement.provider) packages.add('provider');
        if (config.stateManagement == StateManagement.getx) packages.add('get');
        if (config.router == RouterType.goRouter) packages.add('go_router');
        if (config.router == RouterType.autoRoute) packages.add('auto_route');
        if (config.useHive) packages.addAll(['hive', 'hive_flutter']);

        stdout.writeln('\n\x1B[33m[!] Required Dependencies\x1B[0m');
        stdout.writeln(
            '    Please run the following command to install the necessary packages:');
        stdout.writeln('    \x1B[1mflutter pub add ${packages.join(' ')}\x1B[0m');

        if (config.useFreezed || config.router == RouterType.autoRoute) {
          stdout.writeln('\n\x1B[33m[!] You selected Freezed or AutoRoute.\x1B[0m');
          stdout.writeln(
              '    Don\'t forget to run \x1B[1mdart run build_runner build\x1B[0m');
        }
      }

      stdout.writeln('\nNext steps:');
      stdout.writeln('  flutter_architect create feature <name>');
      if (isMvvm) {
        stdout.writeln('  flutter_architect create viewmodel <name>');
      } else {
        stdout.writeln('  flutter_architect create model <Name>');
      }
    }
  }

  void _printBanner() {
    stdout.writeln('');
    stdout.writeln('\x1B[1m\x1B[34m╔════════════════════════════════════╗\x1B[0m');
    stdout.writeln('\x1B[1m\x1B[34m║   flutter_architect  v1.0.0        ║\x1B[0m');
    stdout.writeln('\x1B[1m\x1B[34m║   Architecture Generator           ║\x1B[0m');
    stdout.writeln('\x1B[1m\x1B[34m╚════════════════════════════════════╝\x1B[0m');
  }
}
