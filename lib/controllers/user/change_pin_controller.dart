import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'package:logger/logger.dart';

final changePinControllerProvider = Provider((ref) => ChangePinController());

class ChangePinController {
  final _storage = const FlutterSecureStorage();
  final logger = Logger();
  String changePinURL =
      dotenv.env['CHANGE_PIN_URL'] ?? 'https//defaulturl.com/api';

  String formatBackendError(String message) {
    if (message.contains('Wallet not found')) {
      return 'An  error occurred with your account. Could not change PIN';
    } else if (message.contains('Current PIN is incorrect')) {
      return 'Current PIN is incorrect';
    } else {
      return message;
    }
  }

  Future<String?> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    try {
      final token = await _storage.read(key: 'token');

      final response = await http.put(
        Uri.parse(changePinURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'currentPin': currentPin, 'newPin': newPin}),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final responseData = jsonDecode(response.body);
        final rawError = responseData['message'] ?? 'Failed to change transaction PIN';

        final formattedError =
            response.statusCode == 500
                ? 'Something went wrong on our side. Please try again later.'
                : formatBackendError(rawError);
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
      throw Exception('An error occurred, unable to change PIN');
    }
  }
}
