import 'dart:io';
import 'package:args/command_runner.dart';
import '../../utils/name_utils.dart';
import '../../utils/validation_utils.dart';
import '../../templates/bloc_templates.dart';
import '../../templates/clean_templates.dart';
import '../../templates/mvvm_templates.dart';

class FeatureCreatorCommand extends Command<void> {
  @override
  final String name = 'feature';

  @override
  final String description =
      'Scaffold a full feature module (Clean Architecture or MVVM).';

  @override
  String get invocation => 'flutter_architect create feature <name>';

  FeatureCreatorCommand() {
    argParser.addOption(
      'state-management',
      abbr: 's',
      allowed: ['bloc', 'riverpod', 'provider', 'getx', 'none'],
      help:
          'State management to scaffold. Defaults to value saved in architect.yaml.',
    );
  }

  @override
  Future<void> run() async {
    final root = Directory.current.path;
    ValidationUtils.ensureInitialized(root);

    final rest = argResults!.rest;
    if (rest.isEmpty) {
      usageException(
          'Please provide a feature name.\n  Example: flutter_architect create feature auth');
    }

    final config = ValidationUtils.readConfig(root);
    final rawName = rest.first;
    final sm = (argResults!['state-management'] as String?) ??
        config.stateManagement;
    final names = NameUtils(rawName);

    stdout.writeln('\n\x1B[34mCreating feature: ${names.pascalCase}\x1B[0m');
    stdout.writeln(
        '  Architecture: ${config.architecture} · State: $sm\n');

    if (config.isMvvm) {
      _generateMvvm(root, names, sm, config);
    } else {
      _generateClean(root, names, sm, config);
    }

    stdout.writeln(
        '\n\x1B[32m✅  Feature "${names.pascalCase}" created successfully!\x1B[0m');
  }

  // ── MVVM ───────────────────────────────────────────────────────────
  void _generateMvvm(
    String root,
    NameUtils names,
    String sm,
    ProjectConfig config,
  ) {
    final featurePath = '$root/lib/features/${names.snakeCase}';
    final folders = <String>[
      '$featurePath/models',
      '$featurePath/services',
      '$featurePath/views/widgets',
      '$root/test/features/${names.snakeCase}',
    ];

    switch (sm) {
      case 'bloc':
        folders.add('$featurePath/bloc');
      case 'riverpod':
        folders.add('$featurePath/providers');
      case 'getx':
        folders
          ..add('$featurePath/controllers')
          ..add('$featurePath/bindings');
      default:
        folders.add('$featurePath/viewmodels');
    }

    if (config.useGetIt && sm != 'getx' && sm != 'riverpod') {
      folders.add('$featurePath/di');
    }

    _createFolders(root, folders);

    _write(
      '$featurePath/models/${names.snakeCase}_model.dart',
      MvvmTemplates.model(names.pascalCase, names.snakeCase),
    );
    _write(
      '$featurePath/services/${names.snakeCase}_service.dart',
      MvvmTemplates.service(names.pascalCase, names.snakeCase),
    );

    switch (sm) {
      case 'bloc':
        _write(
          '$featurePath/bloc/${names.snakeCase}_bloc.dart',
          MvvmTemplates.blocViewModel(names.pascalCase, names.snakeCase),
        );
        _write(
          '$featurePath/bloc/${names.snakeCase}_event.dart',
          MvvmTemplates.blocEvent(names.pascalCase),
        );
        _write(
          '$featurePath/bloc/${names.snakeCase}_state.dart',
          MvvmTemplates.blocState(names.pascalCase, names.snakeCase),
        );
        _write(
          '$featurePath/views/${names.snakeCase}_view.dart',
          MvvmTemplates.blocView(
            names.pascalCase,
            names.snakeCase,
            useGetIt: config.useGetIt,
          ),
        );
      case 'riverpod':
        _write(
          '$featurePath/providers/${names.snakeCase}_provider.dart',
          MvvmTemplates.riverpodProvider(names.pascalCase, names.snakeCase),
        );
        _write(
          '$featurePath/views/${names.snakeCase}_view.dart',
          MvvmTemplates.riverpodView(names.pascalCase, names.snakeCase),
        );
      case 'getx':
        _write(
          '$featurePath/controllers/${names.snakeCase}_controller.dart',
          MvvmTemplates.getxController(names.pascalCase, names.snakeCase),
        );
        _write(
          '$featurePath/bindings/${names.snakeCase}_binding.dart',
          MvvmTemplates.getxBinding(names.pascalCase, names.snakeCase),
        );
        _write(
          '$featurePath/views/${names.snakeCase}_view.dart',
          MvvmTemplates.getxView(names.pascalCase, names.snakeCase),
        );
      default:
        _write(
          '$featurePath/viewmodels/${names.snakeCase}_viewmodel.dart',
          MvvmTemplates.viewModel(names.pascalCase, names.snakeCase),
        );
        _write(
          '$featurePath/views/${names.snakeCase}_view.dart',
          MvvmTemplates.view(
            names.pascalCase,
            names.snakeCase,
            useGetIt: config.useGetIt,
          ),
        );
    }

    if (config.useGetIt && sm != 'getx' && sm != 'riverpod') {
      _write(
        '$featurePath/di/${names.snakeCase}_injection.dart',
        MvvmTemplates.injection(
          names.pascalCase,
          names.snakeCase,
          stateManagement: sm == 'none' ? 'none' : sm,
        ),
      );
      ValidationUtils.registerFeatureInLocator(
        root: root,
        pascalName: names.pascalCase,
        snakeName: names.snakeCase,
        relativeImport:
            '../../features/${names.snakeCase}/di/${names.snakeCase}_injection.dart',
      );
    }
  }

  // ── Clean Architecture ─────────────────────────────────────────────
  void _generateClean(
    String root,
    NameUtils names,
    String sm,
    ProjectConfig config,
  ) {
    final featurePath = '$root/lib/features/${names.snakeCase}';
    final folders = <String>[
      '$featurePath/data/datasources',
      '$featurePath/data/models',
      '$featurePath/data/repositories',
      '$featurePath/domain/entities',
      '$featurePath/domain/repositories',
      '$featurePath/domain/usecases',
      '$featurePath/presentation/pages',
      '$featurePath/presentation/widgets',
      '$featurePath/routes',
      '$root/test/features/${names.snakeCase}/data',
      '$root/test/features/${names.snakeCase}/domain',
      '$root/test/features/${names.snakeCase}/presentation',
    ];

    switch (sm) {
      case 'bloc':
        folders.add('$featurePath/presentation/bloc');
      case 'riverpod':
      case 'provider':
        folders.add('$featurePath/presentation/providers');
      case 'getx':
        folders
          ..add('$featurePath/presentation/controllers')
          ..add('$featurePath/bindings');
    }

    if (config.useGetIt) {
      folders.add('$featurePath/di');
    }

    _createFolders(root, folders);

    // Domain
    _write(
      '$featurePath/domain/entities/${names.snakeCase}_entity.dart',
      CleanTemplates.entity(names),
    );
    _write(
      '$featurePath/domain/repositories/${names.snakeCase}_repository.dart',
      CleanTemplates.repository(names),
    );
    _write(
      '$featurePath/domain/usecases/get_all_${names.snakeCase}_usecase.dart',
      CleanTemplates.getAllUseCase(names),
    );

    // Data
    _write(
      '$featurePath/data/models/${names.snakeCase}_model.dart',
      CleanTemplates.model(names),
    );
    _write(
      '$featurePath/data/datasources/${names.snakeCase}_remote_datasource.dart',
      CleanTemplates.remoteDatasource(names),
    );
    _write(
      '$featurePath/data/datasources/${names.snakeCase}_remote_datasource_impl.dart',
      CleanTemplates.remoteDatasourceImpl(names),
    );

    if (config.useHive) {
      _write(
        '$featurePath/data/datasources/${names.snakeCase}_local_datasource.dart',
        CleanTemplates.localDatasource(names),
      );
      _write(
        '$featurePath/data/datasources/${names.snakeCase}_local_datasource_impl.dart',
        CleanTemplates.localDatasourceImpl(names),
      );
    }

    _write(
      '$featurePath/data/repositories/${names.snakeCase}_repository_impl.dart',
      CleanTemplates.repositoryImpl(names, useHive: config.useHive),
    );

    // Presentation
    switch (sm) {
      case 'bloc':
        _writeBlocFiles(featurePath, names);
        _write(
          '$featurePath/presentation/pages/${names.snakeCase}_page.dart',
          CleanTemplates.pageBloc(names, useGetIt: config.useGetIt),
        );
      case 'riverpod':
        _writeRiverpodFiles(featurePath, names);
        _write(
          '$featurePath/presentation/pages/${names.snakeCase}_page.dart',
          CleanTemplates.pageRiverpod(names),
        );
      case 'provider':
        _writeProviderFiles(featurePath, names);
        _write(
          '$featurePath/presentation/pages/${names.snakeCase}_page.dart',
          CleanTemplates.pageProvider(names, useGetIt: config.useGetIt),
        );
      case 'getx':
        _writeGetXFiles(featurePath, names);
        _write(
          '$featurePath/presentation/pages/${names.snakeCase}_page.dart',
          CleanTemplates.pageGetx(names),
        );
      default:
        _write(
          '$featurePath/presentation/pages/${names.snakeCase}_page.dart',
          CleanTemplates.pagePlain(names),
        );
    }

    _write(
      '$featurePath/routes/${names.snakeCase}_routes.dart',
      CleanTemplates.routes(names),
    );
    _write(
      '$root/test/features/${names.snakeCase}/domain/${names.snakeCase}_repository_test.dart',
      CleanTemplates.testStub(names),
    );

    if (config.useGetIt) {
      _write(
        '$featurePath/di/${names.snakeCase}_injection.dart',
        CleanTemplates.injection(
          names,
          stateManagement: sm,
          useHive: config.useHive,
        ),
      );
      ValidationUtils.registerFeatureInLocator(
        root: root,
        pascalName: names.pascalCase,
        snakeName: names.snakeCase,
        relativeImport:
            '../../features/${names.snakeCase}/di/${names.snakeCase}_injection.dart',
      );
    }
  }

  void _createFolders(String root, List<String> folders) {
    for (final f in folders) {
      final dir = Directory(f);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
        File('$f/.gitkeep').writeAsStringSync('');
      }
      final display = f.replaceAll('$root/', '').replaceAll('$root\\', '');
      stdout.writeln('  \x1B[32m✓\x1B[0m  $display');
    }
  }

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
import '../../../../core/base/usecase.dart';
import '../../domain/entities/${names.snakeCase}_entity.dart';
import '../../domain/usecases/get_all_${names.snakeCase}_usecase.dart';

/// Override this in tests / bootstrap with a real [GetAll${names.pascalCase}UseCase].
final getAll${names.pascalCase}UseCaseProvider = Provider<GetAll${names.pascalCase}UseCase>(
  (ref) => throw UnimplementedError(
    'Override getAll${names.pascalCase}UseCaseProvider with a real use case',
  ),
);

final ${names.camelCase}Provider = StateNotifierProvider<${names.pascalCase}Notifier,
    AsyncValue<List<${names.pascalCase}Entity>>>(
  (ref) => ${names.pascalCase}Notifier(ref.watch(getAll${names.pascalCase}UseCaseProvider)),
);

class ${names.pascalCase}Notifier
    extends StateNotifier<AsyncValue<List<${names.pascalCase}Entity>>> {
  ${names.pascalCase}Notifier(this._getAll) : super(const AsyncValue.loading()) {
    load();
  }

  final GetAll${names.pascalCase}UseCase _getAll;

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _getAll(const NoParams());
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      AsyncValue.data,
    );
  }
}
''',
    );
  }

  void _writeProviderFiles(String featurePath, NameUtils names) {
    _write(
      '$featurePath/presentation/providers/${names.snakeCase}_provider.dart',
      '''import 'package:flutter/foundation.dart';
import '../../../../core/base/usecase.dart';
import '../../domain/entities/${names.snakeCase}_entity.dart';
import '../../domain/usecases/get_all_${names.snakeCase}_usecase.dart';

class ${names.pascalCase}Provider extends ChangeNotifier {
  ${names.pascalCase}Provider(this._getAll);

  final GetAll${names.pascalCase}UseCase _getAll;

  bool _isLoading = false;
  String? _errorMessage;
  List<${names.pascalCase}Entity> _items = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<${names.pascalCase}Entity> get items => _items;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getAll(const NoParams());
    result.fold(
      (failure) => _errorMessage = failure.message,
      (items) => _items = items,
    );

    _isLoading = false;
    notifyListeners();
  }
}
''',
    );
  }

  void _writeGetXFiles(String featurePath, NameUtils names) {
    _write(
      '$featurePath/presentation/controllers/${names.snakeCase}_controller.dart',
      '''import 'package:get/get.dart';
import '../../../../core/base/usecase.dart';
import '../../domain/entities/${names.snakeCase}_entity.dart';
import '../../domain/usecases/get_all_${names.snakeCase}_usecase.dart';

class ${names.pascalCase}Controller extends GetxController {
  ${names.pascalCase}Controller(this._getAll);

  final GetAll${names.pascalCase}UseCase _getAll;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final items = <${names.pascalCase}Entity>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _getAll(const NoParams());
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) => items.assignAll(data),
    );
    isLoading.value = false;
  }
}
''',
    );
    _write(
      '$featurePath/bindings/${names.snakeCase}_binding.dart',
      '''import 'package:get/get.dart';
import '../domain/usecases/get_all_${names.snakeCase}_usecase.dart';
import '../presentation/controllers/${names.snakeCase}_controller.dart';

class ${names.pascalCase}Binding extends Bindings {
  @override
  void dependencies() {
    // TODO: register repository, then:
    // Get.lazyPut(() => GetAll${names.pascalCase}UseCase(Get.find()));
    // Get.lazyPut(() => ${names.pascalCase}Controller(Get.find()));
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
      final root = Directory.current.path;
      final display = path.replaceAll('$root/', '').replaceAll('$root\\', '');
      stdout.writeln('  \x1B[32m✓\x1B[0m  $display');
    }
  }
}
