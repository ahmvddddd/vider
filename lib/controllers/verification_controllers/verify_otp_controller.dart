import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../screens/transactions/create_pin.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/helpers/helper_function.dart';
import '../../utils/helpers/token_secure_storage.dart';

final verifyOtpProvider =
    StateNotifierProvider<VerifyOtpNotifier, AsyncValue<void>>((ref) {
      return VerifyOtpNotifier(ref);
    });

class VerifyOtpNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  VerifyOtpNotifier(this.ref) : super(const AsyncValue.data(null));
  final _storage = const FlutterSecureStorage();
  String verifyOTPURL =
      dotenv.env['VERIFY_OTP_URL'] ?? 'https://defaulturl.com/api';

  String formatBackendError(String message) {
    if (message.contains('User not found')) {
      return 'An error occurred, try again later';
    } else if (message.contains('Invalid OTP')) {
      return 'The OTP input is invalid.';
    } else if (message.contains('OTP has expired')) {
      return 'The OTP input is incorrect';
    } else {
      return message;
    }
  }

  Future<void> verifyOtp(String code, BuildContext context, ref) async {
    state = const AsyncValue.loading();
    final logger = Logger();
    try {
      final token = await _storage.read(key: 'token');
      await TokenSecureStorage.checkToken(context: context, ref: ref);

      final response = await http.post(
        Uri.parse(verifyOTPURL),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.data(null);
        CustomSnackbar.show(
          context: context,
          title: 'Success',
          message: 'OTP verified. You are now a verified user',
          icon: Icons.check_circle,
          backgroundColor: CustomColors.success,
        );
        HelperFunction.navigateScreen(context, CreatePinScreen());
      } else {
        final responseData = jsonDecode(response.body);
        final rawError = responseData['message'] ?? 'OTP verification failed';

        final formattedError =
            response.statusCode == 500
                ? 'Something went wrong on our side. Please try again later.'
                : formatBackendError(rawError);
        final error = formattedError;
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to verify OTP: ${response.body}"),
            null,
            reason: 'Verify OTP API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics verify OTP API failed $e');
        }

        CustomSnackbar.show(
          context: context,
          title: 'Error',
          message: 'Failed to verify OTP: $error',
          icon: Icons.error_outline,
          backgroundColor: CustomColors.error,
        );
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error('Failed to verify OTP', stackTrace);
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Verify OTP controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics verify OTP controller failed $e');
      }
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: 'Failed to verify OTP',
        icon: Icons.error_outline,
        backgroundColor: CustomColors.error,
      );
    }
  }
}
