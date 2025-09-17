import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../utils/helpers/capitalize_text.dart';
import '../../../common/widgets/pop_up/custom_snackbar.dart';
import '../../../controllers/jobs/job_request_controller.dart';
import '../../../controllers/notifications/add_notification_controller.dart';
import '../../../controllers/transactions/wallet_controller.dart';
import '../../../controllers/user/user_controller.dart';
import '../../../models/notification/add_notification_model.dart';
import '../../../utils/constants/custom_colors.dart';

class HireValidator {
  /// Validate input fields
  static bool validateJobDetails(
    BuildContext context,
    String? selectedService,
    int count,
    LatLng? selectedLocation,
  ) {
    if (selectedService == null) {
      CustomSnackbar.show(
        context: context,
        title: 'No Service Selected',
        message: 'Please select a service.',
        icon: Icons.error_outline,
        backgroundColor: CustomColors.error,
      );
      return false;
    }
    if (count <= 0) {
      CustomSnackbar.show(
        context: context,
        title: 'Duration not set',
        message: 'Please enter the number of hours.',
        icon: Icons.error_outline,
        backgroundColor: CustomColors.error,
      );
      return false;
    }
    if (selectedLocation == null) {
      CustomSnackbar.show(
        context: context,
        title: 'Missing Location',
        message: 'Select your location on the map.',
        icon: Icons.error_outline,
        backgroundColor: CustomColors.error,
      );
      return false;
    }
    return true;
  }

  /// Check balance (async version)
  static Future<bool> checkAccountBalance(
    WidgetRef ref,
    double totalPay,
    BuildContext context,
  ) async {
    final walletState = ref.read(walletProvider);

    return walletState.when(
      data: (wallet) {
        if (wallet.usdcBalance < totalPay) {
          CustomSnackbar.show(
            context: context,
            title: 'Insufficient Balance',
            message: 'Your balance is not enough to create a job request.',
            backgroundColor: CustomColors.error,
            icon: Icons.error_outline,
          );
          return false;
        }
        return true;
      },
      loading: () {
        // force fetch if needed
        ref.read(walletProvider.notifier).fetchBalance();
        CustomSnackbar.show(
          context: context,
          title: 'Checking Wallet...',
          message: 'Please wait while we verify your balance.',
          backgroundColor: CustomColors.primary,
          icon: Icons.refresh,
        );
        return false;
      },
      error: (err, st) {
        CustomSnackbar.show(
          context: context,
          title: 'Wallet Error',
          message: 'Could not verify your wallet balance. Please refresh.',
          backgroundColor: CustomColors.error,
          icon: Icons.error_outline,
        );
        return false;
      },
    );
  }

  /// Perform the hire + notification flow
  static Future<void> hireProvider({
    required BuildContext context,
    required WidgetRef ref,
    required String? selectedService,
    required int count,
    required LatLng? selectedLocation,
    required double totalPay,
    required String providerId,
    required String providerName,
    required String providerImage,
    required VoidCallback onSuccess,
  }) async {
    // 1. Validate job details
    if (!validateJobDetails(context, selectedService, count, selectedLocation)) {
      return;
    }

    // 2. Validate balance
    final hasBalance = await checkAccountBalance(ref, totalPay, context);
    if (!hasBalance) return;

    // 3. Get user profile
    final userState = ref.read(userProvider);
    userState.when(
      data: (user) async {
        final vvid = await ref.read(jobRequestProvider.future);

        final jobDetails = JobDetails(
          employerId: user.userId,
          providerId: providerId,
          employerImage: user.profileImage,
          providerImage: providerImage,
          employerName: "${user.firstname.capitalizeEachWord()} ${user.lastname.capitalizeEachWord()}",
          providerName: providerName,
          jobTitle: selectedService!,
          pay: totalPay,
          duration: count,
          startTime: DateTime.now(),
          latitude: selectedLocation!.latitude,
          longitude: selectedLocation.longitude,
          vvid: vvid!,
        );

        final notification = AddNotificationModel(
          type: "job_request",
          title: "New Job Request",
          message:
              "${user.firstname} ${user.lastname} wants to hire you for $selectedService for $count hour(s).",
          recipientId: providerId,
          jobDetails: jobDetails,
        );

        try {
          await ref.read(addNotificationProvider(notification).future);
          if (context.mounted) {
            CustomSnackbar.show(
              context: context,
              title: 'Success',
              message: 'Job created successfully!',
              backgroundColor: CustomColors.success,
              icon: Icons.check_circle_outline,
            );
            onSuccess();
          }
        } catch (e) {
          if (context.mounted) {
            CustomSnackbar.show(
              context: context,
              title: 'Error',
              message: 'Failed to send notification: $e',
              backgroundColor: CustomColors.error,
              icon: Icons.error_outline,
            );
          }
        }
      },
      loading: () {
        CustomSnackbar.show(
          context: context,
          title: 'Loading Profile...',
          message: 'Fetching employer details.',
          backgroundColor: CustomColors.primary,
          icon: Icons.refresh,
        );
      },
      error: (err, st) {
        CustomSnackbar.show(
          context: context,
          title: 'Profile Error',
          message: 'Could not fetch employer details: $err',
          backgroundColor: CustomColors.error,
          icon: Icons.error_outline,
        );
      },
    );
  }
}

