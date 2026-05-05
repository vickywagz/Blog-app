import 'package:blog_app/providers/auth_provider.dart';
import 'package:blog_app/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

final _formkey = GlobalKey<FormState>();
final username = TextEditingController();
final password = TextEditingController();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

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
                        'assets/icons/logo.png', // change to your icon path
                        fit: BoxFit.contain,
                        color: Colors.white,
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
                    'Continue your editorial journey.',
                    style: TextStyle(fontSize: 15, color: Color(0xFF7A8087)),
                  ),

                  const SizedBox(height: 48),

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
                    controller: username,
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
                      if (value!.isEmpty) {
                        return '* Required';
                      } else {
                        return null;
                      }
                    },
                  ),

                  const SizedBox(height: 24),

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
                        onPressed: () {},
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
                    controller: password,
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
                      if (value!.isEmpty) {
                        return '* Required';
                      } else if (value.length < 6) {
                        return 'Password should be atleast 6 characters';
                      } else if (value.length > 15) {
                        return 'Password should not be greater than 15 characters';
                      } else {
                        return null;
                      }
                    },
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: AbsorbPointer(
                      absorbing: isLoading,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formkey.currentState!.validate()) {
                            context.read<AuthProvider>().login(
                              username.text,
                              password.text,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F2328),
                          foregroundColor: Colors.white,
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
                  ),

                  const SizedBox(height: 34),

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
                      AbsorbPointer(
                        absorbing: isLoading,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2328),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
