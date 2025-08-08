import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Storage and API constants
final _storage = FlutterSecureStorage();
final logger = Logger();
String userBioURL = dotenv.env['USER_BIO_URL'] ?? 'https://defaulturl.com/api';
String occupationsURL =
    dotenv.env['OCCUPATIONS_URL'] ?? 'https://defaulturl.com/api';

/// Provider to fetch occupations (category + services)
final occupationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await http.get(Uri.parse(occupationsURL));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load occupations');
  }
});

/// Provider to update DOB, bio, category, and service
final updateUserBioProvider = FutureProvider.family<bool, Map<String, dynamic>>(
  (ref, data) async {
    try {
      final token = await _storage.read(key: 'token');

      final response = await http.post(
        Uri.parse(userBioURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to submit user bio details: ${response.body}"),
            null,
            reason: 'User bio API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics API response failed $e');
        }
        return false;
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'User bio controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics bio controller failed $e');
      }
      return false;
    }
  },
);
