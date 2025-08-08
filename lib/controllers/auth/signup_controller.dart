// // ignore_for_file: use_build_context_synchronously

// ignore_for_file: use_build_context_synchronously

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/user/user_model.dart';
import '../../repository/user/username_local_storage.dart';
import '../../screens/authentication/user_details/user_details.dart';
import '../../utils/helpers/helper_function.dart';
import '../services/firebase_service.dart';

const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

final signupControllerProvider =
    StateNotifierProvider<SignupController, SignupState>((ref) {
      return SignupController();
    });

class SignupController extends StateNotifier<SignupState> {
  SignupController() : super(SignupState());
  final String signupUrl =
      dotenv.env['SIGNUP_URL'] ?? 'https://defaulturl.com/api';

  String formatBackendError(String message) {
    if (message.contains('User already exists')) {
      return 'An account with this email already exists.';
    } else if (message.contains('Invalid username or password')) {
      return 'Your login details are incorrect.';
    } else if (message.toLowerCase().contains('password')) {
      return 'Password does not meet the required criteria.';
    } else {
      return message;
    }
  }

  Future<void> signup(
    BuildContext context,
    String firstname,
    String lastname,
    String username,
    String email,
    String password,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await http.post(
        Uri.parse(signupUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstname': firstname,
          'lastname': lastname,
          'username': username,
          'email': email,
          'password': password,
          'userType': 'provider',
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        await Future.wait([
          // Save the token in secure storage
          _secureStorage.write(key: 'token', value: responseData['token']),
          // Save username to local storage
          UsernameLocalStorage.saveUsername(username)
        ]);

        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          saveFcmTokenToBackend();
        });

        // Navigate to the new page
        // HelperFunction.navigateScreenReplacement(context, UserDetailsScreen());
      } else {
        final responseData = jsonDecode(response.body);
        final rawError = responseData['message'] ?? 'Signup failed';

        final formattedError =
            response.statusCode == 500
                ? 'Something went wrong on our side. Please try again later.'
                : formatBackendError(rawError);

        state = state.copyWith(
          isLoading: false,
          error: "An error occurred. Please try again later.",
        );
        await FirebaseCrashlytics.instance.recordError(
          Exception("Signup failed: $formattedError"),
          null,
          reason: 'Signup API returned error ${response.statusCode}',
        );
      }
    } catch (error, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: "An error occurred. Please try again later.",
      );
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Signup controller error ',
      );
    }
  }
}
