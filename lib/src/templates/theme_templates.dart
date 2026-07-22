abstract class ThemeTemplates {
  static const String appColors = '''import 'package:flutter/material.dart';

/// App color palette — customize to match your brand.
abstract class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF26A69A);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);

  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
}
''';

  static const String appTextStyles = '''import 'package:flutter/material.dart';

/// Shared text styles used across the app.
abstract class AppTextStyles {
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}
''';

  static const String appTheme = '''import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Light / dark [ThemeData] for the application.
abstract class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.labelLarge,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.labelLarge,
      ),
    );
  }
}
''';
}
