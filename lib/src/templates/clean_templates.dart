import '../utils/name_utils.dart';

/// Templates for Clean Architecture feature scaffolding.
abstract class CleanTemplates {
  // ── Entity ─────────────────────────────────────────────────────────
  static String entity(NameUtils n) => '''import 'package:equatable/equatable.dart';

class ${n.pascalCase}Entity extends Equatable {
  const ${n.pascalCase}Entity({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
''';

  // ── Model (composition + toEntity, not inheritance) ─────────────────
  static String model(NameUtils n) => '''import '../../domain/entities/${n.snakeCase}_entity.dart';

class ${n.pascalCase}Model {
  const ${n.pascalCase}Model({required this.id});

  final String id;

  factory ${n.pascalCase}Model.fromJson(Map<String, dynamic> json) {
    return ${n.pascalCase}Model(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id};

  ${n.pascalCase}Entity toEntity() => ${n.pascalCase}Entity(id: id);

  factory ${n.pascalCase}Model.fromEntity(${n.pascalCase}Entity entity) {
    return ${n.pascalCase}Model(id: entity.id);
  }

  ${n.pascalCase}Model copyWith({String? id}) {
    return ${n.pascalCase}Model(id: id ?? this.id);
  }
}
''';

  // ── Domain repository ──────────────────────────────────────────────
  static String repository(NameUtils n) => '''import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/${n.snakeCase}_entity.dart';

abstract class ${n.pascalCase}Repository {
  Future<Either<Failure, List<${n.pascalCase}Entity>>> getAll();
}
''';

  // ── Repository impl ────────────────────────────────────────────────
  static String repositoryImpl(NameUtils n, {required bool useHive}) {
    final localField = useHive
        ? '''
  final ${n.pascalCase}LocalDataSource? localDataSource;
'''
        : '';
    final localParam = useHive ? 'this.localDataSource,\n    ' : '';
    final localImport = useHive
        ? "import '../datasources/${n.snakeCase}_local_datasource.dart';\n"
        : '';
    final cacheWrite = useHive
        ? '''
      await localDataSource?.cacheAll(remote);
'''
        : '';
    final cacheFallback = useHive
        ? '''
    } on ServerException catch (e) {
      final cached = await localDataSource?.getCached();
      if (cached != null && cached.isNotEmpty) {
        return Right(cached.map((m) => m.toEntity()).toList());
      }
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
'''
        : '''
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
''';

    return '''import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/${n.snakeCase}_entity.dart';
import '../../domain/repositories/${n.snakeCase}_repository.dart';
import '../datasources/${n.snakeCase}_remote_datasource.dart';
$localImport
class ${n.pascalCase}RepositoryImpl implements ${n.pascalCase}Repository {
  const ${n.pascalCase}RepositoryImpl({
    required this.remoteDataSource,
    $localParam required this.networkInfo,
  });

  final ${n.pascalCase}RemoteDataSource remoteDataSource;
$localField  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<${n.pascalCase}Entity>>> getAll() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final remote = await remoteDataSource.getAll();
$cacheWrite      return Right(remote.map((m) => m.toEntity()).toList());
$cacheFallback    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
''';
  }

  // ── Remote datasource ──────────────────────────────────────────────
  static String remoteDatasource(NameUtils n) => '''import '../models/${n.snakeCase}_model.dart';

abstract class ${n.pascalCase}RemoteDataSource {
  Future<List<${n.pascalCase}Model>> getAll();
}
''';

  static String remoteDatasourceImpl(NameUtils n) => '''import '../../../../core/errors/exceptions.dart';
import '../models/${n.snakeCase}_model.dart';
import '${n.snakeCase}_remote_datasource.dart';

class ${n.pascalCase}RemoteDataSourceImpl implements ${n.pascalCase}RemoteDataSource {
  // TODO: inject ApiClient / Dio
  const ${n.pascalCase}RemoteDataSourceImpl();

  @override
  Future<List<${n.pascalCase}Model>> getAll() async {
    try {
      // TODO: implement API call
      // final response = await apiClient.dio.get('/${n.snakeCase}');
      // return (response.data as List)
      //     .map((e) => ${n.pascalCase}Model.fromJson(e as Map<String, dynamic>))
      //     .toList();
      throw const ServerException('Not implemented');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
''';

  // ── Local datasource (Hive / offline cache) ────────────────────────
  static String localDatasource(NameUtils n) => '''import '../models/${n.snakeCase}_model.dart';

abstract class ${n.pascalCase}LocalDataSource {
  Future<List<${n.pascalCase}Model>> getCached();
  Future<void> cacheAll(List<${n.pascalCase}Model> items);
}
''';

  static String localDatasourceImpl(NameUtils n) => '''import '../../../../core/errors/exceptions.dart';
import '../models/${n.snakeCase}_model.dart';
import '${n.snakeCase}_local_datasource.dart';

class ${n.pascalCase}LocalDataSourceImpl implements ${n.pascalCase}LocalDataSource {
  // TODO: inject Hive box / Drift dao
  const ${n.pascalCase}LocalDataSourceImpl();

  @override
  Future<List<${n.pascalCase}Model>> getCached() async {
    try {
      // TODO: read from local storage
      return const [];
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheAll(List<${n.pascalCase}Model> items) async {
    try {
      // TODO: write to local storage
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
''';

  // ── UseCase ────────────────────────────────────────────────────────
  static String getAllUseCase(NameUtils n) => '''import 'package:dartz/dartz.dart';
import '../../../../core/base/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/${n.snakeCase}_entity.dart';
import '../repositories/${n.snakeCase}_repository.dart';

class GetAll${n.pascalCase}UseCase
    implements UseCase<List<${n.pascalCase}Entity>, NoParams> {
  const GetAll${n.pascalCase}UseCase(this.repository);

  final ${n.pascalCase}Repository repository;

  @override
  Future<Either<Failure, List<${n.pascalCase}Entity>>> call(NoParams params) {
    return repository.getAll();
  }
}
''';

  // ── Page ───────────────────────────────────────────────────────────
  static String pageBloc(NameUtils n, {required bool useGetIt}) {
    final create = useGetIt
        ? "sl<${n.pascalCase}Bloc>()..add(const Load${n.pascalCase}Event())"
        : '${n.pascalCase}Bloc(/* TODO: inject GetAll${n.pascalCase}UseCase */)..add(const Load${n.pascalCase}Event())';
    final slImport = useGetIt
        ? "import '../../../../app/di/service_locator.dart';\n"
        : '';

    return '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
${slImport}import '../bloc/${n.snakeCase}_bloc.dart';
import '../bloc/${n.snakeCase}_event.dart';
import '../bloc/${n.snakeCase}_state.dart';

class ${n.pascalCase}Page extends StatelessWidget {
  const ${n.pascalCase}Page({super.key});

  static const routeName = '/${n.kebabCase}';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => $create,
      child: const _${n.pascalCase}View(),
    );
  }
}

class _${n.pascalCase}View extends StatelessWidget {
  const _${n.pascalCase}View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${n.titleCase}')),
      body: BlocBuilder<${n.pascalCase}Bloc, ${n.pascalCase}State>(
        builder: (context, state) {
          if (state is ${n.pascalCase}Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ${n.pascalCase}Error) {
            return Center(child: Text(state.message));
          }
          if (state is ${n.pascalCase}Loaded) {
            return Center(child: Text('${n.titleCase} loaded (\${state.items.length} items)'));
          }
          return const Center(child: Text('${n.titleCase} Page'));
        },
      ),
    );
  }
}
''';
  }

  static String pageRiverpod(NameUtils n) => '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/${n.snakeCase}_provider.dart';

class ${n.pascalCase}Page extends ConsumerWidget {
  const ${n.pascalCase}Page({super.key});

  static const routeName = '/${n.kebabCase}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${n.camelCase}Provider);

    return Scaffold(
      appBar: AppBar(title: const Text('${n.titleCase}')),
      body: state.when(
        data: (_) => const Center(child: Text('${n.titleCase} Page')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
''';

  static String pageProvider(NameUtils n, {required bool useGetIt}) {
    final create = useGetIt
        ? 'sl<${n.pascalCase}Provider>()'
        : '${n.pascalCase}Provider(/* TODO: inject GetAll${n.pascalCase}UseCase */)';
    final slImport = useGetIt
        ? "import '../../../../app/di/service_locator.dart';\n"
        : '';

    return '''import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
${slImport}import '../providers/${n.snakeCase}_provider.dart';

class ${n.pascalCase}Page extends StatelessWidget {
  const ${n.pascalCase}Page({super.key});

  static const routeName = '/${n.kebabCase}';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => $create..load(),
      child: const _${n.pascalCase}View(),
    );
  }
}

class _${n.pascalCase}View extends StatelessWidget {
  const _${n.pascalCase}View();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<${n.pascalCase}Provider>();

    return Scaffold(
      appBar: AppBar(title: const Text('${n.titleCase}')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : const Center(child: Text('${n.titleCase} Page')),
    );
  }
}
''';
  }

  static String pageGetx(NameUtils n) => '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/${n.snakeCase}_controller.dart';

class ${n.pascalCase}Page extends GetView<${n.pascalCase}Controller> {
  const ${n.pascalCase}Page({super.key});

  static const routeName = '/${n.kebabCase}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${n.titleCase}')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!));
        }
        return const Center(child: Text('${n.titleCase} Page'));
      }),
    );
  }
}
''';

  static String pagePlain(NameUtils n) => '''import 'package:flutter/material.dart';

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

  static String routes(NameUtils n) => '''// Route constants for the ${n.pascalCase} feature.
// Register these in your app-level router (e.g. GoRouter or AutoRoute).
abstract class ${n.pascalCase}Routes {
  static const root = '/${n.kebabCase}';
}
''';

  static String testStub(NameUtils n) => '''import 'package:flutter_test/flutter_test.dart';

void main() {
  group('${n.pascalCase}Repository', () {
    test('getAll returns data', () {
      // TODO: implement test
      expect(true, isTrue);
    });
  });
}
''';

  // ── DI registration for a feature ──────────────────────────────────
  static String injection(NameUtils n, {
    required String stateManagement,
    required bool useHive,
  }) {
    final localRegs = useHive
        ? '''
  sl.registerLazySingleton<${n.pascalCase}LocalDataSource>(
    () => ${n.pascalCase}LocalDataSourceImpl(),
  );
'''
        : '';
    final localImport = useHive
        ? "import '../data/datasources/${n.snakeCase}_local_datasource.dart';\n"
          "import '../data/datasources/${n.snakeCase}_local_datasource_impl.dart';\n"
        : '';
    final localArg = useHive ? 'localDataSource: sl(),\n      ' : '';

    String presentationRegs;
    String presentationImports;
    switch (stateManagement) {
      case 'bloc':
        presentationImports =
            "import '../presentation/bloc/${n.snakeCase}_bloc.dart';\n";
        presentationRegs = '''
  sl.registerFactory(() => ${n.pascalCase}Bloc(sl()));
''';
      case 'provider':
        presentationImports =
            "import '../presentation/providers/${n.snakeCase}_provider.dart';\n";
        presentationRegs = '''
  sl.registerFactory(() => ${n.pascalCase}Provider(sl()));
''';
      case 'getx':
        presentationImports = '';
        presentationRegs = '  // GetX: register via ${n.pascalCase}Binding\n';
      default:
        presentationImports = '';
        presentationRegs = '';
    }

    return '''import '../../../app/di/service_locator.dart';
import '../data/datasources/${n.snakeCase}_remote_datasource.dart';
import '../data/datasources/${n.snakeCase}_remote_datasource_impl.dart';
$localImport import '../data/repositories/${n.snakeCase}_repository_impl.dart';
import '../domain/repositories/${n.snakeCase}_repository.dart';
import '../domain/usecases/get_all_${n.snakeCase}_usecase.dart';
$presentationImports
void register${n.pascalCase}Feature() {
  // Data sources
  sl.registerLazySingleton<${n.pascalCase}RemoteDataSource>(
    () => ${n.pascalCase}RemoteDataSourceImpl(),
  );
$localRegs
  // Repository
  sl.registerLazySingleton<${n.pascalCase}Repository>(
    () => ${n.pascalCase}RepositoryImpl(
      remoteDataSource: sl(),
      ${localArg}networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAll${n.pascalCase}UseCase(sl()));
$presentationRegs}
''';
  }
}
