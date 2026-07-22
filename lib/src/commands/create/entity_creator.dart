import 'dart:io';
import 'package:args/command_runner.dart';
import '../../utils/name_utils.dart';
import '../../utils/validation_utils.dart';

class EntityCreatorCommand extends Command<void> {
  @override
  final String name = 'entity';

  @override
  final String description = 'Generate a domain entity with Equatable.';

  @override
  String get invocation =>
      'flutter_architect create entity <Name> [--feature <featureName>]';

  EntityCreatorCommand() {
    argParser.addOption(
      'feature',
      abbr: 'f',
      help:
          'Feature this entity belongs to. If omitted, creates in lib/shared/entities/.',
    );
  }

  @override
  Future<void> run() async {
    final root = Directory.current.path;
    ValidationUtils.ensureInitialized(root);

    final config = ValidationUtils.readConfig(root);
    if (config.isMvvm) {
      stdout.writeln(
          '\x1B[31mError: Entities belong to Clean Architecture, not MVVM.\x1B[0m');
      stdout.writeln(
          'Use \x1B[1mflutter_architect create model <name>\x1B[0m instead.');
      exit(1);
    }

    final rest = argResults!.rest;
    if (rest.isEmpty) {
      usageException(
          'Please provide an entity name.\n  Example: flutter_architect create entity User --feature auth');
    }

    final names = NameUtils(rest.first);
    final feature = argResults!['feature'] as String?;

    final targetDir = feature != null
        ? '$root/lib/features/${NameUtils(feature).snakeCase}/domain/entities'
        : '$root/lib/shared/entities';

    Directory(targetDir).createSync(recursive: true);

    final filePath = '$targetDir/${names.snakeCase}_entity.dart';
    final content = '''import 'package:equatable/equatable.dart';

class ${names.pascalCase}Entity extends Equatable {
  const ${names.pascalCase}Entity({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
''';

    _writeFile(filePath, content, root);
    stdout.writeln(
        '\n\x1B[32m✅  Entity "${names.pascalCase}Entity" created.\x1B[0m');
  }

  void _writeFile(String path, String content, String root) {
    final file = File(path);
    if (file.existsSync()) {
      stdout.writeln(
          '\x1B[33m  ~ ${path.replaceAll('$root/', '')} (already exists)\x1B[0m');
      return;
    }
    file.writeAsStringSync(content);
    stdout.writeln('  \x1B[32m✓\x1B[0m  ${path.replaceAll('$root/', '')}');
  }
}
