import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final sendOtpProvider =
    StateNotifierProvider<SendOtpNotifier, AsyncValue<void>>((ref) {
      return SendOtpNotifier(ref);
    });

class SendOtpNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  SendOtpNotifier(this.ref) : super(const AsyncValue.data(null));
  final _storage = const FlutterSecureStorage();
  final logger = Logger();
  String sendOTPURL =
      dotenv.env['SEND_OTP_URL'] ?? 'https://defaulturl.com/api';

  Future<void> sendOtp() async {
    state = const AsyncValue.loading();
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) throw Exception('An error occurred');

      final response = await http.post(
        Uri.parse(sendOTPURL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.data(null);
      } else {
        final exception = 'Failed to send OTP';
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to send OTP: ${response.body}"),
            null,
            reason: 'Send OTP API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics send OTP API response failed $e');
        }
        throw exception;
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error('Failed to end OTP', stackTrace);
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Send OTP controller failed',
      );
    }
  }
}
