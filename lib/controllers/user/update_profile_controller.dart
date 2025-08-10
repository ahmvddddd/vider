import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

/// Storage and API constants
final _storage = FlutterSecureStorage();
String updateProfileURL =
    dotenv.env['UPDATE_PROFILE_URL'] ?? 'https/defaulturl.com/api';

final updateBioData = FutureProvider.family<bool, Map<String, dynamic>>((
  ref,
  data,
) async {
  final logger = Logger();

  try {
    final token = await _storage.read(key: 'token');
    final response = await http.put(
      Uri.parse(updateProfileURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final exception = 'Failed to update user bio';
      try {
        await FirebaseCrashlytics.instance.recordError(
          Exception("Failed to update user bio details: ${response.body}"),
          null,
          reason:
              'Update user details API returned error ${response.statusCode}',
        );
      } catch (e) {
        logger.i('Crashlytics update user bio API failed $e');
      }
      throw exception;
    }
  } catch (error, stackTrace) {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Update user details controller failed',
      );
    } catch (e) {
      logger.i('Crashlytics update user bio details failed $e');
    }
    return false;
  }
});
