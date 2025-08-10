import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../screens/authentication/verification/verify_email.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/helpers/helper_function.dart';

class VerifyIdController {
  static const _secureStorage = FlutterSecureStorage();
  static var identificationCardURL =
      dotenv.env['IDENTIFICATION_CARD_URL'] ?? 'https://defaulturl.com/api';
  static var logger = Logger();

//   static String? _parseErrorMessage(String responseBody) {
//   try {
//     final decoded = jsonDecode(responseBody);
//     if (decoded is Map<String, dynamic> && decoded['message'] != null) {
//       return decoded['message'];
//     }
//   } catch (_) {
//     // If parsing fails, just return null
//   }
//   return null;
// }


  static Future<void> uploadIdentificationCard({
    required BuildContext context,
    required File idImage,
    required String idType,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'token');

      

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(identificationCardURL),
      );

      request.files.add(
        await http.MultipartFile.fromPath('idImage', idImage.path),
      );

      request.fields['idType'] = idType;
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();

      if (response.statusCode == 200) {
        CustomSnackbar.show(
          context: context,
          title: 'Success',
          message: 'Identification card uploaded successfully',
          icon: Icons.check_circle,
          backgroundColor: CustomColors.success,
        );
        HelperFunction.navigateScreen(context, VerifyEmailScreen());
      } else {
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to submit user ID: ${response.statusCode}"),
            null,
            reason: 'User ID API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics upload Id response failed $e');
        }

        CustomSnackbar.show(
          context: context,
          title: 'An error occured',
          message:  
             'Failed to upload image. Try again later',
          icon: Icons.error_outline,
          backgroundColor: CustomColors.error,
        );
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Upload Id controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics upload Id controller failed $e');
      }
      CustomSnackbar.show(
        context: context,
        title: 'An error occurred',
        message: 'Failed to upload image. Try again later',
        icon: Icons.error_outline,
        backgroundColor: CustomColors.error,
      );
    }
  }
}
