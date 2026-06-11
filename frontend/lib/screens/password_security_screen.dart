import 'package:flutter/material.dart';

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  // Input Controllers
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Visibility States
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Real-time Validation Rules
  bool _hasMinLength = false;
  bool _hasNumberOrSymbol = false;
  bool _isMatching = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final text = _newPasswordController.text;

    setState(() {
      // Rule 1: Minimum 8 characters
      _hasMinLength = text.length >= 8;

      // Rule 2: At least one number or special symbol
      _hasNumberOrSymbol = text.contains(RegExp(r'[0-9!@#$卧%^&*(),.?":{}|<>]'));

      // Rule 3: Confirm password matches new password
      _isMatching = text.isNotEmpty && text == _confirmPasswordController.text;
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Determines if the "Save Updates" button should light up
  bool get _isFormValid {
    return _currentPasswordController.text.isNotEmpty &&
        _hasMinLength &&
        _hasNumberOrSymbol &&
        _isMatching;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC), // Your crisp background canvas
      /// 1. APP BAR HEADER
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF002244),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Password & Security',
          style: TextStyle(
            color: Color(0xFF002244),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              /// Key Illustration Container Block
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.vpn_key_outlined,
                    color: Color(0xFF005A8D),
                    size: 36,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Intro Heading Titles
              const Center(
                child: Text(
                  'Secure Your Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Update your password to keep your digital curated assets protected and private.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// --- CURRENT PASSWORD FIELD ---
              const Text(
                'Current Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00365C),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  onChanged: (_) =>
                      setState(() {}), // Force re-evaluation of button state
                  style: const TextStyle(color: Color(0xFF1F2328)),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: const TextStyle(
                      color: Color(0xFFB0B5C1),
                      letterSpacing: 2,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF555555),
                      ),
                      onPressed: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// --- NEW PASSWORD FIELD ---
              const Text(
                'New Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00365C),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  style: const TextStyle(color: Color(0xFF1F2328)),
                  decoration: InputDecoration(
                    hintText: 'Minimum 8 characters',
                    hintStyle: const TextStyle(color: Color(0xFFB0B5C1)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF555555),
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// --- CONFIRM NEW PASSWORD FIELD ---
              const Text(
                'Confirm New Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00365C),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  style: const TextStyle(color: Color(0xFF1F2328)),
                  decoration: const InputDecoration(
                    hintText: 'Re-enter new password',
                    hintStyle: TextStyle(color: Color(0xFFB0B5C1)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// --- VALIDATION INDICATORS ---
              _buildValidationRow('Minimum of 8 characters', _hasMinLength),
              const SizedBox(height: 10),
              _buildValidationRow(
                'At least one number or symbol',
                _hasNumberOrSymbol,
              ),

              const SizedBox(height: 40),

              /// --- SAVE UPDATES BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid
                      ? () {}
                      : null, // Keeps it greyed out dynamically
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid
                        ? const Color(0xFFECEFF3)
                        : const Color(0xFFEAEAEA),
                    disabledBackgroundColor: const Color(
                      0xFFECEFF3,
                    ).withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Save Updates',
                    style: TextStyle(
                      color: _isFormValid
                          ? const Color(0xFF1F2328)
                          : const Color(0xFF7A8087).withOpacity(0.6),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
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

  /// Helper row widget builder for checkboxes rules
  Widget _buildValidationRow(String ruleText, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid
              ? Icons.check_circle_rounded
              : Icons.check_circle_outline_rounded,
          size: 20,
          color: isValid ? const Color(0xFF005A8D) : const Color(0xFF7A8087),
        ),
        const SizedBox(width: 12),
        Text(
          ruleText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isValid ? const Color(0xFF1F2328) : const Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}
