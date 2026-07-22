import 'dart:io';
import 'package:args/command_runner.dart';
import '../../utils/name_utils.dart';
import '../../utils/validation_utils.dart';

/// `flutter_architect create datasource User --feature auth [--local]`
class DatasourceCreatorCommand extends Command<void> {
  @override
  final String name = 'datasource';

  @override
  final String description =
      'Generate remote (and optional local) datasource stubs for a feature.';

  @override
  String get invocation =>
      'flutter_architect create datasource <Name> --feature <featureName> [--local]';

  DatasourceCreatorCommand() {
    argParser.addOption(
      'feature',
      abbr: 'f',
      help: 'Feature folder (required for Clean Architecture).',
    );
    argParser.addFlag(
      'local',
      negatable: false,
      help: 'Also generate a local datasource stub.',
    );
  }

  @override
  Future<void> run() async {
    final root = Directory.current.path;
    ValidationUtils.ensureInitialized(root);

    final config = ValidationUtils.readConfig(root);
    if (config.isMvvm) {
      stdout.writeln(
          '\x1B[31mError: Datasources belong to Clean Architecture.\x1B[0m');
      stdout.writeln(
          'For MVVM, add methods to a service under features/<name>/services/.');
      exit(1);
    }

    final rest = argResults!.rest;
    if (rest.isEmpty) {
      usageException(
          'Please provide a datasource name.\n  Example: flutter_architect create datasource User --feature auth --local');
    }

    final feature = argResults!['feature'] as String?;
    if (feature == null || feature.isEmpty) {
      usageException('Please provide --feature <name>.');
    }

    final withLocal =
        (argResults!['local'] as bool) || config.useHive;
    final names = NameUtils(rest.first);
    final featureSnake = NameUtils(feature).snakeCase;
    final featurePath = '$root/lib/features/$featureSnake';

    if (!Directory(featurePath).existsSync()) {
      stdout.writeln(
          '\x1B[31mError: Feature "$featureSnake" does not exist.\x1B[0m');
      exit(1);
    }

    final dsDir = '$featurePath/data/datasources';
    final modelsDir = '$featurePath/data/models';
    Directory(dsDir).createSync(recursive: true);
    Directory(modelsDir).createSync(recursive: true);

    // Ensure a matching model exists so generated datasources analyze cleanly.
    _write(
      root,
      '$modelsDir/${names.snakeCase}_model.dart',
      '''import '../../domain/entities/${names.snakeCase}_entity.dart';

class ${names.pascalCase}Model {
  const ${names.pascalCase}Model({required this.id});

  final String id;

  factory ${names.pascalCase}Model.fromJson(Map<String, dynamic> json) {
    return ${names.pascalCase}Model(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id};

  ${names.pascalCase}Entity toEntity() => ${names.pascalCase}Entity(id: id);

  factory ${names.pascalCase}Model.fromEntity(${names.pascalCase}Entity entity) {
    return ${names.pascalCase}Model(id: entity.id);
  }
}
''',
    );

    final entityPath =
        '$featurePath/domain/entities/${names.snakeCase}_entity.dart';
    _write(
      root,
      entityPath,
      '''import 'package:equatable/equatable.dart';

class ${names.pascalCase}Entity extends Equatable {
  const ${names.pascalCase}Entity({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
''',
    );

    _write(
      root,
      '$dsDir/${names.snakeCase}_remote_datasource.dart',
      '''import '../models/${names.snakeCase}_model.dart';

abstract class ${names.pascalCase}RemoteDataSource {
  Future<List<${names.pascalCase}Model>> getAll();
}
''',
    );
    _write(
      root,
      '$dsDir/${names.snakeCase}_remote_datasource_impl.dart',
      '''import '../../../../core/errors/exceptions.dart';
import '../models/${names.snakeCase}_model.dart';
import '${names.snakeCase}_remote_datasource.dart';

class ${names.pascalCase}RemoteDataSourceImpl
    implements ${names.pascalCase}RemoteDataSource {
  const ${names.pascalCase}RemoteDataSourceImpl();

  @override
  Future<List<${names.pascalCase}Model>> getAll() async {
    try {
      // TODO: implement API call
      throw const ServerException('Not implemented');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
''',
    );

    if (withLocal) {
      _write(
        root,
        '$dsDir/${names.snakeCase}_local_datasource.dart',
        '''import '../models/${names.snakeCase}_model.dart';

abstract class ${names.pascalCase}LocalDataSource {
  Future<List<${names.pascalCase}Model>> getCached();
  Future<void> cacheAll(List<${names.pascalCase}Model> items);
}
''',
      );
      _write(
        root,
        '$dsDir/${names.snakeCase}_local_datasource_impl.dart',
        '''import '../../../../core/errors/exceptions.dart';
import '../models/${names.snakeCase}_model.dart';
import '${names.snakeCase}_local_datasource.dart';

class ${names.pascalCase}LocalDataSourceImpl
    implements ${names.pascalCase}LocalDataSource {
  const ${names.pascalCase}LocalDataSourceImpl();

  @override
  Future<List<${names.pascalCase}Model>> getCached() async {
    try {
      return const [];
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheAll(List<${names.pascalCase}Model> items) async {
    try {
      // TODO: write to local storage
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
''',
      );
    }

    stdout.writeln(
        '\n\x1B[32m✅  Datasource "${names.pascalCase}" created.\x1B[0m');
  }

  void _write(String root, String path, String content) {
    final file = File(path);
    if (file.existsSync()) {
      stdout.writeln(
          '\x1B[33m  ~ ${path.replaceAll('$root/', '')} (already exists)\x1B[0m');
      return;
    }
    file.writeAsStringSync(content);
    stdout.writeln(
        '  \x1B[32m✓\x1B[0m  ${path.replaceAll('$root/', '').replaceAll('$root\\', '')}');
  }
}
