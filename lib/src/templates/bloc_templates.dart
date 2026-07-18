import '../utils/name_utils.dart';

/// Generates BLoC boilerplate strings for a given feature name.
abstract class BlocTemplates {
  static String bloc(NameUtils n) => '''import 'package:flutter_bloc/flutter_bloc.dart';
import '${n.snakeCase}_event.dart';
import '${n.snakeCase}_state.dart';

class ${n.pascalCase}Bloc extends Bloc<${n.pascalCase}Event, ${n.pascalCase}State> {
  ${n.pascalCase}Bloc() : super(${n.pascalCase}Initial()) {
    on<Load${n.pascalCase}Event>(_onLoad);
  }

  Future<void> _onLoad(
    Load${n.pascalCase}Event event,
    Emitter<${n.pascalCase}State> emit,
  ) async {
    emit(${n.pascalCase}Loading());
    try {
      // TODO: call use-case and emit result
      emit(${n.pascalCase}Loaded());
    } catch (e) {
      emit(${n.pascalCase}Error(message: e.toString()));
    }
  }
}
''';

  static String event(NameUtils n) => '''import 'package:equatable/equatable.dart';

abstract class ${n.pascalCase}Event extends Equatable {
  const ${n.pascalCase}Event();

  @override
  List<Object?> get props => [];
}

class Load${n.pascalCase}Event extends ${n.pascalCase}Event {
  const Load${n.pascalCase}Event();
}
''';

  static String state(NameUtils n) => '''import 'package:equatable/equatable.dart';

abstract class ${n.pascalCase}State extends Equatable {
  const ${n.pascalCase}State();

  @override
  List<Object?> get props => [];
}

class ${n.pascalCase}Initial extends ${n.pascalCase}State {}

class ${n.pascalCase}Loading extends ${n.pascalCase}State {}

class ${n.pascalCase}Loaded extends ${n.pascalCase}State {}

class ${n.pascalCase}Error extends ${n.pascalCase}State {
  const ${n.pascalCase}Error({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
''';
}
