import 'dart:io';

class ValidationUtils {
  static const _configFile = 'architect.yaml';

  /// Ensures that `flutter_architect init` has been run.
  /// If not, it prints an error and terminates the process.
  static void ensureInitialized(String root) {
    final coreDir = Directory('$root/lib/core');
    if (!coreDir.existsSync()) {
      stdout.writeln(
          '\x1B[31mError: Architecture is not initialized in this project.\x1B[0m');
      stdout.writeln(
          'Please run \x1B[1mflutter_architect init\x1B[0m first before creating features or components.');
      exit(1);
    }
  }

  /// Saves the chosen architecture type to architect.yaml in the project root.
  static void saveArchitecture(String root, String architecture) {
    final file = File('$root/$_configFile');
    file.writeAsStringSync('architecture: $architecture\n');
  }

  /// Reads the saved architecture type from architect.yaml.
  /// Returns 'clean' if the file is missing (safe default).
  static String readArchitecture(String root) {
    final file = File('$root/$_configFile');
    if (!file.existsSync()) return 'clean';
    for (final line in file.readAsLinesSync()) {
      if (line.startsWith('architecture:')) {
        return line.replaceFirst('architecture:', '').trim();
      }
    }
    return 'clean';
  }
}
