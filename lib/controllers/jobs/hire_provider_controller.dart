import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// StateNotifier to handle job posting state
class JobController extends StateNotifier<AsyncValue<void>> {
  JobController() : super(const AsyncValue.data(null));

  Future<void> addEmployee({
    required String employerImage,
    required String providerImage,
    required String employerId,
    required String providerId,
    required String employerName,
    required String providerName,
    required String jobTitle,
    required int pay,
    required int duration,
    required double latitude,
    required double longitude,
  }) async {
    state = const AsyncValue.loading();

    try {
      String hireProviderURL = dotenv.env['HIRE_PROVIDER_URL'] ?? 'https://defaulturl.com/api';

      final logger = Logger();
      final response = await http.post(
        Uri.parse(hireProviderURL),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "employerImage": employerImage,
          "providerImage": providerImage,
          "employerId": employerId,
          "providerId": providerId,
          "employerName": employerName,
          "providerName": providerName,
          "jobTitle": jobTitle,
          "pay": pay,
          "duration": duration,
          "latitude": latitude,
          "longitude": longitude
        }),
      );

      if (response.statusCode == 201) {
        state = const AsyncValue.data(null);
      } else {
        final body = jsonDecode(response.body);
        final exception = 'Unable to hire Provider';
        
        try {
          await FirebaseCrashlytics.instance.recordError(
            '${body['message']}',
            null,
            reason: 'Hire provider API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i("Crashlytics logging failed: $e");
        }
        state = AsyncValue.error(
          "An error occured",
          StackTrace.current,
        );
        throw exception;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      await FirebaseCrashlytics.instance.recordError(
        e,
        st,
        reason: 'Hire Provider controller failed',
      );
    }
  }
}

// Provider for the controller
final jobControllerProvider =
    StateNotifierProvider<JobController, AsyncValue<void>>((ref) {
  return JobController();
});
