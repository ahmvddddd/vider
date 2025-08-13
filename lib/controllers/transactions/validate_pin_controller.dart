import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'package:logger/logger.dart';

final validatePinControllerProvider = Provider(
  (ref) => ValidatePinController(),
);

class ValidatePinController {
  final _storage = const FlutterSecureStorage();
  final logger = Logger();
  String validatePinURL =
      dotenv.env['VALIDATE_PIN_URL'] ?? 'https//defaulturl.com/api';

  String formatBackendError(String message) {
    if (message.contains('Wallet not found')) {
      return 'An  error occurred with your account.';
    } else if (message.contains('User not found')) {
      return 'An  error occurred with your account.';
    } else {
      return message;
    }
  }

  Future<String?> validatePin({required String currentPin}) async {
    try {
      final token = await _storage.read(key: 'token');

      final response = await http.post(
        Uri.parse(validatePinURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'currentPin': currentPin}),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final responseData = jsonDecode(response.body);
        final rawError = responseData['message'] ?? 'Failed to validate PIN';

        final formattedError =
            response.statusCode == 500
                ? 'Something went wrong on our side. Please try again later.'
                : formatBackendError(rawError);

        // ✅ Only add attempts left if it's actually a number
        if (responseData.containsKey('attemptsLeft') &&
            responseData['attemptsLeft'] != null) {
          return formattedError;
        }
        
        return formattedError;
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'change PIN controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics change PIN controller failed $e');
      }
      throw Exception('An error occurred, failed to validate PIN');
    }
  }
}
