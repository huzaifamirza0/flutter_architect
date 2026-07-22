import '../utils/name_utils.dart';

/// Generates BLoC boilerplate wired to a GetXs UseCase.
abstract class BlocTemplates {
  static String bloc(NameUtils n) => '''import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/usecase.dart';
import '../../domain/usecases/get_all_${n.snakeCase}_usecase.dart';
import '${n.snakeCase}_event.dart';
import '${n.snakeCase}_state.dart';

class ${n.pascalCase}Bloc extends Bloc<${n.pascalCase}Event, ${n.pascalCase}State> {
  ${n.pascalCase}Bloc(this._getAll) : super(${n.pascalCase}Initial()) {
    on<Load${n.pascalCase}Event>(_onLoad);
  }

  final GetAll${n.pascalCase}UseCase _getAll;

  Future<void> _onLoad(
    Load${n.pascalCase}Event event,
    Emitter<${n.pascalCase}State> emit,
  ) async {
    emit(${n.pascalCase}Loading());
    final result = await _getAll(const NoParams());
    result.fold(
      (failure) => emit(${n.pascalCase}Error(message: failure.message)),
      (items) => emit(${n.pascalCase}Loaded(items: items)),
    );
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
import '../../domain/entities/${n.snakeCase}_entity.dart';

abstract class ${n.pascalCase}State extends Equatable {
  const ${n.pascalCase}State();

  @override
  List<Object?> get props => [];
}

class ${n.pascalCase}Initial extends ${n.pascalCase}State {}

class ${n.pascalCase}Loading extends ${n.pascalCase}State {}

class ${n.pascalCase}Loaded extends ${n.pascalCase}State {
  const ${n.pascalCase}Loaded({required this.items});

  final List<${n.pascalCase}Entity> items;

  @override
  List<Object?> get props => [items];
}

class ${n.pascalCase}Error extends ${n.pascalCase}State {
  const ${n.pascalCase}Error({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
''';
}
