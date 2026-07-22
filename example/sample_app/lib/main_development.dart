import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/config/app_config.dart';
import 'app/di/service_locator.dart';

/// Entry point for the **development** flavor.
///
/// ```bash
/// flutter run -t lib/main_development.dart
/// ```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.bootstrap(Environment.development);
  await setupLocator();
  runApp(const App());
}
