import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Expose remaining‑seconds as an `int`.
final otpTimerProvider =
    StateNotifierProvider<OtpTimerController, int>((ref) {
  return OtpTimerController()..initialize();
});

class OtpTimerController extends StateNotifier<int> {
  static const int _otpDuration = 180;          // 3 minutes in seconds
  static const String _key = 'otp_start_time';  // SharedPrefs key
  Timer? _timer;

  OtpTimerController() : super(_otpDuration);

  /// Called once when the provider is first read.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStart = prefs.getInt(_key);
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (savedStart != null) {
      // We’ve already sent an OTP before.
      final elapsed = nowSec - savedStart;
      final remaining = _otpDuration - elapsed;
      if (remaining > 0) {
        state = remaining;
        _startCountdown();               // keep counting
      } else {
        state = 0;                       // timer finished while user was away
      }
    } else {
      // First time on this page – start a brand‑new countdown immediately.
      await prefs.setInt(_key, nowSec);  // remember start time
      state = _otpDuration;
      _startCountdown();                 // <‑‑‑ this line was missing
    }
  }

  /// Call this after a fresh “Send OTP”; it resets both storage & timer.
  Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await prefs.setInt(_key, nowSec);

    state = _otpDuration;
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        state--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
