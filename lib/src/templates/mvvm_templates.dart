abstract class MvvmTemplates {
  // ── ViewModel (ChangeNotifier) ──────────────────────────────────
  static String viewModel(String pascal, String snake) => '''import 'package:flutter/foundation.dart';

class ${pascal}ViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Methods ────────────────────────────────────────────────────
  Future<void> init() async {
    _setLoading(true);
    try {
      // TODO: load data via a service
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
''';

  // ── View ────────────────────────────────────────────────────────
  static String view(String pascal, String snake) => '''import 'package:flutter/material.dart';
import '../viewmodels/${snake}_viewmodel.dart';

class ${pascal}View extends StatefulWidget {
  const ${pascal}View({super.key});

  @override
  State<${pascal}View> createState() => _${pascal}ViewState();
}

class _${pascal}ViewState extends State<${pascal}View> {
  late final ${pascal}ViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ${pascal}ViewModel();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          appBar: AppBar(title: const Text('$pascal')),
          body: const Center(child: Text('$pascal View')),
        );
      },
    );
  }
}
''';

  // ── Model ───────────────────────────────────────────────────────
  static String model(String pascal, String snake) => '''class ${pascal}Model {
  const ${pascal}Model({
    required this.id,
  });

  final String id;

  factory ${pascal}Model.fromJson(Map<String, dynamic> json) {
    return ${pascal}Model(
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
  };

  ${pascal}Model copyWith({String? id}) {
    return ${pascal}Model(id: id ?? this.id);
  }
}
''';
}
