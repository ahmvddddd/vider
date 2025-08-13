import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../nav_menu.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/helpers/helper_function.dart';
import 'wallet_controller.dart';

final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, bool>(
      (ref) => SubscriptionController(ref),
    );

class SubscriptionController extends StateNotifier<bool> {
  final Ref ref;
  SubscriptionController(this.ref) : super(false);

  final _storage = const FlutterSecureStorage();
  String subscriptionPlanURL =
      dotenv.env['SUBSCRIPTION_PLAN_URL'] ?? 'https://default.com/api';

  Future<void> updateSubscriptionPlan(String plan, BuildContext context) async {
    state = true;
    final logger = Logger();

    try {
      final token = await _storage.read(key: 'token');
      final response = await http.put(
        Uri.parse(subscriptionPlanURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'subscriptionPlan': plan}),
      );

      if (response.statusCode == 200) {
        await ref.read(walletProvider.notifier).fetchBalance();
        CustomSnackbar.show(
          context: context,
          title: 'Success',
          message: 'Your subscription was changed successfully',
          icon: Icons.check_circle,
          backgroundColor: CustomColors.success,
        );
        ref.read(selectedIndexProvider.notifier).state = 3;
        HelperFunction.navigateScreenReplacement(context, NavigationMenu());
      } else {
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to submit subscription plan: ${response.body}"),
            null,
            reason:
                'Subscription plan API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics subscription plan api failed $e');
        }
        CustomSnackbar.show(
          context: context,
          title: 'Error',
          message: 'Failed to change your subscription plan',
          icon: Icons.error_outline,
          backgroundColor: CustomColors.error,
        );
        state = false;
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'User bio controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics subscription plan controller failed $e');
      }
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: 'Failed to change your subscription plan',
        icon: Icons.error_outline,
        backgroundColor: CustomColors.error,
      );
      state = false;
    }
  }
}
