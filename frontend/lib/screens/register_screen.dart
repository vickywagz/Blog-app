import 'package:blog_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final _formkey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _repassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 36),

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
                      'assets/icons/logo.png', // change to your asset path
                      fit: BoxFit.contain,
                      color: Colors.white,
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
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF7A8087),
                  ),
                ),

                const SizedBox(height: 42),

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
                  controller: _username,
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
                    if (value!.isEmpty) {
                      return '* Required';
                    } else {
                      return null;
                    }
                  },
                ),

                const SizedBox(height: 22),

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
                  controller: _password,
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
                    if (value!.isEmpty) {
                      return '* Required';
                    } else if (value.length < 6) {
                      return 'Password should be atleast 6 characters';
                    } else if (value.length > 15) {
                      return 'Password should not be greater than 15 characters';
                    } else if (_password.text != _repassword.text) {
                      return 'Password do not match';
                    } else {
                      return null;
                    }
                  },
                ),

                const SizedBox(height: 22),

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
                  controller: _repassword,
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
                    if (value!.isEmpty) {
                      return '* Required';
                    } else if (value.length < 6) {
                      return 'Password should be atleast 6 characters';
                    } else if (value.length > 15) {
                      return 'Password should not be greater than 15 characters';
                    } else if (_password.text != _repassword.text) {
                      return 'Password do not match';
                    } else {
                      return null;
                    }
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: AbsorbPointer(
                    absorbing: isLoading,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formkey.currentState!.validate()) {
                          await context
                              .read<AuthProvider>()
                              .register(
                                _username.text,
                                _password.text,
                              )
                              .then((value) {
                            if (value) Navigator.pop(context);
                          });
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
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

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
                    AbsorbPointer(
                      absorbing: isLoading,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
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
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}