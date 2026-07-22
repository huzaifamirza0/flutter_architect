import 'dart:io';
import 'package:interact/interact.dart';
import '../models/setup_config.dart';

class SetupPrompts {
  static SetupConfig run() {
    String? detectedName;
    final pubspecFile = File('pubspec.yaml');
    if (pubspecFile.existsSync()) {
      final lines = pubspecFile.readAsLinesSync();
      for (final line in lines) {
        if (line.startsWith('name:')) {
          detectedName = line.replaceFirst('name:', '').trim();
          break;
        }
      }
    }

    String projectName;
    if (detectedName != null) {
      final useAuto = Confirm(
        prompt: 'Auto-detected project name "$detectedName". Use this?',
        defaultValue: true,
      ).interact();

      if (useAuto) {
        projectName = detectedName;
      } else {
        projectName = Input(
          prompt: 'Project Name?',
          defaultValue: 'my_flutter_app',
        ).interact();
      }
    } else {
      projectName = Input(
        prompt: 'Project Name?',
        defaultValue: 'my_flutter_app',
      ).interact();
    }

    final archIdx = Select(
      prompt: 'Architecture Pattern?',
      options: ['Clean Architecture', 'MVVM'],
      initialIndex: 0,
    ).interact();
    final architecture = ArchitectureType.values[archIdx];

    final stateManagementIdx = Select(
      prompt: 'Which state management?',
      options: ['BLoC', 'Riverpod', 'Provider', 'GetX', 'None'],
      initialIndex: 0,
    ).interact();

    final routerIdx = Select(
      prompt: 'Routing?',
      options: ['Go Router', 'Auto Route', 'Navigator 2.0', 'Vanilla'],
      initialIndex: 0,
    ).interact();

    final networkingIdx = Select(
      prompt: 'Networking?',
      options: ['REST (Dio)', 'GraphQL', 'Both', 'None'],
      initialIndex: 0,
    ).interact();

    final useFirebase = Confirm(
      prompt: 'Use Firebase?',
      defaultValue: false,
    ).interact();

    final useHive = Confirm(
      prompt: 'Use Hive for local storage?',
      defaultValue: false,
    ).interact();

    final useGetIt = Confirm(
      prompt: 'Use GetIt for Dependency Injection?',
      defaultValue: true,
    ).interact();

    final useFreezed = Confirm(
      prompt: 'Use Freezed?',
      defaultValue: false,
    ).interact();

    final useEquatable = Confirm(
      prompt: 'Use Equatable?',
      defaultValue: true,
    ).interact();

    final useLocalization = Confirm(
      prompt: 'Enable localization (l10n)?',
      defaultValue: true,
    ).interact();

    var locales = <String>['en'];
    if (useLocalization) {
      final extra = Input(
        prompt: 'Locales (comma-separated, en is always included)?',
        defaultValue: 'en, ar',
      ).interact();
      locales = extra
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
      if (!locales.contains('en')) locales.insert(0, 'en');
    }

    final useFlavors = Confirm(
      prompt: 'Generate flavors (dev / staging / prod) + env files?',
      defaultValue: true,
    ).interact();

    final cicdIdx = Select(
      prompt: 'CI/CD templates?',
      options: ['GitHub Actions', 'Codemagic', 'Both', 'None'],
      initialIndex: 0,
    ).interact();

    final generateAuth = Confirm(
      prompt: 'Generate Auth Module?',
      defaultValue: true,
    ).interact();

    final generateSample = Confirm(
      prompt: 'Generate Sample Feature?',
      defaultValue: true,
    ).interact();

    return SetupConfig(
      architecture: architecture,
      projectName: projectName,
      stateManagement: StateManagement.values[stateManagementIdx],
      router: RouterType.values[routerIdx],
      networking: NetworkingType.values[networkingIdx],
      useFirebase: useFirebase,
      useHive: useHive,
      useGetIt: useGetIt,
      useFreezed: useFreezed,
      useEquatable: useEquatable,
      generateAuth: generateAuth,
      generateSample: generateSample,
      useLocalization: useLocalization,
      locales: locales,
      useFlavors: useFlavors,
      cicd: CicdProvider.values[cicdIdx],
    );
  }
}
