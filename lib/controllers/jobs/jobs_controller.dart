import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../utils/helpers/connectivity_helper.dart';

class JobRepository {
  final storage = const FlutterSecureStorage();
  String employerJobsURL =
      dotenv.env['EMPLOYER_JOBS_URL'] ?? 'https://defaulturl.com/api';
  final logger = Logger();

  Future<List<dynamic>> fetchEmployerJobs(Ref ref) async {
    final connectivity = ref.read(connectivityProvider);

    if (!connectivity.isOnline) {
      throw Exception('No Internet. Please check your internet connection');
    }
    
    try {
      final token = await storage.read(key: 'token');
      final response = await http.get(
        Uri.parse(employerJobsURL),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final exception = 'Failed to load jobs';
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to fetch jobs: ${response.body}"),
            null,
            reason: 'Fetch jobs API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics fetch jobs API response failed');
        }
        throw exception;
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Fetch jobs controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics fetch jobs controller failed $e');
      }
      throw Exception('Failed to load jobs');
    }
  }
}

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});

final jobsFutureProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final repository = ref.read(jobRepositoryProvider);
  return repository.fetchEmployerJobs(ref);
});
