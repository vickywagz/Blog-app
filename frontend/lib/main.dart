import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/providers/post_provider.dart';
import 'package:blog_app/screens/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  // Ensure Flutter engine is initialized before running the app setup
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlutterAuth());
}

class FlutterAuth extends StatefulWidget {
  const FlutterAuth({super.key});

  @override
  State<FlutterAuth> createState() => _FlutterAuthState();
}

class _FlutterAuthState extends State<FlutterAuth> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<PostProvider>(create: (_) => PostProvider()),
      ],
      child: Builder(
        builder: (context) {
          // 1. Fetch the provider instance cleanly
          final authProvider = context.read<AuthProvider>();

          _router ??= createRouter(authProvider);

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(
                0xFFF5F5F5,
              ), // Set app background globally
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
              ),
            ),
            routerConfig: _router!,
          );
        },
      ),
    );
  }
}
