import 'dart:io';
import 'package:args/command_runner.dart';
import '../../utils/name_utils.dart';
import '../../utils/validation_utils.dart';

class ModelCreatorCommand extends Command<void> {
  @override
  final String name = 'model';

  @override
  final String description = 'Generate a Data Model class (with copyWith, fromJson, toJson, and Equatable).';

  @override
  String get invocation => 'flutter_architect create model <Name> [--feature <featureName>]';

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
      usageException('Please provide a model name.\n  Example: flutter_architect create model User --feature auth');
    }

    final names = NameUtils(rest.first);
    final feature = argResults!['feature'] as String?;

    final targetDir = feature != null
        ? '$root/lib/features/${NameUtils(feature).snakeCase}/data/models'
        : '$root/lib/shared/models';

    Directory(targetDir).createSync(recursive: true);

    final filePath = '$targetDir/${names.snakeCase}_model.dart';
    final content = '''import 'package:equatable/equatable.dart';

class ${names.pascalCase}Model extends Equatable {
  const ${names.pascalCase}Model({required this.id});

  final String id;

  factory ${names.pascalCase}Model.fromJson(Map<String, dynamic> json) {
    return ${names.pascalCase}Model(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }

  ${names.pascalCase}Model copyWith({String? id}) {
    return ${names.pascalCase}Model(id: id ?? this.id);
  }

  @override
  List<Object?> get props => [id];
}
''';

    _writeFile(filePath, content, root);
    stdout.writeln('\n\x1B[32m✅  Model "${names.pascalCase}Model" created.\x1B[0m');
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
