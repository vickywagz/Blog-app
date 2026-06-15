import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:blog_app/providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final String username; // Captured dynamically from the register stream

  const OtpScreen({super.key, required this.username});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Logic for the 6-digit input
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  // Timer Logic
  Timer? _timer;
  int _secondsRemaining = 57;
  bool _canResend = false;

  // Track layout status safely separate from global configurations
  bool _isVerifyingFromServer = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Add listeners to focus nodes so the box borders update immediately on tap
    for (var node in _focusNodes) {
      node.addListener(() => setState(() {}));
    }
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 57;
      _canResend = false;
    });
    _timer?.cancel(); // Clear any existing instance
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Determines if all 6 digits are entered to activate the button
  bool get _isComplete => _controllers.every((c) => c.text.isNotEmpty);

  /// Combines the 6 unique input values into a single contiguous string
  String get _compiledOtpCode => _controllers.map((c) => c.text.trim()).join();

  Future<void> _submitOtpVerification() async {
    if (!_isComplete || _isVerifyingFromServer) return;

    setState(() {
      _isVerifyingFromServer = true;
    });

    final authProvider = context.read<AuthProvider>();
    
    final result = await authProvider.verifyAccountOtp(
      widget.username, 
      _compiledOtpCode,
    );

    if (!mounted) return;

    setState(() {
      _isVerifyingFromServer = false;
    });

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message), 
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Clear navigation history stack completely and route them back to log in
      context.go('/login'); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message), 
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Clear wrong attempts so the user can easily re-type numbers
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF1F2328),
            size: 24,
          ),
          onPressed: () => context.pop(), // Safe structural back navigation
        ),
        title: const Text(
          'Verification Code',
          style: TextStyle(
            color: Color(0xFF1F2328),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              /// Shield Icon Container
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3EDF7), // Soft blue accent circle backdrop
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF005E9E),
                  size: 34,
                ),
              ),

              const SizedBox(height: 32),

              /// Headline Section
              const Text(
                'Secure Authentication',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF000000),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "We've sent a 6-digit confirmation code for account verification. Please enter it below to confirm access for '${widget.username}'.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4A5568),
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: 44),

              /// --- 6-DIGIT OTP INPUT ROW ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => _buildOtpBox(index)),
              ),

              const SizedBox(height: 36),

              /// --- RESEND TIMER LOGIC ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _canResend
                        ? "Didn't receive the code? "
                        : "Didn't receive the code? Resend in ",
                    style: const TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _canResend
                      ? GestureDetector(
                          onTap: _startTimer,
                          child: const Text(
                            "Resend Now",
                            style: TextStyle(
                              color: Color(0xFF005E9E),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : Text(
                          "0:${_secondsRemaining.toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            color: Color(0xFF1F2328),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ],
              ),

              const SizedBox(height: 48),

              /// --- VERIFY & COMPLETE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: (_isComplete && !_isVerifyingFromServer)
                      ? _submitOtpVerification
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2328),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFECEFF3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(29),
                    ),
                  ),
                  child: _isVerifyingFromServer
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Verify Account',
                              style: TextStyle(
                                color: _isComplete
                                    ? Colors.white
                                    : const Color(0xFF9AA2AC),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: _isComplete
                                  ? Colors.white
                                  : const Color(0xFF9AA2AC),
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

  /// Helper to build each digit box with auto-focus logic
  Widget _buildOtpBox(int index) {
    final bool hasFocus = _focusNodes[index].hasFocus;
    
    return Container(
      width: 48,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasFocus ? const Color(0xFF005E9E) : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1F2328),
        ),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {}); // Recalculates validation state for button activation
        },
      ),
    );
  }
}