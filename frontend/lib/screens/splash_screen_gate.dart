import 'package:flutter/material.dart';

class SplashGateScreen extends StatelessWidget {
  const SplashGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Core Brand Mark Accent
              const Icon(
                Icons.edit_note_rounded, // An alternative neat built-in match if you don't use the raw PNG here
                size: 64,
                color: Color(0xFF0B3558),
              ),
              const SizedBox(height: 16),

              // 2. Main Title Line
              const Text(
                'THE CURATOR',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0B3558),
                  letterSpacing: 0.5,
                ),
              ),
              
              // 3. Thin Minimalist Divider Accent
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                width: 45,
                height: 1.5,
                color: const Color(0xFF0B3558).withOpacity(0.3),
              ),

              // 4. Sub-Text Statement
              Text(
                'DIGITAL EDITORIAL\nEXCELLENCE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF0B3558).withOpacity(0.7),
                  letterSpacing: 2.5,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Subtle loader keeping them engaged while Render wakes up
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B3558)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}