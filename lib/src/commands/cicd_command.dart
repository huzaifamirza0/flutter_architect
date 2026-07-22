import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:interact/interact.dart';
import '../templates/cicd_templates.dart';

/// `flutter_architect cicd` — generate GitHub Actions and/or Codemagic configs.
class CicdCommand extends Command<void> {
  @override
  final String name = 'cicd';

  @override
  final String description =
      'Generate CI/CD templates (GitHub Actions and/or Codemagic).';

  CicdCommand() {
    argParser.addOption(
      'provider',
      abbr: 'p',
      allowed: ['github', 'codemagic', 'both'],
      help: 'CI/CD provider. If omitted, an interactive prompt is shown.',
    );
  }

  @override
  Future<void> run() async {
    final root = Directory.current.path;
    if (!File('$root/pubspec.yaml').existsSync()) {
      stdout.writeln(
          '\x1B[31mError: Run this inside a Flutter project (pubspec.yaml missing).\x1B[0m');
      exit(1);
    }

    var provider = argResults!['provider'] as String?;
    if (provider == null) {
      final idx = Select(
        prompt: 'CI/CD provider?',
        options: ['GitHub Actions', 'Codemagic', 'Both'],
        initialIndex: 0,
      ).interact();
      provider = ['github', 'codemagic', 'both'][idx];
    }

    stdout.writeln('\n\x1B[36mGenerating CI/CD templates...\x1B[0m\n');

    if (provider == 'github' || provider == 'both') {
      _write(
        '$root/.github/workflows/flutter_ci.yml',
        CicdTemplates.githubActions,
      );
    }
    if (provider == 'codemagic' || provider == 'both') {
      _write('$root/codemagic.yaml', CicdTemplates.codemagic);
    }

    stdout.writeln('\n\x1B[32m✅  CI/CD templates ready.\x1B[0m');
  }

  void _write(String path, String content) {
    final file = File(path);
    if (file.existsSync()) {
      stdout.writeln('  \x1B[33m~\x1B[0m  $path (already exists)');
      return;
    }
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
    stdout.writeln('  \x1B[32m✓\x1B[0m  $path');
  }
}
