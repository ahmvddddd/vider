import 'package:flutter/material.dart';
import '../../../utils/constants/sizes.dart';
import '../custom_shapes/containers/rounded_container.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon, //  icons_check_circle icons_error_outline
    int durationInSeconds = 4,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoundedContainer(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(Sizes.xs),
                child: Icon(icon, size: Sizes.iconMd, color: Colors.white),
              ),
              const SizedBox(width: Sizes.xs),
              Expanded( // ✅ Prevent overflow by letting the column take available space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // ✅ Prevent Column from taking infinite height
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white),
                      softWrap: true,
                      overflow: TextOverflow.visible, // ✅ Allow wrapping
                    ),
                  ],
                ),
              ),
            ],
          ),
          duration: Duration(seconds: durationInSeconds),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.cardRadiusSm),
          ),
        ),

    );
  }
}
