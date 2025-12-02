import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/employee/employee_home_screen.dart';
import '../features/admin/admin_home_screen.dart';

// Auth state'i dinleyen notifier
class AuthNotifierForRouter extends ChangeNotifier {
  AuthNotifierForRouter(this._ref) {
    _ref.listen(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }
  final Ref _ref;
}

final authNotifierForRouterProvider = Provider<AuthNotifierForRouter>((ref) {
  return AuthNotifierForRouter(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierForRouterProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final isLoading = authState.isLoading;
      final currentPath = state.matchedLocation;
      final isAuthRoute = currentPath == '/login' || currentPath == '/register';

      // Yükleniyorsa bekle
      if (isLoading) return null;

      // Giriş yapmamışsa ve auth sayfasında değilse, login'e yönlendir
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // Giriş yapmışsa ve auth sayfasındaysa, ana sayfaya yönlendir
      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) {
          final authState = ref.read(authNotifierProvider);
          final user = authState.valueOrNull;
          
          if (user == null) {
            return const LoginScreen();
          }
          
          // Rol'e göre yönlendir
          if (user.isAdmin) {
            return const AdminHomeScreen();
          } else {
            return const EmployeeHomeScreen();
          }
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Sayfa bulunamadı: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
});
