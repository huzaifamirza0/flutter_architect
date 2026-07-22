import 'dart:io';
import 'package:args/command_runner.dart';
import '../../utils/name_utils.dart';
import '../../utils/validation_utils.dart';
import '../../templates/mvvm_templates.dart';

/// `flutter_architect create viewmodel <Name>`
class ViewModelCreatorCommand extends Command<void> {
  @override
  final String name = 'viewmodel';

  @override
  final String description =
      'Generate a ViewModel (and View) for an MVVM feature.';

  @override
  String get invocation =>
      'flutter_architect create viewmodel <Name> [--feature <featureName>]';

  ViewModelCreatorCommand() {
    argParser.addOption(
      'feature',
      abbr: 'f',
      help: 'The feature folder to place this viewmodel in (e.g. auth).',
    );
  }

  @override
  Future<void> run() async {
    final root = Directory.current.path;
    ValidationUtils.ensureInitialized(root);

    final config = ValidationUtils.readConfig(root);
    if (!config.isMvvm) {
      stdout.writeln(
          '\x1B[31mError: This project uses Clean Architecture, not MVVM.\x1B[0m');
      stdout.writeln(
          'Use \x1B[1mflutter_architect create feature <name>\x1B[0m instead.');
      exit(1);
    }

    final rest = argResults!.rest;
    if (rest.isEmpty) {
      usageException(
          'Please provide a viewmodel name.\n  Example: flutter_architect create viewmodel Auth --feature auth');
    }

    final names = NameUtils(rest.first);
    final feature = argResults!['feature'] as String?;

    final targetDir = feature != null
        ? '$root/lib/features/${NameUtils(feature).snakeCase}/viewmodels'
        : '$root/lib/shared/viewmodels';

    final viewDir = feature != null
        ? '$root/lib/features/${NameUtils(feature).snakeCase}/views'
        : '$root/lib/shared/views';

    final serviceDir = feature != null
        ? '$root/lib/features/${NameUtils(feature).snakeCase}/services'
        : '$root/lib/shared/services';

    Directory(targetDir).createSync(recursive: true);
    Directory(viewDir).createSync(recursive: true);
    Directory(serviceDir).createSync(recursive: true);

    final serviceFile =
        File('$serviceDir/${names.snakeCase}_service.dart');
    if (!serviceFile.existsSync()) {
      serviceFile.writeAsStringSync(
          MvvmTemplates.service(names.pascalCase, names.snakeCase));
      stdout.writeln(
          '  \x1B[32m✓\x1B[0m  ${serviceFile.path.replaceAll('$root/', '')}');
    }

    final vmFile = File('$targetDir/${names.snakeCase}_viewmodel.dart');
    if (!vmFile.existsSync()) {
      vmFile.writeAsStringSync(
          MvvmTemplates.viewModel(names.pascalCase, names.snakeCase));
      stdout.writeln(
          '  \x1B[32m✓\x1B[0m  ${vmFile.path.replaceAll('$root/', '')}');
    }

    final viewFile = File('$viewDir/${names.snakeCase}_view.dart');
    if (!viewFile.existsSync()) {
      viewFile.writeAsStringSync(
        MvvmTemplates.view(
          names.pascalCase,
          names.snakeCase,
          useGetIt: config.useGetIt,
        ),
      );
      stdout.writeln(
          '  \x1B[32m✓\x1B[0m  ${viewFile.path.replaceAll('$root/', '')}');
    }

    stdout.writeln(
        '\n\x1B[32m✅  ViewModel "${names.pascalCase}ViewModel" created.\x1B[0m');
  }
}
