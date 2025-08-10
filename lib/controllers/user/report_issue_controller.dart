import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportIssueController {
  static var logger = Logger();
  static void launchGmailCompose(String subject) async {
    try {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'vider_support@gmail.com',
        queryParameters: {'subject': subject},
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        try {
          await FirebaseCrashlytics.instance.recordError(
            'Failed to launch URL',
            null,
            reason: 'Report an issue controller failed',
          );
        } catch (e) {
          logger.i('Crashlytics report an issue controller failed $e');
        }
        throw Exception('An error occurred');
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Report an issue controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics report an issue controller failed $e');
      }
      throw Exception('An error occurred');
    }
  }
}
