import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/presentation/providers/auth_provider.dart';
import 'package:newsletter_portal/presentation/pages/auth/login_page.dart';
import 'package:newsletter_portal/presentation/pages/auth/register_page.dart';
import 'package:newsletter_portal/presentation/pages/report/report_page.dart';
import 'package:newsletter_portal/presentation/pages/terminal/terminal_page.dart';

/// Notifies GoRouter when auth changes without recreating the router
/// (recreating remounts LoginPage and clears the text fields mid-submit).
class _AuthRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh();
  ref.onDispose(refresh.dispose);

  ref.listen<AuthState>(authStateProvider, (_, __) {
    refresh.ping();
  });

  return GoRouter(
    initialLocation: '/report',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState is AuthAuthenticated;
      final isGoingToLogin = state.uri.path == '/login';
      final isGoingToRegister = state.uri.path == '/register';
      final onAuthScreen = isGoingToLogin || isGoingToRegister;

      // Avoid redirect thrash while the session is still bootstrapping.
      if (authState is AuthInitial) {
        return null;
      }

      // Keep login/register mounted while a sign-in request is in flight.
      if (authState is AuthLoading && onAuthScreen) {
        return null;
      }

      if (!isAuthenticated && !onAuthScreen) {
        return '/login';
      }

      if (isAuthenticated && onAuthScreen) {
        return '/report';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/report',
      ),
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
