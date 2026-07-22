import 'dart:io';
import 'package:args/command_runner.dart';
import '../../utils/name_utils.dart';
import '../../utils/validation_utils.dart';

class UsecaseCreatorCommand extends Command<void> {
  @override
  final String name = 'usecase';

  @override
  final String description =
      'Generate a UseCase implementing the Callable Class pattern with error handling.';

  @override
  String get invocation =>
      'flutter_architect create usecase <Name> [--feature <featureName>]';

  UsecaseCreatorCommand() {
    argParser.addOption(
      'feature',
      abbr: 'f',
      help: 'The feature folder to place this usecase in (e.g. auth).',
    );
  }

  @override
  Future<void> run() async {
    final root = Directory.current.path;
    ValidationUtils.ensureInitialized(root);

    final config = ValidationUtils.readConfig(root);
    if (config.isMvvm) {
      stdout.writeln(
          '\x1B[31mError: UseCases belong to Clean Architecture, not MVVM.\x1B[0m');
      stdout.writeln(
          'Use \x1B[1mflutter_architect create viewmodel <name>\x1B[0m instead.');
      exit(1);
    }

    final rest = argResults!.rest;
    if (rest.isEmpty) {
      usageException(
          'Please provide a use-case name.\n  Example: flutter_architect create usecase Login --feature auth');
    }

    final names = NameUtils(rest.first);
    final feature = argResults!['feature'] as String?;

    final targetDir = feature != null
        ? '$root/lib/features/${NameUtils(feature).snakeCase}/domain/usecases'
        : '$root/lib/shared/usecases';

    Directory(targetDir).createSync(recursive: true);

    final corePrefix = feature != null ? '../../../../' : '../../';
    final repoImport = '../repositories/${names.snakeCase}_repository.dart';

    final filePath = '$targetDir/${names.snakeCase}_usecase.dart';
    final content = '''import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '${corePrefix}core/base/usecase.dart';
import '${corePrefix}core/errors/failures.dart';
import '$repoImport';

class ${names.pascalCase}UseCase implements UseCase<void, ${names.pascalCase}Params> {
  const ${names.pascalCase}UseCase(this.repository);

  final ${names.pascalCase}Repository repository;

  @override
  Future<Either<Failure, void>> call(${names.pascalCase}Params params) async {
    // return await repository.doSomething(params);
    throw UnimplementedError();
  }
}

class ${names.pascalCase}Params extends Equatable {
  const ${names.pascalCase}Params();

  @override
  List<Object> get props => [];
}
''';
    _writeFile(filePath, content, root);
    stdout.writeln(
        '\n\x1B[32m✅  UseCase "${names.pascalCase}UseCase" created.\x1B[0m');
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
