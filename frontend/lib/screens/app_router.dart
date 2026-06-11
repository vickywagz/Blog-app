import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/screens/all_recent_post_screen.dart';
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
    // 1. Start on the splash gate route while checking background storage
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
        path: '/otp-screen',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: '/Forgot-Password-Screen',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password-screen',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/Recent-Post-Screen',
        builder: (context, state) => const RecentPostScreen(),
      ),

      // 2. Nested Tab Shell Route Architecture
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Wraps all three tabs in your premium floating capsule layout
          return MainDashboardLayout(navigationShell: navigationShell);
        },
        branches: [
          // Tab Branch 1: Home Blog Feed
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feed',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab Branch 2: Bookmarks / Saved Posts
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),
          // Tab Branch 3: Creator Hub / Studio
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

      // 3. If we are still initializing/loading storage, stay on the splash screen
      if (currentLoc == '/splash' && authProvider.isLoading) {
        return null;
      }

      // 4. Whitelist Public Auth Screens so logged-out users can visit them
      final isPublicAuthRoute =
          currentLoc == '/login' ||
          currentLoc == '/register' ||
          currentLoc == '/Forgot-Password-Screen' ||
          currentLoc == '/otp-screen' ||
          currentLoc == '/reset-password-screen';

      // Protection: Force non-logged-in users back to login if trying to access protected paths
      if (!loggedIn && !isPublicAuthRoute) {
        return '/login';
      }

      // 5. Prevention: If already logged in, route them straight into the primary tab (/feed)
      // but allow them to stay on sub-pages like /profile-screen or /password-security-screen
      if (loggedIn && (currentLoc == '/login' || currentLoc == '/splash')) {
        return '/feed';
      }

      return null;
    },
  );
}
