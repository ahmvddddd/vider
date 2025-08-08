import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../screens/authentication/reset_password/reset_password_screen.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/helpers/helper_function.dart';

String resetOtpUrl =
    dotenv.env['RESET_OTP_URL'] ?? 'https://defaulturl.com/api';

final logger = Logger();

class SendOtpState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  SendOtpState({this.isLoading = false, this.isSuccess = false, this.error});

  SendOtpState copyWith({bool? isLoading, bool? isSuccess, String? error}) {
    return SendOtpState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}

// ---- CONTROLLER ----
class SendOtpController extends StateNotifier<SendOtpState> {
  SendOtpController() : super(SendOtpState());

  String formatBackendError(String message) {
    if (message.contains('No user found with this email')) {
      return 'An  error occurred with your account. Could not reset password';
    } else {
      return message;
    }
  }

  Future<void> sendOtp(String email, BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final response = await http.post(
        Uri.parse(resetOtpUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        HelperFunction.navigateScreen(
          context,
          ResetPasswordScreen(email: email),
        );
      } else {
        final responseData = jsonDecode(response.body);
        final rawError = responseData['message'] ?? 'Failed to reset password';

        final formattedError =
            response.statusCode == 500
                ? 'Something went wrong on our side. Please try again later.'
                : formatBackendError(rawError);
        state = state.copyWith(
          isLoading: false,
          error: formattedError,
        );
          CustomSnackbar.show(
            context: context,
            title: 'Error',
            message: formattedError,
            icon: Icons.error_outline,
            backgroundColor: CustomColors.error,
          );
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to send reset password OTP: ${response.body}"),
            null,
            reason:
                'Reset password OTP API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics reset password OTP API response failed $e');
        }
      }
    } catch (error, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong: ${error.toString()}',
      );
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Reset password OTP controller failed',
      );
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: 'An  error occurred with your account. Could not reset password',
        icon: Icons.error_outline,
        backgroundColor: CustomColors.error,
      );
    }
  }
}

// ---- PROVIDER ----
final sendOtpControllerProvider =
    StateNotifierProvider<SendOtpController, SendOtpState>(
      (ref) => SendOtpController(),
    );
