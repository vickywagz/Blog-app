import 'package:blog_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Safe stack routing management

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Instantiated safely inside state parameters to prevent controller leakage
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _repasswordController;

  // 2. Holds inline backend response errors dynamically
  String? _serverRegistrationError;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _repasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _repasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    // Clear old errors before evaluating
    setState(() {
      _serverRegistrationError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    // Call the updated provider that passes back AuthResult details
    final result = await authProvider.register(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (result.success) {
      if (mounted) {
        context.push('/otp', extra: _usernameController.text.trim());
      }
    } else {
      // 3. Intercept server errors and drop them directly beneath the username/form area
      setState(() {
        _serverRegistrationError = result.message;
      });
      // Re-trigger validation rules to paint the error text red inline
      _formKey.currentState!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
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
                  const SizedBox(height: 16),
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
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2328),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Start managing your content today.',
                    style: TextStyle(fontSize: 15, color: Color(0xFF7A8087)),
                  ),
                  const SizedBox(height: 42),

                  /// USERNAME FIELD
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'USERNAME',
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
                    decoration: InputDecoration(
                      hintText: 'Enter username',
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
                      // Returns the database uniqueness conflict messages here instantly
                      return _serverRegistrationError;
                    },
                  ),

                  const SizedBox(height: 22),

                  /// PASSWORD FIELD
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PASSWORD',
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
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Enter secure password',
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
                      if (value.length > 15) {
                        return 'Password should not be greater than 15 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 22),

                  /// CONFIRM PASSWORD FIELD
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'CONFIRM PASSWORD',
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
                    obscureText: true,
                    controller: _repasswordController,
                    decoration: InputDecoration(
                      hintText: 'Retype password',
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
                      if (_passwordController.text !=
                          _repasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 38),

                  /// SIGN UP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleRegistration,
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
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// BACK TO LOGIN REDIRECT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already registered? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8A9097),
                        ),
                      ),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                context.pop();
                              },
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2328),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
