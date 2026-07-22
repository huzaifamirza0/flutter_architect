abstract class MvvmTemplates {
  // ── Model ──────────────────────────────────────────────────────────
  static String model(String pascal, String snake) => '''class ${pascal}Model {
  const ${pascal}Model({required this.id});

  final String id;

  factory ${pascal}Model.fromJson(Map<String, dynamic> json) {
    return ${pascal}Model(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id};

  ${pascal}Model copyWith({String? id}) {
    return ${pascal}Model(id: id ?? this.id);
  }
}
''';

  // ── Service (data access for MVVM) ─────────────────────────────────
  static String service(String pascal, String snake) => '''import '../models/${snake}_model.dart';

class ${pascal}Service {
  // TODO: inject ApiClient / Dio
  const ${pascal}Service();

  Future<List<${pascal}Model>> getAll() async {
    // TODO: implement API call
    return const [];
  }
}
''';

  // ── ViewModel (ChangeNotifier) ─────────────────────────────────────
  static String viewModel(String pascal, String snake) => '''import 'package:flutter/foundation.dart';
import '../models/${snake}_model.dart';
import '../services/${snake}_service.dart';

class ${pascal}ViewModel extends ChangeNotifier {
  ${pascal}ViewModel(this._service);

  final ${pascal}Service _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<${pascal}Model> _items = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<${pascal}Model> get items => _items;

  Future<void> init() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _items = await _service.getAll();
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

  // ── View (wired to ViewModel via ListenableBuilder / DI) ───────────
  static String view(String pascal, String snake, {required bool useGetIt}) {
    final create = useGetIt
        ? 'sl<${pascal}ViewModel>()'
        : '${pascal}ViewModel(${pascal}Service())';
    final slImport = useGetIt
        ? "import '../../../app/di/service_locator.dart';\n"
        : "import '../services/${snake}_service.dart';\n";

    return '''import 'package:flutter/material.dart';
${slImport}import '../viewmodels/${snake}_viewmodel.dart';

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
    _viewModel = $create;
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (_viewModel.errorMessage != null) {
          return Scaffold(
            body: Center(child: Text(_viewModel.errorMessage!)),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('$pascal')),
          body: Center(
            child: Text('$pascal View (\${_viewModel.items.length} items)'),
          ),
        );
      },
    );
  }
}
''';
  }

  // ── BLoC-as-ViewModel (when MVVM + bloc) ───────────────────────────
  static String blocViewModel(String pascal, String snake) => '''import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/${snake}_model.dart';
import '../services/${snake}_service.dart';
import '${snake}_event.dart';
import '${snake}_state.dart';

class ${pascal}Bloc extends Bloc<${pascal}Event, ${pascal}State> {
  ${pascal}Bloc(this._service) : super(${pascal}Initial()) {
    on<Load${pascal}Event>(_onLoad);
  }

  final ${pascal}Service _service;

  Future<void> _onLoad(
    Load${pascal}Event event,
    Emitter<${pascal}State> emit,
  ) async {
    emit(${pascal}Loading());
    try {
      final items = await _service.getAll();
      emit(${pascal}Loaded(items: items));
    } catch (e) {
      emit(${pascal}Error(message: e.toString()));
    }
  }
}
''';

  static String blocEvent(String pascal) => '''import 'package:equatable/equatable.dart';

abstract class ${pascal}Event extends Equatable {
  const ${pascal}Event();

  @override
  List<Object?> get props => [];
}

class Load${pascal}Event extends ${pascal}Event {
  const Load${pascal}Event();
}
''';

  static String blocState(String pascal, String snake) => '''import 'package:equatable/equatable.dart';
import '../models/${snake}_model.dart';

abstract class ${pascal}State extends Equatable {
  const ${pascal}State();

  @override
  List<Object?> get props => [];
}

class ${pascal}Initial extends ${pascal}State {}

class ${pascal}Loading extends ${pascal}State {}

class ${pascal}Loaded extends ${pascal}State {
  const ${pascal}Loaded({required this.items});

  final List<${pascal}Model> items;

  @override
  List<Object?> get props => [items];
}

class ${pascal}Error extends ${pascal}State {
  const ${pascal}Error({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
''';

  static String blocView(String pascal, String snake, {required bool useGetIt}) {
    final create = useGetIt
        ? "sl<${pascal}Bloc>()..add(const Load${pascal}Event())"
        : '${pascal}Bloc(${pascal}Service())..add(const Load${pascal}Event())';
    final slImport = useGetIt
        ? "import '../../../app/di/service_locator.dart';\n"
        : "import '../services/${snake}_service.dart';\n";

    return '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
${slImport}import '../bloc/${snake}_bloc.dart';
import '../bloc/${snake}_event.dart';
import '../bloc/${snake}_state.dart';

class ${pascal}View extends StatelessWidget {
  const ${pascal}View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => $create,
      child: const _${pascal}Body(),
    );
  }
}

class _${pascal}Body extends StatelessWidget {
  const _${pascal}Body();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$pascal')),
      body: BlocBuilder<${pascal}Bloc, ${pascal}State>(
        builder: (context, state) {
          if (state is ${pascal}Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ${pascal}Error) {
            return Center(child: Text(state.message));
          }
          if (state is ${pascal}Loaded) {
            return Center(child: Text('$pascal View (\${state.items.length} items)'));
          }
          return const Center(child: Text('$pascal View'));
        },
      ),
    );
  }
}
''';
  }

  // ── Riverpod ───────────────────────────────────────────────────────
  static String riverpodProvider(String pascal, String snake) => '''import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/${snake}_model.dart';
import '../services/${snake}_service.dart';

final ${snake}ServiceProvider = Provider<${pascal}Service>(
  (ref) => const ${pascal}Service(),
);

final ${snake}Provider =
    StateNotifierProvider<${pascal}Notifier, AsyncValue<List<${pascal}Model>>>(
  (ref) => ${pascal}Notifier(ref.read(${snake}ServiceProvider)),
);

class ${pascal}Notifier extends StateNotifier<AsyncValue<List<${pascal}Model>>> {
  ${pascal}Notifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  final ${pascal}Service _service;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_service.getAll);
  }
}
''';

  static String riverpodView(String pascal, String snake) => '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/${snake}_provider.dart';

class ${pascal}View extends ConsumerWidget {
  const ${pascal}View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${snake}Provider);

    return Scaffold(
      appBar: AppBar(title: const Text('$pascal')),
      body: state.when(
        data: (items) => Center(child: Text('$pascal View (\${items.length} items)')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
''';

  // ── GetX ───────────────────────────────────────────────────────────
  static String getxController(String pascal, String snake) => '''import 'package:get/get.dart';
import '../models/${snake}_model.dart';
import '../services/${snake}_service.dart';

class ${pascal}Controller extends GetxController {
  ${pascal}Controller(this._service);

  final ${pascal}Service _service;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final items = <${pascal}Model>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      items.assignAll(await _service.getAll());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
''';

  static String getxBinding(String pascal, String snake) => '''import 'package:get/get.dart';
import '../controllers/${snake}_controller.dart';
import '../services/${snake}_service.dart';

class ${pascal}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${pascal}Service>(() => const ${pascal}Service());
    Get.lazyPut<${pascal}Controller>(
      () => ${pascal}Controller(Get.find()),
    );
  }
}
''';

  static String getxView(String pascal, String snake) => '''import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/${snake}_controller.dart';

class ${pascal}View extends GetView<${pascal}Controller> {
  const ${pascal}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$pascal')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!));
        }
        return Center(
          child: Text('$pascal View (\${controller.items.length} items)'),
        );
      }),
    );
  }
}
''';

  // ── DI registration ────────────────────────────────────────────────
  static String injection(
    String pascal,
    String snake, {
    required String stateManagement,
  }) {
    switch (stateManagement) {
      case 'bloc':
        return '''import '../../../app/di/service_locator.dart';
import '../bloc/${snake}_bloc.dart';
import '../services/${snake}_service.dart';

void register${pascal}Feature() {
  sl.registerLazySingleton(() => const ${pascal}Service());
  sl.registerFactory(() => ${pascal}Bloc(sl()));
}
''';
      case 'provider':
      case 'none':
        return '''import '../../../app/di/service_locator.dart';
import '../services/${snake}_service.dart';
import '../viewmodels/${snake}_viewmodel.dart';

void register${pascal}Feature() {
  sl.registerLazySingleton(() => const ${pascal}Service());
  sl.registerFactory(() => ${pascal}ViewModel(sl()));
}
''';
      default:
        return '''import '../../../app/di/service_locator.dart';
import '../services/${snake}_service.dart';

void register${pascal}Feature() {
  sl.registerLazySingleton(() => const ${pascal}Service());
}
''';
    }
  }
}
