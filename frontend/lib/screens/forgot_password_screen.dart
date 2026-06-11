import 'package:flutter/material.dart';
import 'auth/otp_screen.dart'; // Routes directly to the OTP verification screen you have

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  /// Simple regex checking to match standard production-grade email strings
  void _validateEmail() {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC), // Matching canvas fill
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF002244)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              /// --- MAIN HEADLINE ---
              const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              /// --- EXPLANATORY SUBTITLE ---
              const Text(
                'Enter the email address associated with your account and we\'ll send you a 6–digit verification code to reset your password.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              /// --- FIELD LABEL ---
              const Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00365C),
                ),
              ),
              const SizedBox(height: 8),

              /// --- EMAIL INPUT FIELD ---
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9), // Matching light utility background tint
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontSize: 16, 
                    color: Color(0xFF1F2328),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. curator@design.com',
                    hintStyle: TextStyle(color: Color(0xFFB0B5C1), fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              /// --- ACTION TRIGGER BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isEmailValid
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OtpScreen(),
                            ),
                          );
                        }
                      : null, // Kept disabled when validation criteria isn't met
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEmailValid 
                        ? const Color(0xFFB4CDE4) // Beautiful signature faded brand blue matching your exact mockup button state
                        : const Color(0xFFEAEAEA),
                    disabledBackgroundColor: const Color(0xFFB4CDE4).withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28), // Pill shape style
                    ),
                  ),
                  child: Text(
                    'Send Code',
                    style: TextStyle(
                      color: _isEmailValid ? Colors.white : const Color(0xFF7A8087).withOpacity(0.6),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}