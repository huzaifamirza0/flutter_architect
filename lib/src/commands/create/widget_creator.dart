import 'dart:io';
import 'package:args/command_runner.dart';
import '../../utils/name_utils.dart';
import '../../utils/validation_utils.dart';

/// `flutter_architect create widget UserAvatar --feature profile`
/// or shared: `flutter_architect create widget AppButton`
class WidgetCreatorCommand extends Command<void> {
  @override
  final String name = 'widget';

  @override
  final String description =
      'Generate a reusable widget in a feature or in shared/widgets.';

  @override
  String get invocation =>
      'flutter_architect create widget <Name> [--feature <featureName>]';

  WidgetCreatorCommand() {
    argParser.addOption(
      'feature',
      abbr: 'f',
      help: 'Feature folder. If omitted, creates in lib/shared/widgets/.',
    );
  }

  @override
  Future<void> run() async {
    final root = Directory.current.path;
    ValidationUtils.ensureInitialized(root);

    final rest = argResults!.rest;
    if (rest.isEmpty) {
      usageException(
          'Please provide a widget name.\n  Example: flutter_architect create widget UserAvatar --feature profile');
    }

    final names = NameUtils(rest.first);
    final feature = argResults!['feature'] as String?;
    final config = ValidationUtils.readConfig(root);

    late final String targetDir;
    if (feature != null) {
      final featureSnake = NameUtils(feature).snakeCase;
      final featurePath = '$root/lib/features/$featureSnake';
      if (!Directory(featurePath).existsSync()) {
        stdout.writeln(
            '\x1B[31mError: Feature "$featureSnake" does not exist.\x1B[0m');
        exit(1);
      }
      targetDir = config.isMvvm
          ? '$featurePath/views/widgets'
          : '$featurePath/presentation/widgets';
    } else {
      targetDir = '$root/lib/shared/widgets';
    }

    Directory(targetDir).createSync(recursive: true);
    final filePath = '$targetDir/${names.snakeCase}_widget.dart';
    final content = '''import 'package:flutter/material.dart';

class ${names.pascalCase}Widget extends StatelessWidget {
  const ${names.pascalCase}Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''';

    final file = File(filePath);
    if (file.existsSync()) {
      stdout.writeln(
          '\x1B[33m  ~ ${filePath.replaceAll('$root/', '')} (already exists)\x1B[0m');
    } else {
      file.writeAsStringSync(content);
      stdout.writeln(
          '  \x1B[32m✓\x1B[0m  ${filePath.replaceAll('$root/', '').replaceAll('$root\\', '')}');
    }

    stdout.writeln(
        '\n\x1B[32m✅  Widget "${names.pascalCase}Widget" created.\x1B[0m');
  }
}
