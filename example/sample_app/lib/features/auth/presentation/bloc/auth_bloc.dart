import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/usecase.dart';
import '../../domain/usecases/get_all_auth_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._getAll) : super(AuthInitial()) {
    on<LoadAuthEvent>(_onLoad);
  }

  final GetAllAuthUseCase _getAll;

  Future<void> _onLoad(
    LoadAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _getAll(const NoParams());
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (items) => emit(AuthLoaded(items: items)),
    );
  }
}
