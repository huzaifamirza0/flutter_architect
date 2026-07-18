import 'dart:io';
import 'package:args/command_runner.dart';
import '../../utils/name_utils.dart';
import '../../utils/validation_utils.dart';
import '../../templates/bloc_templates.dart';
import '../../templates/mvvm_templates.dart';

class FeatureCreatorCommand extends Command<void> {
  @override
  final String name = 'feature';

  @override
  final String description = 'Scaffold a full Clean Architecture feature module.';

  @override
  String get invocation => 'flutter_architect create feature <name>';

  FeatureCreatorCommand() {
    argParser.addOption(
      'state-management',
      abbr: 's',
      allowed: ['bloc', 'riverpod', 'provider', 'getx', 'none'],
      defaultsTo: 'bloc',
      help: 'State management to scaffold inside the feature.',
    );
  }

  @override
  Future<void> run() async {
    final root = Directory.current.path;
    ValidationUtils.ensureInitialized(root);

    final rest = argResults!.rest;
    if (rest.isEmpty) {
      usageException('Please provide a feature name.\n  Example: flutter_architect create feature auth');
    }

    final rawName = rest.first;
    final sm = argResults!['state-management'] as String;
    final names = NameUtils(rawName);
    final arch = ValidationUtils.readArchitecture(root);

    stdout.writeln('\n\x1B[34mCreating feature: ${names.pascalCase}\x1B[0m\n');

    if (arch == 'mvvm') {
      _generateMvvm(root, names);
    } else {
      _generateClean(root, names, sm);
    }

    stdout.writeln('\n\x1B[32m✅  Feature "${names.pascalCase}" created successfully!\x1B[0m');
  }

  // ── MVVM scaffold ─────────────────────────────────────────────────
  void _generateMvvm(String root, NameUtils names) {
    final featurePath = '$root/lib/features/${names.snakeCase}';
    final folders = [
      '$featurePath/models',
      '$featurePath/views/widgets',
      '$featurePath/viewmodels',
      '$root/test/features/${names.snakeCase}',
    ];
    _createFolders(root, folders);

    _write('$featurePath/models/${names.snakeCase}_model.dart',
        MvvmTemplates.model(names.pascalCase, names.snakeCase));
    _write('$featurePath/viewmodels/${names.snakeCase}_viewmodel.dart',
        MvvmTemplates.viewModel(names.pascalCase, names.snakeCase));
    _write('$featurePath/views/${names.snakeCase}_view.dart',
        MvvmTemplates.view(names.pascalCase, names.snakeCase));
  }

  // ── Clean Architecture scaffold ───────────────────────────────────
  void _generateClean(String root, NameUtils names, String sm) {
    final featurePath = '$root/lib/features/${names.snakeCase}';
    final folders = [
      '$featurePath/data/datasource',
      '$featurePath/data/models',
      '$featurePath/data/repository',
      '$featurePath/domain/entities',
      '$featurePath/domain/repository',
      '$featurePath/domain/usecases',
      '$featurePath/presentation/pages',
      '$featurePath/presentation/widgets',
      '$featurePath/routes',
    ];

    switch (sm) {
      case 'bloc':
        folders.add('$featurePath/presentation/bloc');
      case 'riverpod':
        folders.add('$featurePath/presentation/providers');
      case 'provider':
        folders.add('$featurePath/presentation/providers');
      case 'getx':
        folders.add('$featurePath/presentation/controllers');
        folders.add('$featurePath/bindings');
    }

    folders.addAll([
      '$root/test/features/${names.snakeCase}/data',
      '$root/test/features/${names.snakeCase}/domain',
      '$root/test/features/${names.snakeCase}/presentation',
    ]);

    _createFolders(root, folders);

    _write('$featurePath/domain/entities/${names.snakeCase}_entity.dart',
        _entityContent(names));
    _write('$featurePath/data/models/${names.snakeCase}_model.dart',
        _modelContent(names));
    _write('$featurePath/domain/repository/${names.snakeCase}_repository.dart',
        _repositoryAbstractContent(names));
    _write('$featurePath/data/repository/${names.snakeCase}_repository_impl.dart',
        _repositoryImplContent(names));
    _write('$featurePath/data/datasource/${names.snakeCase}_remote_datasource.dart',
        _datasourceAbstractContent(names));
    _write('$featurePath/data/datasource/${names.snakeCase}_remote_datasource_impl.dart',
        _datasourceImplContent(names));
    _write('$featurePath/presentation/pages/${names.snakeCase}_page.dart',
        _pageContent(names));
    _write('$featurePath/routes/${names.snakeCase}_routes.dart',
        _routesContent(names));

    switch (sm) {
      case 'bloc':
        _writeBlocFiles(featurePath, names);
      case 'riverpod':
        _writeRiverpodFiles(featurePath, names);
      case 'provider':
        _writeProviderFiles(featurePath, names);
      case 'getx':
        _writeGetXFiles(featurePath, names, root);
    }

    _write(
      '$root/test/features/${names.snakeCase}/domain/${names.snakeCase}_repository_test.dart',
      _testStubContent(names),
    );
  }

  void _createFolders(String root, List<String> folders) {
    for (final f in folders) {
      final dir = Directory(f);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
        File('$f/.gitkeep').writeAsStringSync('');
      }
      final display = f.replaceAll('$root/', '');
      stdout.writeln('  \x1B[32m✓\x1B[0m  $display');
    }
  }

  // ── file writers ──────────────────────────────────────────────────

  void _writeBlocFiles(String featurePath, NameUtils names) {
    _write(
      '$featurePath/presentation/bloc/${names.snakeCase}_bloc.dart',
      BlocTemplates.bloc(names),
    );
    _write(
      '$featurePath/presentation/bloc/${names.snakeCase}_event.dart',
      BlocTemplates.event(names),
    );
    _write(
      '$featurePath/presentation/bloc/${names.snakeCase}_state.dart',
      BlocTemplates.state(names),
    );
  }

  void _writeRiverpodFiles(String featurePath, NameUtils names) {
    _write(
      '$featurePath/presentation/providers/${names.snakeCase}_provider.dart',
      '''import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: replace with your actual state type
final ${names.camelCase}Provider = StateNotifierProvider<${names.pascalCase}Notifier, AsyncValue<void>>(
  (ref) => ${names.pascalCase}Notifier(),
);

class ${names.pascalCase}Notifier extends StateNotifier<AsyncValue<void>> {
  ${names.pascalCase}Notifier() : super(const AsyncValue.data(null));

  Future<void> load() async {
    state = const AsyncValue.loading();
    // TODO: call use-case / repository
    state = const AsyncValue.data(null);
  }
}
''',
    );
  }

  void _writeProviderFiles(String featurePath, NameUtils names) {
    _write(
      '$featurePath/presentation/providers/${names.snakeCase}_provider.dart',
      '''import 'package:flutter/foundation.dart';

class ${names.pascalCase}Provider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    // TODO: call use-case / repository
    _isLoading = false;
    notifyListeners();
  }
}
''',
    );
  }

  void _writeGetXFiles(String featurePath, NameUtils names, String root) {
    _write(
      '$featurePath/presentation/controllers/${names.snakeCase}_controller.dart',
      '''import 'package:get/get.dart';

class ${names.pascalCase}Controller extends GetxController {
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    // TODO: call use-case / repository
    isLoading.value = false;
  }
}
''',
    );
    _write(
      '$featurePath/bindings/${names.snakeCase}_binding.dart',
      '''import 'package:get/get.dart';
import '../presentation/controllers/${names.snakeCase}_controller.dart';

class ${names.pascalCase}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${names.pascalCase}Controller>(() => ${names.pascalCase}Controller());
  }
}
''',
    );
  }

  void _write(String path, String content) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
      file.writeAsStringSync(content);
      final display = path.replaceAll('${Directory.current.path}/', '');
      stdout.writeln('  \x1B[32m✓\x1B[0m  $display');
    }
  }

  // ── templates ─────────────────────────────────────────────────────

  String _entityContent(NameUtils n) => '''import 'package:equatable/equatable.dart';

class ${n.pascalCase}Entity extends Equatable {
  const ${n.pascalCase}Entity({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
''';

  String _modelContent(NameUtils n) => '''import '../../domain/entities/${n.snakeCase}_entity.dart';

class ${n.pascalCase}Model extends ${n.pascalCase}Entity {
  const ${n.pascalCase}Model({required super.id});

  factory ${n.pascalCase}Model.fromJson(Map<String, dynamic> json) {
    return ${n.pascalCase}Model(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }

  ${n.pascalCase}Model copyWith({String? id}) {
    return ${n.pascalCase}Model(id: id ?? this.id);
  }
}
''';

  String _repositoryAbstractContent(NameUtils n) => '''import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/${n.snakeCase}_entity.dart';

abstract class ${n.pascalCase}Repository {
  Future<Either<Failure, List<${n.pascalCase}Entity>>> getAll();
}
''';

  String _repositoryImplContent(NameUtils n) => '''import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/${n.snakeCase}_entity.dart';
import '../../domain/repository/${n.snakeCase}_repository.dart';
import '../datasource/${n.snakeCase}_remote_datasource.dart';

class ${n.pascalCase}RepositoryImpl implements ${n.pascalCase}Repository {
  const ${n.pascalCase}RepositoryImpl({required this.remoteDataSource});

  final ${n.pascalCase}RemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<${n.pascalCase}Entity>>> getAll() async {
    try {
      final result = await remoteDataSource.getAll();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
''';

  String _datasourceAbstractContent(NameUtils n) => '''import '../models/${n.snakeCase}_model.dart';

abstract class ${n.pascalCase}RemoteDataSource {
  Future<List<${n.pascalCase}Model>> getAll();
}
''';

  String _datasourceImplContent(NameUtils n) => '''import '../models/${n.snakeCase}_model.dart';
import '${n.snakeCase}_remote_datasource.dart';

class ${n.pascalCase}RemoteDataSourceImpl implements ${n.pascalCase}RemoteDataSource {
  // TODO: inject Dio / ApiClient
  const ${n.pascalCase}RemoteDataSourceImpl();

  @override
  Future<List<${n.pascalCase}Model>> getAll() async {
    // TODO: implement API call
    throw UnimplementedError();
  }
}
''';

  String _pageContent(NameUtils n) => '''import 'package:flutter/material.dart';

class ${n.pascalCase}Page extends StatelessWidget {
  const ${n.pascalCase}Page({super.key});

  static const routeName = '/${n.kebabCase}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${n.titleCase}')),
      body: const Center(child: Text('${n.titleCase} Page')),
    );
  }
}
''';

  String _routesContent(NameUtils n) => '''// Route constants for the ${n.pascalCase} feature.
// Register these in your app-level router (e.g. GoRouter or AutoRoute).
abstract class ${n.pascalCase}Routes {
  static const root = '/${n.kebabCase}';
}
''';

  String _testStubContent(NameUtils n) => '''import 'package:flutter_test/flutter_test.dart';

void main() {
  group('${n.pascalCase}Repository', () {
    test('getAll returns data', () {
      // TODO: implement test
      expect(true, isTrue);
    });
  });
}
''';
}
