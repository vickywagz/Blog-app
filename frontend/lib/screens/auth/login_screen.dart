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
  final _formKey = GlobalKey<FormState>();

  // 🟢 FIXED: Renamed controller explicitly to match our database email parameter
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  String? _serverEmailError;
  String? _serverPasswordError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _serverEmailError = null;
      _serverPasswordError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    // 🟢 FIXED: Sends clean email controller input directly to updated AuthProvider
    final result = await context.read<AuthProvider>().login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (!result.success) {
      final errorMessage = result.message.toLowerCase();

      setState(() {
        // 🟢 FIXED: Checks for explicit email matching conditions across server responses
        if (errorMessage.contains('user') ||
            errorMessage.contains('email') ||
            errorMessage.contains('exist') ||
            errorMessage.contains('find')) {
          _serverEmailError = result.message;
        } else if (errorMessage.contains('password') ||
            errorMessage.contains('invalid')) {
          _serverPasswordError = result.message;
        } else {
          _serverEmailError = result.message;
        }
      });

      _formKey.currentState!.validate();
    } else {
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

                    /// EMAIL ADDRESS FIELD
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'EMAIL ADDRESS', // 🟢 FIXED: Refactored label context
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
                      controller: _emailController,
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
                      // 🟢 FIXED: Clears inline server layout error immediately when typing begins
                      onChanged: (value) {
                        if (_serverEmailError != null) {
                          setState(() => _serverEmailError = null);
                          _formKey.currentState!.validate();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '* Required';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email address';
                        }
                        return _serverEmailError;
                      },
                    ),

                    const SizedBox(height: 24),

                    /// PASSWORD FIELD
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
                      // 🟢 FIXED: Clears inline password error immediately when user begins editing
                      onChanged: (value) {
                        if (_serverPasswordError != null) {
                          setState(() => _serverPasswordError = null);
                          _formKey.currentState!.validate();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '* Required';
                        }
                        if (value.length < 6) {
                          return 'Password should be at least 6 characters';
                        }
                        return _serverPasswordError;
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
