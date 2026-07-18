import 'dart:io';
import 'package:args/command_runner.dart';
import '../../utils/name_utils.dart';
import '../../utils/validation_utils.dart';

class RepositoryCreatorCommand extends Command<void> {
  @override
  final String name = 'repository';

  @override
  final String description = 'Generate a Domain Repository interface and Data Repository implementation.';

  @override
  String get invocation => 'flutter_architect create repository <Name> [--feature <featureName>]';

  RepositoryCreatorCommand() {
    argParser.addOption(
      'feature',
      abbr: 'f',
      help: 'The feature folder to place this repository in (e.g. auth).',
    );
  }

  @override
  Future<void> run() async {
    final root = Directory.current.path;
    ValidationUtils.ensureInitialized(root);
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      usageException('Please provide a repository name.\n  Example: flutter_architect create repository User --feature auth');
    }

    final names = NameUtils(rest.first);
    final feature = argResults!['feature'] as String?;

    String abstractDir, implDir;
    if (feature != null) {
      final fn = NameUtils(feature).snakeCase;
      abstractDir = '$root/lib/features/$fn/domain/repository';
      implDir = '$root/lib/features/$fn/data/repository';
    } else {
      abstractDir = '$root/lib/shared/repository';
      implDir = '$root/lib/shared/repository';
    }

    Directory(abstractDir).createSync(recursive: true);
    Directory(implDir).createSync(recursive: true);

    // Abstract
    _writeFile(
      '$abstractDir/${names.snakeCase}_repository.dart',
      '''abstract class ${names.pascalCase}Repository {
  // TODO: define your repository contract methods here.
  // Example:
  // Future<Either<Failure, ${names.pascalCase}Entity>> getById(String id);
}
''',
      root,
    );

    // Implementation
    _writeFile(
      '$implDir/${names.snakeCase}_repository_impl.dart',
      '''import '${abstractDir == implDir ? '' : '../../domain/repository/'}${names.snakeCase}_repository.dart';

class ${names.pascalCase}RepositoryImpl implements ${names.pascalCase}Repository {
  const ${names.pascalCase}RepositoryImpl();

  // TODO: implement repository methods.
}
''',
      root,
    );

    stdout.writeln('\n\x1B[32m✅  Repository "${names.pascalCase}Repository" created.\x1B[0m');
  }

  void _writeFile(String path, String content, String root) {
    final file = File(path);
    if (file.existsSync()) {
      stdout.writeln('\x1B[33m  ~ ${path.replaceAll('$root/', '')} (already exists)\x1B[0m');
      return;
    }
    file.writeAsStringSync(content);
    stdout.writeln('  \x1B[32m✓\x1B[0m  ${path.replaceAll('$root/', '')}');
  }
}
