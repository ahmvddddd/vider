import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../../nav_menu.dart';
import '../../models/user/user_model.dart';
import '../../repository/user/username_local_storage.dart';
import '../../utils/helpers/helper_function.dart';
import '../services/firebase_service.dart';
import '../user/user_controller.dart';

// Secure storage instance
const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

// Provider
final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
      return LoginController(ref);
    });

// Controller
class LoginController extends StateNotifier<LoginState> {
  final Ref ref;
  final String signinUrl =
      dotenv.env['SIGNIN_URL'] ?? 'https://defaulturl.com/api';

  LoginController(this.ref) : super(LoginState());

  String formatBackendError(String message) {
    if (message.contains('Invalid username or password')) {
      return 'Your login details are incorrect.';
    } else if (message.contains('Account locked. Try again in 15 minutes.')) {
      return 'Account locked. Try again in 15 minutes.';
    } else {
      return message;
    }
  }

  static Future<bool> isUserStillLoggedIn() async {
    final token = await _secureStorage.read(key: 'token');
    final timestampStr = await _secureStorage.read(key: 'loginTimestamp');

    if (token == null || timestampStr == null) return false;

    final loginTime = DateTime.tryParse(timestampStr);
    if (loginTime == null) return false;

    final now = DateTime.now();
    final difference = now.difference(loginTime);

    return difference.inDays < 7;
  }

  Future<void> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await http.post(
        Uri.parse(signinUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'userType': 'client',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final user = User(
          username: responseData['username'],
          password: responseData['password'],
        );

        await Future.wait([
          _secureStorage.write(key: 'token', value: responseData['token']),
          _secureStorage.write(
            key: 'loginTimestamp',
            value: DateTime.now().toIso8601String(),
          ),
          UsernameLocalStorage.saveUsername(username),
        ]);

        // Optional: Register FCM
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          saveFcmTokenToBackend();
        });

        state = state.copyWith(isLoading: false, user: user);

        // Navigate to the main screen
        ref.read(selectedIndexProvider.notifier).state = 0;
        HelperFunction.navigateScreenReplacement(context, NavigationMenu());

        // Fetch user profile via UserController
        await ref.read(userProvider.notifier).fetchUserDetails();
      } else {
        final responseData = jsonDecode(response.body);
        final rawError = responseData['message'] ?? 'Signin failed';
        final formattedError =
            response.statusCode == 500
                ? 'Something went wrong on our side. Please try again later.'
                : formatBackendError(rawError);

        state = state.copyWith(isLoading: false, error: formattedError);
        await FirebaseCrashlytics.instance.recordError(
          Exception("Login failed: $formattedError"),
          null,
          reason: 'Login API error ${response.statusCode}',
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
        reason: 'Login controller error',
      );
    }
  }
}
