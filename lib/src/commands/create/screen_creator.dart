import 'dart:io';
import 'package:args/command_runner.dart';
import '../../utils/name_utils.dart';
import '../../utils/validation_utils.dart';

/// `flutter_architect create screen Settings --feature profile`
class ScreenCreatorCommand extends Command<void> {
  @override
  final String name = 'screen';

  @override
  final String description =
      'Generate a UI screen/page (and optional state stub) inside a feature.';

  @override
  String get invocation =>
      'flutter_architect create screen <Name> --feature <featureName>';

  ScreenCreatorCommand() {
    argParser.addOption(
      'feature',
      abbr: 'f',
      help: 'Feature folder to place the screen in (required).',
    );
    argParser.addFlag(
      'with-state',
      defaultsTo: true,
      help: 'Also generate a state-management stub for this screen.',
    );
  }

  @override
  Future<void> run() async {
    final root = Directory.current.path;
    ValidationUtils.ensureInitialized(root);

    final rest = argResults!.rest;
    if (rest.isEmpty) {
      usageException(
          'Please provide a screen name.\n  Example: flutter_architect create screen Settings --feature profile');
    }

    final feature = argResults!['feature'] as String?;
    if (feature == null || feature.isEmpty) {
      usageException('Please provide --feature <name>.');
    }

    final withState = argResults!['with-state'] as bool;
    final config = ValidationUtils.readConfig(root);
    final names = NameUtils(rest.first);
    final featureSnake = NameUtils(feature).snakeCase;
    final featurePath = '$root/lib/features/$featureSnake';

    if (!Directory(featurePath).existsSync()) {
      stdout.writeln(
          '\x1B[31mError: Feature "$featureSnake" does not exist.\x1B[0m');
      stdout.writeln(
          'Create it first: \x1B[1mflutter_architect create feature $featureSnake\x1B[0m');
      exit(1);
    }

    if (config.isMvvm) {
      _writeMvvm(root, featurePath, names, config.stateManagement, withState);
    } else {
      _writeClean(root, featurePath, names, config.stateManagement, withState);
    }

    stdout.writeln(
        '\n\x1B[32m✅  Screen "${names.pascalCase}" created.\x1B[0m');
  }

  void _writeClean(
    String root,
    String featurePath,
    NameUtils names,
    String sm,
    bool withState,
  ) {
    final pagePath =
        '$featurePath/presentation/pages/${names.snakeCase}_page.dart';

    String stateImport = '';
    String body = '''
      body: const Center(child: Text('${names.titleCase}')),''';

    if (withState && sm == 'bloc') {
      Directory('$featurePath/presentation/bloc').createSync(recursive: true);
      _write(
        root,
        '$featurePath/presentation/bloc/${names.snakeCase}_bloc.dart',
        '''import 'package:flutter_bloc/flutter_bloc.dart';
import '${names.snakeCase}_event.dart';
import '${names.snakeCase}_state.dart';

class ${names.pascalCase}Bloc extends Bloc<${names.pascalCase}Event, ${names.pascalCase}State> {
  ${names.pascalCase}Bloc() : super(${names.pascalCase}Initial()) {
    on<Load${names.pascalCase}Event>((event, emit) async {
      emit(${names.pascalCase}Loading());
      // TODO: load data
      emit(${names.pascalCase}Loaded());
    });
  }
}
''',
      );
      _write(
        root,
        '$featurePath/presentation/bloc/${names.snakeCase}_event.dart',
        '''import 'package:equatable/equatable.dart';

abstract class ${names.pascalCase}Event extends Equatable {
  const ${names.pascalCase}Event();
  @override
  List<Object?> get props => [];
}

class Load${names.pascalCase}Event extends ${names.pascalCase}Event {
  const Load${names.pascalCase}Event();
}
''',
      );
      _write(
        root,
        '$featurePath/presentation/bloc/${names.snakeCase}_state.dart',
        '''import 'package:equatable/equatable.dart';

abstract class ${names.pascalCase}State extends Equatable {
  const ${names.pascalCase}State();
  @override
  List<Object?> get props => [];
}

class ${names.pascalCase}Initial extends ${names.pascalCase}State {}
class ${names.pascalCase}Loading extends ${names.pascalCase}State {}
class ${names.pascalCase}Loaded extends ${names.pascalCase}State {}
class ${names.pascalCase}Error extends ${names.pascalCase}State {
  const ${names.pascalCase}Error(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
''',
      );
      stateImport = '''import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${names.snakeCase}_bloc.dart';
import '../bloc/${names.snakeCase}_event.dart';
import '../bloc/${names.snakeCase}_state.dart';
''';
      body = '''
      body: BlocBuilder<${names.pascalCase}Bloc, ${names.pascalCase}State>(
        builder: (context, state) {
          if (state is ${names.pascalCase}Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text('${names.titleCase}'));
        },
      ),''';
      _write(
        root,
        pagePath,
        '''import 'package:flutter/material.dart';
$stateImport
class ${names.pascalCase}Page extends StatelessWidget {
  const ${names.pascalCase}Page({super.key});

  static const routeName = '/${names.kebabCase}';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ${names.pascalCase}Bloc()..add(const Load${names.pascalCase}Event()),
      child: Scaffold(
        appBar: AppBar(title: const Text('${names.titleCase}')),$body
      ),
    );
  }
}
''',
      );
      return;
    }

    _write(
      root,
      pagePath,
      '''import 'package:flutter/material.dart';

class ${names.pascalCase}Page extends StatelessWidget {
  const ${names.pascalCase}Page({super.key});

  static const routeName = '/${names.kebabCase}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${names.titleCase}')),$body
    );
  }
}
''',
    );
  }

  void _writeMvvm(
    String root,
    String featurePath,
    NameUtils names,
    String sm,
    bool withState,
  ) {
    Directory('$featurePath/views').createSync(recursive: true);

    if (withState && (sm == 'provider' || sm == 'none' || sm == 'bloc')) {
      // Prefer ChangeNotifier ViewModel for screen micro-gen in MVVM
      Directory('$featurePath/viewmodels').createSync(recursive: true);
      _write(
        root,
        '$featurePath/viewmodels/${names.snakeCase}_viewmodel.dart',
        '''import 'package:flutter/foundation.dart';

class ${names.pascalCase}ViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    // TODO: load data
    _isLoading = false;
    notifyListeners();
  }
}
''',
      );
      _write(
        root,
        '$featurePath/views/${names.snakeCase}_view.dart',
        '''import 'package:flutter/material.dart';
import '../viewmodels/${names.snakeCase}_viewmodel.dart';

class ${names.pascalCase}View extends StatefulWidget {
  const ${names.pascalCase}View({super.key});

  @override
  State<${names.pascalCase}View> createState() => _${names.pascalCase}ViewState();
}

class _${names.pascalCase}ViewState extends State<${names.pascalCase}View> {
  late final ${names.pascalCase}ViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ${names.pascalCase}ViewModel()..init();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('${names.titleCase}')),
          body: _vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : const Center(child: Text('${names.titleCase}')),
        );
      },
    );
  }
}
''',
      );
      return;
    }

    _write(
      root,
      '$featurePath/views/${names.snakeCase}_view.dart',
      '''import 'package:flutter/material.dart';

class ${names.pascalCase}View extends StatelessWidget {
  const ${names.pascalCase}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${names.titleCase}')),
      body: const Center(child: Text('${names.titleCase}')),
    );
  }
}
''',
    );
  }

  void _write(String root, String path, String content) {
    final file = File(path);
    if (file.existsSync()) {
      stdout.writeln(
          '\x1B[33m  ~ ${path.replaceAll('$root/', '')} (already exists)\x1B[0m');
      return;
    }
    file.createSync(recursive: true);
    file.writeAsStringSync(content);
    stdout.writeln(
        '  \x1B[32m✓\x1B[0m  ${path.replaceAll('$root/', '').replaceAll('$root\\', '')}');
  }
}
