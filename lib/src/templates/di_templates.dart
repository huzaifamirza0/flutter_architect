abstract class DiTemplates {
  static const String getItLocator = '''import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Core
  // sl.registerLazySingleton(() => ApiClient());
  
  // Features
  // _setupAuthFeature();
}

// void _setupAuthFeature() {
//   sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
//   sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
//   sl.registerLazySingleton(() => LoginUseCase(sl()));
//   sl.registerFactory(() => AuthBloc(sl()));
// }
''';
}
