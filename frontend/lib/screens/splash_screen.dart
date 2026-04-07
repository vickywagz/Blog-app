import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:blog_app/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

 void _checkAuth() async {
  await Future.delayed(const Duration(seconds: 2));

  final authProvider = context.read<AuthProvider>();

  if (!mounted) return;

  if (authProvider.user != null) {
    context.go('/home');
  } else {
    context.go('/login');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Logo Container
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF108558),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Image.asset(
                  'assets/icons/logo.png', // change to your asset path
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            const Text(
              'The Merchant',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'CURATED STORIES & INSIGHTS',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                color: Colors.black54,
              ),
            ),

            const Spacer(),

            // Loader
            const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFF108558),
            ),

            const SizedBox(height: 16),

            const Text(
              'Authenticating account...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}