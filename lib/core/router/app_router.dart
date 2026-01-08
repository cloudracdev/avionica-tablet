import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/offline_mode_provider.dart';
import '../../screens/login_screen.dart';
import '../../screens/connection_screen.dart';
import '../../screens/selecao_screen.dart';
import '../../screens/sixpack_screen.dart';
import '../../screens/calibration_screen.dart';
import '../../screens/origem_destino_screen.dart';
import '../../screens/my_flights_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isOfflineMode = ref.watch(offlineModeProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: RouterRefreshStream(ref),
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.status == AuthStatus.loading;
      final isInitial = authState.status == AuthStatus.initial;
      final isLoginRoute = state.matchedLocation == '/login';
      final hasAccess = isAuthenticated || isOfflineMode;

      if (isLoading || isInitial) return null;

      if (!hasAccess && !isLoginRoute) return '/login';

      if (hasAccess && isLoginRoute) return '/connection';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/connection',
        name: 'connection',
        builder: (context, state) => const ConnectionScreen(),
      ),
      GoRoute(
        path: '/selecao',
        name: 'selecao',
        builder: (context, state) => const SelecaoScreen(),
      ),
      GoRoute(
        path: '/origem-destino',
        name: 'origem-destino',
        builder: (context, state) => const OrigemDestinoScreen(),
      ),
      GoRoute(
        path: '/calibration',
        name: 'calibration',
        builder: (context, state) => const CalibrationScreen(),
      ),
      GoRoute(
        path: '/sixpack',
        name: 'sixpack',
        builder: (context, state) => const SixPackScreen(),
      ),
      GoRoute(
        path: '/my-flights',
        name: 'my-flights',
        builder: (context, state) => const MyFlightsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Página não encontrada: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    ),
  );
});

class RouterRefreshStream extends ChangeNotifier {
  RouterRefreshStream(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    ref.listen(offlineModeProvider, (_, __) => notifyListeners());
  }
}

extension GoRouterExtension on BuildContext {
  void goToConnection() => go('/connection');
  void goToLogin() => go('/login');
  void goToSelecao() => go('/selecao');
  void goToOrigemDestino() => go('/origem-destino');
  void goToCalibration() => go('/calibration');
  void goToSixpack() => go('/sixpack');
}
