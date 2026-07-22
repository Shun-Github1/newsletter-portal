import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/presentation/providers/auth_provider.dart';
import 'package:newsletter_portal/presentation/pages/auth/login_page.dart';
import 'package:newsletter_portal/presentation/pages/auth/register_page.dart';
import 'package:newsletter_portal/presentation/pages/report/report_page.dart';
import 'package:newsletter_portal/presentation/pages/terminal/terminal_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final isAuthenticated = authState is AuthAuthenticated;

  return GoRouter(
    initialLocation: '/report',
    redirect: (context, state) {
      final isGoingToLogin = state.uri.path == '/login';
      final isGoingToRegister = state.uri.path == '/register';

      if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister) {
        return '/login';
      }

      if (isAuthenticated && (isGoingToLogin || isGoingToRegister)) {
        return '/report';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/report',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ReportPage(),
        ),
      ),
      GoRoute(
        path: '/terminal',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: TerminalPage(),
        ),
      ),
    ],
  );
});
