import 'dart:io';
import 'package:args/command_runner.dart';
import '../../utils/name_utils.dart';
import '../../utils/validation_utils.dart';

class RepositoryCreatorCommand extends Command<void> {
  @override
  final String name = 'repository';

  @override
  final String description =
      'Generate a Domain Repository interface and Data Repository implementation.';

  @override
  String get invocation =>
      'flutter_architect create repository <Name> [--feature <featureName>]';

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

    final config = ValidationUtils.readConfig(root);
    if (config.isMvvm) {
      stdout.writeln(
          '\x1B[31mError: Repositories belong to Clean Architecture, not MVVM.\x1B[0m');
      stdout.writeln(
          'Use a \x1B[1mservice\x1B[0m inside the feature, or create a feature with '
          '\x1B[1mflutter_architect create feature <name>\x1B[0m.');
      exit(1);
    }

    final rest = argResults!.rest;
    if (rest.isEmpty) {
      usageException(
          'Please provide a repository name.\n  Example: flutter_architect create repository User --feature auth');
    }

    final names = NameUtils(rest.first);
    final feature = argResults!['feature'] as String?;

    late final String abstractDir;
    late final String implDir;
    if (feature != null) {
      final fn = NameUtils(feature).snakeCase;
      abstractDir = '$root/lib/features/$fn/domain/repositories';
      implDir = '$root/lib/features/$fn/data/repositories';
    } else {
      abstractDir = '$root/lib/shared/repositories';
      implDir = '$root/lib/shared/repositories';
    }

    Directory(abstractDir).createSync(recursive: true);
    Directory(implDir).createSync(recursive: true);

    _writeFile(
      '$abstractDir/${names.snakeCase}_repository.dart',
      '''import 'package:dartz/dartz.dart';
import '${feature != null ? '../../../../' : '../../'}core/errors/failures.dart';

abstract class ${names.pascalCase}Repository {
  // TODO: define repository contract methods.
  // Example:
  // Future<Either<Failure, ${names.pascalCase}Entity>> getById(String id);
}
''',
      root,
    );

    final implImport = feature != null
        ? "../../domain/repositories/${names.snakeCase}_repository.dart"
        : "${names.snakeCase}_repository.dart";
    final corePrefix = feature != null ? '../../../../' : '../../';

    _writeFile(
      '$implDir/${names.snakeCase}_repository_impl.dart',
      '''import 'package:dartz/dartz.dart';
import '${corePrefix}core/errors/exceptions.dart';
import '${corePrefix}core/errors/failures.dart';
import '$implImport';

class ${names.pascalCase}RepositoryImpl implements ${names.pascalCase}Repository {
  const ${names.pascalCase}RepositoryImpl();

  // TODO: implement repository methods.
  // Map ServerException → ServerFailure, CacheException → CacheFailure.
}
''',
      root,
    );

    stdout.writeln(
        '\n\x1B[32m✅  Repository "${names.pascalCase}Repository" created.\x1B[0m');
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
