import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/service_locator.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(const LoadAuthEvent()),
      child: const _AuthView(),
    );
  }
}

class _AuthView extends StatelessWidget {
  const _AuthView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AuthError) {
            return Center(child: Text(state.message));
          }
          if (state is AuthLoaded) {
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return ListTile(
                  title: Text('User ${item.id}'),
                  subtitle: const Text('From GetAllAuthUseCase → Repository'),
                );
              },
            );
          }
          return const Center(child: Text('Auth Page'));
        },
      ),
    );
  }
}
