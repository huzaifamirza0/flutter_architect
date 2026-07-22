import 'dart:io';

/// Helpers for patching the host Flutter project's pubspec.yaml.
abstract class PubspecUtils {
  /// Ensures flutter_localizations + intl + generate: true for l10n.
  static void enableLocalization(String root) {
    final file = File('$root/pubspec.yaml');
    if (!file.existsSync()) return;

    var content = file.readAsStringSync();

    if (!content.contains('flutter_localizations:')) {
      content = content.replaceFirstMapped(
        RegExp(r'(flutter:\s*\n\s*sdk:\s*flutter)'),
        (match) => '''${match[1]}
  flutter_localizations:
    sdk: flutter
  intl: any''',
      );
    }

    if (!RegExp(r'generate:\s*true').hasMatch(content)) {
      if (RegExp(r'^flutter:\s*$', multiLine: true).hasMatch(content)) {
        content = content.replaceFirst(
          RegExp(r'^flutter:\s*$', multiLine: true),
          'flutter:\n  generate: true',
        );
      } else if (content.contains('uses-material-design:')) {
        content = content.replaceFirst(
          'uses-material-design:',
          'generate: true\n  uses-material-design:',
        );
      } else {
        content = '$content\nflutter:\n  generate: true\n';
      }
    }

    file.writeAsStringSync(content);
    stdout.writeln('  \x1B[32m✓\x1B[0m  pubspec.yaml (localization)');
  }
}
