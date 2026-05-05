import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/screens/home_screen.dart';
import 'package:blog_app/screens/login_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = authProvider.user != null;
      final isLogin = state.matchedLocation == '/login';

      if (!loggedIn && !isLogin) {
        return '/login';
      }

      if (loggedIn && isLogin) {
        return '/home';
      }

      return null;
    },
  );
}