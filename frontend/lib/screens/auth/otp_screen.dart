import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Logic for the 6-digit input (matches your portfolio text requirements)
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  // Timer Logic
  Timer? _timer;
  int _secondsRemaining = 57;
  bool _canResend = false;

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
    _secondsRemaining = 57;
    _canResend = false;
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'We\'ve sent a 6-digit confirmation code to jul.***@curator.io. Please enter it below to verify your changes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
                  onPressed: _isComplete
                      ? () {
                          
                          context.push("/reset-password-screen");
                        }
                      : null, // Keeps interaction disabled until entry array fills up
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFECEFF3),
                    disabledBackgroundColor: const Color(0xFFECEFF3).withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(29),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Verify',
                        style: TextStyle(
                          color: _isComplete
                              ? const Color(0xFF111111)
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
                            ? const Color(0xFF111111)
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
        color: const Color(0xFFECEFF3), // True component workspace container color
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
          setState(() {}); // Recalculates dynamic submit button validation parameters
        },
      ),
    );
  }
}