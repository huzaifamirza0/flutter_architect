abstract class DiTemplates {
  /// GetIt service locator. [registerApiClient] adds ApiClient when REST is on.
  static String getItLocator({required bool registerApiClient}) {
    final apiImport = registerApiClient
        ? "import '../../core/network/api_client.dart';\n"
        : '';
    final apiReg = registerApiClient
        ? '  sl.registerLazySingleton(() => ApiClient());\n'
        : '  // sl.registerLazySingleton(() => ApiClient());\n';

    return '''import 'package:get_it/get_it.dart';
import '../../core/network/network_info.dart';
$apiImport
final sl = GetIt.instance;

Future<void> setupLocator() async {
  // ── Core ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
$apiReg
  // ── Features — flutter_architect appends registrations below ──────
  // <FEATURE_REGISTRATIONS>
}
''';
  }
}
