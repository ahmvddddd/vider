import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final jobRequestProvider = FutureProvider.autoDispose<String?>((ref) async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  final logger = Logger();
  final jobRequestURL =
      dotenv.env['JOB_REQUEST_URL'] ?? "https://defaulturl.com/api";

  try {
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    final response = await http.post(
      Uri.parse(jobRequestURL),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['vvid'];
    } else {
      final body = jsonDecode(response.body);
      final exception = 'An error occurred while creating a job request';

      try {
        await FirebaseCrashlytics.instance.recordError(
          '${body['message']}',
          null,
          reason: 'Job Request API returned error ${response.statusCode}',
        );
      } catch (e) {
        logger.i("Crashlytics logging failed: $e");
      }

      throw exception;
    }
  } catch (error, stackTrace) {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'Job Request controller failed',
    );
    throw Exception('An error occurred while creating a job request');
  }
});
