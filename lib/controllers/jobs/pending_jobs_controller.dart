import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class JobCheckResult {
  final bool hasPendingJob;
  final Map<String, dynamic>? job;

  JobCheckResult({required this.hasPendingJob, this.job});

  factory JobCheckResult.fromJson(Map<String, dynamic> json) {
    return JobCheckResult(
      hasPendingJob: json['hasPendingJob'],
      job: json['job'],
    );
  }
}

// Provider to check if user has a pending job
final pendingJobsProvider =
    FutureProvider.family<JobCheckResult, String>((ref, userId) async {
  final pendingJobsURL = dotenv.env['PENDING_JOBS_URL'] ?? 'https://defaulturl.com/api';

  final response = await http.get(Uri.parse('$pendingJobsURL$userId'), headers: {
    "Content-Type": "application/json",
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return JobCheckResult.fromJson(data);
  } else {
    throw Exception("Failed to check pending job: ${response.body}");
  }
});
