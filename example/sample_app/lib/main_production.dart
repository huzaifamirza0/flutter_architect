import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/config/app_config.dart';
import 'app/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.bootstrap(Environment.production);
  await setupLocator();
  runApp(const App());
}
