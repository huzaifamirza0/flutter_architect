import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/auth_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AuthPage.routeName,
  routes: [
    GoRoute(
      path: AuthPage.routeName,
      builder: (context, state) => const AuthPage(),
    ),
  ],
);
