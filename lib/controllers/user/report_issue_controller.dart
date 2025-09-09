import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../utils/constants/custom_colors.dart';

class ReportIssueController {
  static final logger = Logger();

  /// Launch Gmail (if available) or fallback to default mail client.
  /// If no email app is found, shows a Snackbar instead of crashing.
  static Future<void> launchGmailCompose(
    BuildContext context,
    String subject,
  ) async {
    try {
      if (Platform.isAndroid) {
        final Uri gmailUri = Uri.parse(
          "intent://compose?to=vider_support@gmail.com&subject=$subject"
          "#Intent;package=com.google.android.gm;scheme=mailto;end",
        );

        if (await canLaunchUrl(gmailUri)) {
          await launchUrl(gmailUri);
          return;
        }
      }

      // fallback: generic mailto
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'vider_support@gmail.com',
        queryParameters: {'subject': subject},
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
      } else {
        _showNoEmailClientMessage(context);
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'ReportIssueController failed',
        );
      } catch (e) {
        logger.e('Crashlytics reporting failed: $e');
      }
      _showNoEmailClientMessage(context);
    }
  }

  /// Show user-friendly message when no email client is available
  static void _showNoEmailClientMessage(BuildContext context) {
    CustomSnackbar.show(
      context: context,
      title: 'An error occured',
      message: 'No email app found. Please install Gmail or another mail app.',
      icon: Icons.error_outline,
      backgroundColor: CustomColors.error
    );
  }
}
