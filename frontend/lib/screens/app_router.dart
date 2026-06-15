import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/screens/notification_screen.dart';
import 'package:blog_app/screens/all_recent_post_screen.dart';
import 'package:blog_app/screens/article_detail_screen.dart';
import 'package:blog_app/screens/forgot_password_screen.dart';
import 'package:blog_app/screens/home_screen.dart';
import 'package:blog_app/screens/auth/login_screen.dart';
import 'package:blog_app/screens/auth/otp_screen.dart';
import 'package:blog_app/screens/password_security_screen.dart';
import 'package:blog_app/screens/profile_screen.dart';
import 'package:blog_app/screens/auth/register_screen.dart';
import 'package:blog_app/screens/reset_password_screen.dart';
import 'package:blog_app/screens/saved_screen.dart';
import 'package:blog_app/screens/splash_screen_gate.dart';
import 'package:blog_app/screens/main_dashboard_layout.dart';
import 'package:blog_app/screens/studio_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashGateScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile-screen',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/password-security-screen',
        builder: (context, state) => const PasswordSecurityScreen(),
      ),
      GoRoute(
        // 🟢 FIX: Lowercased this path to standard routing casing conventions ('/notification-screen')
        path: '/notification-screen',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/otp-screen',
        builder: (context, state) {
          final String username = state.extra as String;
          return OtpScreen(username: username);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final Map<String, String> args = state.extra as Map<String, String>;
          return ResetPasswordScreen(
            email: args['email'] ?? '',
            token: args['token'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/recent-posts',
        builder: (context, state) => const RecentPostScreen(),
      ),

      /// Nested Tab Shell Route Architecture
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainDashboardLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feed',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'post/:id',
                    builder: (context, state) {
                      final postId = state.pathParameters['id'] ?? '';
                      return ArticleDetailScreen(postId: postId);
                    },
                  ),
                  GoRoute(
                    path: 'author/:authorId/:authorName',
                    builder: (context, state) {
                      return const ProfileScreen();
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/studio',
                builder: (context, state) => const StudioScreen(),
              ),
            ],
          ),
        ],
      ),
    ],

    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = authProvider.user != null;
      final currentLoc = state.matchedLocation;

      if (authProvider.isLoading && currentLoc == '/splash') {
        return '/splash';
      }

      // 2. Define our open-access routes
      final isPublicAuthRoute =
          currentLoc == '/login' ||
          currentLoc == '/register' ||
          currentLoc == '/forgot-password' ||
          currentLoc == '/otp-screen' ||
          currentLoc == '/reset-password';

      // 3. User is NOT logged in:
      if (!loggedIn) {
        // If they are on the splash screen and loading finishes, send them to login
        if (currentLoc == '/splash') return '/login';
        // Allow them to navigate anywhere within the public paths
        if (isPublicAuthRoute) return null;
        // Kick them back to login if they try accessing protected areas
        return '/login';
      }

      // 4. User IS logged in:
      // Prevent authenticated users from going backward to auth or splash pages
      if (currentLoc == '/login' ||
          currentLoc == '/splash' ||
          currentLoc == '/register') {
        return '/feed';
      }

      // Allow all other normal target navigations
      return null;
    },
  );
}
