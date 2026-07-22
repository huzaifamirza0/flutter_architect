abstract class L10nTemplates {
  static const String l10nYaml = '''arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
''';

  static String arb(String locale, String appName) {
    if (locale == 'en') {
      return '''{
  "@@locale": "en",
  "appTitle": "$appName",
  "@appTitle": {
    "description": "The application title"
  },
  "hello": "Hello",
  "loading": "Loading...",
  "errorGeneric": "Something went wrong",
  "retry": "Retry"
}
''';
    }

    // Minimal stubs for non-English locales (same keys).
    final translations = <String, Map<String, String>>{
      'ar': {
        'appTitle': appName,
        'hello': 'مرحبا',
        'loading': 'جاري التحميل...',
        'errorGeneric': 'حدث خطأ ما',
        'retry': 'إعادة المحاولة',
      },
      'fr': {
        'appTitle': appName,
        'hello': 'Bonjour',
        'loading': 'Chargement...',
        'errorGeneric': 'Une erreur est survenue',
        'retry': 'Réessayer',
      },
      'de': {
        'appTitle': appName,
        'hello': 'Hallo',
        'loading': 'Wird geladen...',
        'errorGeneric': 'Etwas ist schiefgelaufen',
        'retry': 'Erneut versuchen',
      },
      'es': {
        'appTitle': appName,
        'hello': 'Hola',
        'loading': 'Cargando...',
        'errorGeneric': 'Algo salió mal',
        'retry': 'Reintentar',
      },
    };

    final t = translations[locale] ??
        {
          'appTitle': appName,
          'hello': 'Hello',
          'loading': 'Loading...',
          'errorGeneric': 'Something went wrong',
          'retry': 'Retry',
        };

    return '''{
  "@@locale": "$locale",
  "appTitle": "${t['appTitle']}",
  "hello": "${t['hello']}",
  "loading": "${t['loading']}",
  "errorGeneric": "${t['errorGeneric']}",
  "retry": "${t['retry']}"
}
''';
  }
}
