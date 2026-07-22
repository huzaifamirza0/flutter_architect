import 'package:get_it/get_it.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../features/auth/di/auth_injection.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // ── Core ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => ApiClient());

  // ── Features ──────────────────────────────────────────────────────
  registerAuthFeature();
  // <FEATURE_REGISTRATIONS>
}
