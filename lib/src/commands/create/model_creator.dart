import 'dart:io';
import 'package:args/command_runner.dart';
import '../../utils/name_utils.dart';
import '../../utils/validation_utils.dart';

class ModelCreatorCommand extends Command<void> {
  @override
  final String name = 'model';

  @override
  final String description =
      'Generate a Data Model class (fromJson, toJson, copyWith, toEntity).';

  @override
  String get invocation =>
      'flutter_architect create model <Name> [--feature <featureName>]';

  ModelCreatorCommand() {
    argParser.addOption(
      'feature',
      abbr: 'f',
      help: 'The feature folder to place this model in (e.g. auth).',
    );
  }

  @override
  Future<void> run() async {
    final root = Directory.current.path;
    ValidationUtils.ensureInitialized(root);

    final rest = argResults!.rest;
    if (rest.isEmpty) {
      usageException(
          'Please provide a model name.\n  Example: flutter_architect create model User --feature auth');
    }

    final names = NameUtils(rest.first);
    final feature = argResults!['feature'] as String?;
    final config = ValidationUtils.readConfig(root);

    final targetDir = feature != null
        ? config.isMvvm
            ? '$root/lib/features/${NameUtils(feature).snakeCase}/models'
            : '$root/lib/features/${NameUtils(feature).snakeCase}/data/models'
        : '$root/lib/shared/models';

    Directory(targetDir).createSync(recursive: true);

    final filePath = '$targetDir/${names.snakeCase}_model.dart';
    final String content;
    if (config.isClean && feature != null) {
      content = '''import '../../domain/entities/${names.snakeCase}_entity.dart';

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

  ${names.pascalCase}Model copyWith({String? id}) {
    return ${names.pascalCase}Model(id: id ?? this.id);
  }
}
''';
    } else {
      content = '''class ${names.pascalCase}Model {
  const ${names.pascalCase}Model({required this.id});

  final String id;

  factory ${names.pascalCase}Model.fromJson(Map<String, dynamic> json) {
    return ${names.pascalCase}Model(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id};

  ${names.pascalCase}Model copyWith({String? id}) {
    return ${names.pascalCase}Model(id: id ?? this.id);
  }
}
''';
    }

    _writeFile(filePath, content, root);
    stdout.writeln(
        '\n\x1B[32m✅  Model "${names.pascalCase}Model" created.\x1B[0m');
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
