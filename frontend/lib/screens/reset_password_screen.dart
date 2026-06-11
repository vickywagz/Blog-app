import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  // Validation Check States
  bool _hasMinimumLength = false;
  bool _hasSpecialCharacter = false;
  double _securityStrengthValue = 0.0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_evaluatePasswordStrength);
  }

  void _evaluatePasswordStrength() {
    final text = _passwordController.text;

    setState(() {
      // 1. Check for minimum 8 characters
      _hasMinimumLength = text.length >= 8;

      // 2. Check for special characters (!@#$)
      _hasSpecialCharacter = text.contains(RegExp(r'[!@#\$]'));

      // 3. Calculate linear indicator strength mapping
      if (text.isEmpty) {
        _securityStrengthValue = 0.0;
      } else if (_hasMinimumLength && _hasSpecialCharacter) {
        _securityStrengthValue = 1.0; // Full strength
      } else if (_hasMinimumLength || _hasSpecialCharacter) {
        _securityStrengthValue = 0.5; // Half strength
      } else {
        _securityStrengthValue = 0.2; // Weak string entry
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Button is enabled if validations pass and fields match perfectly
    final bool isFormValid = _hasMinimumLength && 
                             _hasSpecialCharacter && 
                             _passwordController.text == _confirmPasswordController.text &&
                             _confirmPasswordController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC), // Exact background canvas tint
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFBFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF1F2328),
              size: 24,
            ),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              /// --- HERO HEADLINE ---
              const Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF000000),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              /// --- SUBTITLE ---
              const Text(
                'Create a strong, secure new password that you don\'t use for other online accounts.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4A5568),
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 44),

              /// --- FIELD 1: NEW PASSWORD ---
              const Text(
                'NEW PASSWORD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF003366),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFECEFF3), // True component fill matching mockups
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _isPasswordObscured,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF1F2328)),
                  decoration: InputDecoration(
                    hintText: 'Enter new password',
                    hintStyle: const TextStyle(color: Color(0xFF9AA2AC), fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFF1F2328),
                        size: 22,
                      ),
                      onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              /// --- FIELD 2: CONFIRM NEW PASSWORD ---
              const Text(
                'CONFIRM NEW PASSWORD',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF003366),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFECEFF3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordObscured,
                  style: const TextStyle(fontSize: 16, color: Color(0xFF1F2328)),
                  onChanged: (_) => setState(() {}), // Redraws to update state validation live
                  decoration: InputDecoration(
                    hintText: 'Re-enter new password',
                    hintStyle: const TextStyle(color: Color(0xFF9AA2AC), fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFF1F2328),
                        size: 22,
                      ),
                      onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// --- SECURITY STRENGTH INDICATOR BAR ---
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _securityStrengthValue,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _securityStrengthValue == 1.0 
                              ? Colors.green 
                              : const Color(0xFF003366), // Matches signature dark blue track style
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'SECURITY STRENGTH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF718096),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// --- VALIDATION ITEM 1: LENGTH ---
              Row(
                children: [
                  Icon(
                    _hasMinimumLength ? Icons.check_circle_outlined : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: _hasMinimumLength ? const Color(0xFF003366) : const Color(0xFFA0AEC0),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'At least 8 characters',
                    style: TextStyle(fontSize: 13, color: Color(0xFF4A5568), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              /// --- VALIDATION ITEM 2: SPECIAL CHARS ---
              Row(
                children: [
                  Icon(
                    _hasSpecialCharacter ? Icons.check_circle_outlined : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: _hasSpecialCharacter ? const Color(0xFF003366) : const Color(0xFFA0AEC0),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'One special character (!@#\$)',
                    style: TextStyle(fontSize: 13, color: Color(0xFF4A5568), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              /// --- PREMIUM BLUE SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: isFormValid
                      ? () {
                          // Complete local routing sequence redirecting up to core login workspace
                          context.go('/login');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005E9E), // True deep blue brand core accent
                    disabledBackgroundColor: const Color(0xFF005E9E).withOpacity(0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Save Password',
                        style: TextStyle(
                          color: isFormValid ? Colors.white : Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: isFormValid ? Colors.white : Colors.white.withOpacity(0.6),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}