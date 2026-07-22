import '../../../../app/di/service_locator.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/datasources/auth_remote_datasource_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/get_all_auth_usecase.dart';
import '../presentation/bloc/auth_bloc.dart';

void registerAuthFeature() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => const AuthRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetAllAuthUseCase(sl()));
  sl.registerFactory(() => AuthBloc(sl()));
}
