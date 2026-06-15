import 'package:blog_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Properly managed inside the Widget state lifecycle
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  // Inline Error Strings updated dynamically by the backend catch block
  String? _serverUsernameError;
  String? _serverPasswordError;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // Prevent system leaks
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _serverUsernameError = null;
      _serverPasswordError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    // Trigger login action inside AuthProvider
    // The provider should handle calling /authenticate and saving the JWT to secure storage
    final result = await context.read<AuthProvider>().login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    // If the backend sent an error, intercept it here
    if (!result.success) {
      final errorMessage = result.message.toLowerCase();

      setState(() {
        if (errorMessage.contains('user') ||
            errorMessage.contains('name') ||
            errorMessage.contains('exist') ||
            errorMessage.contains('find')) {
          _serverUsernameError = result.message;
        } else if (errorMessage.contains('password') ||
            errorMessage.contains('invalid')) {
          _serverPasswordError = result.message;
        } else {
          // Fallback for generic errors (e.g. network/server errors)
          _serverUsernameError = result.message;
        }
      });

      // Re-run the form validator to show the backend messages inline
      _formKey.currentState!.validate();
    } else {
      // Clear navigation history stack completely and route them to your landing workspace
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );

    final isLoading = context.watch<AuthProvider>().isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2328),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          'assets/icons/logo.png',
                          fit: BoxFit.contain,
                          color: Colors.white,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.edit_note, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2328),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Continue your journey.',
                      style: TextStyle(fontSize: 15, color: Color(0xFF7A8087)),
                    ),
                    const SizedBox(height: 48),

                    /// USERNAME FIELD CONTAINER
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'USERNAME OR EMAIL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'editor@architect.com',
                        hintStyle: const TextStyle(color: Color(0xFFB2B7BD)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '* Required';
                        }
                        return _serverUsernameError; // Returns backend response error inline
                      },
                    ),

                    const SizedBox(height: 24),

                    /// PASSWORD FIELD CONTAINER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PASSWORD',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.push("/Forgot-Password-Screen"),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'FORGOT?',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: Color(0xFF1F2328),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: true,
                      controller: _passwordController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: Color(0xFFB2B7BD)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '* Required';
                        }
                        if (value.length < 6) {
                          return 'Password should be at least 6 characters';
                        }
                        return _serverPasswordError; // Returns backend response error inline
                      },
                    ),

                    const SizedBox(height: 28),

                    /// SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F2328),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(
                            0xFF1F2328,
                          ).withOpacity(0.6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    /// ACCOUNT REDIRECT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8A9097),
                          ),
                        ),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => context.push('/register'),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2328),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
