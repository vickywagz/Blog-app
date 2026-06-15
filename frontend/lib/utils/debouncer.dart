import 'dart:async';
import 'package:flutter/material.dart';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void run(VoidCallback action) {
    // Cancel the active timer if the user typed another character before the delay finished
    _timer?.cancel();

    // Start a brand new countdown
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
