import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../screens/authentication/auth_screen.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/helpers/helper_function.dart';

String resetPasswordUrl =
    dotenv.env['RESET_PASSWORD_URL'] ?? 'https://defaulturl.com/api';

final logger = Logger();

// ---- STATE CLASS ----
class ResetPasswordState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  ResetPasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}

// ---- CONTROLLER ----
class ResetPasswordController extends StateNotifier<ResetPasswordState> {
  ResetPasswordController() : super(ResetPasswordState());

  String formatBackendError(String message) {
    if (message.contains('User not found')) {
      return 'An  error occurred with your account. Could not reset password';
    } else if (message.contains('Invalid OTP')) {
      return 'OTP provided is invalid';
    } else if (message.contains('OTP has expired')) {
      return 'OTP has expired';
    } else if (message.toLowerCase().contains('password')) {
      return 'Password does not meet the required criteria.';
    } else {
      return message;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required BuildContext context,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final response = await http.post(
        Uri.parse(resetPasswordUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        HelperFunction.navigateScreen(context, AuthScreen());
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
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to reset password: ${response.body}"),
            null,
            reason: 'Reset password API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics reset password API response failed $e');
        }
        CustomSnackbar.show(
          context: context,
          title: 'Error',
          message: formattedError,
          icon: Icons.error_outline,
          backgroundColor: CustomColors.error,
        );
      }
    } catch (error, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong: ${error.toString()}',
      );
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Reset password  controller failed',
      );
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: 'An  error occurred. Could not reset password',
        icon: Icons.error_outline,
        backgroundColor: CustomColors.error,
      );
    }
  }
}

// ---- PROVIDER ----
final resetPasswordControllerProvider =
    StateNotifierProvider<ResetPasswordController, ResetPasswordState>(
      (ref) => ResetPasswordController(),
    );
