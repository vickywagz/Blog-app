import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/screens/home_screen.dart';
import 'package:blog_app/screens/login_screen.dart';
import 'package:blog_app/screens/splash_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = authProvider.user != null;
      final loading = authProvider.futureUser != null && authProvider.user == null;
      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';

      if (loading && !isSplash) return '/splash';
      if (loggedIn && (isLogin || isSplash)) return '/home';
      if (!loggedIn && !isLogin && !isSplash) return '/login';

      return null;
    },
  );
}