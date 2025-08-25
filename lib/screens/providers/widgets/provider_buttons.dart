import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/widgets/pop_up/custom_alert_dialog.dart';
import '../../../controllers/user/report_issue_controller.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';

class ProviderButtons extends StatelessWidget {
  const ProviderButtons({
    super.key,
    required this.hasValidLocation,
    required this.providerMapWidget,
    required this.employeruserName,
    required this.messageWidget,
  });

  final bool hasValidLocation;
  final String employeruserName;
  final Widget providerMapWidget;
  final Widget messageWidget;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.spaceBtwItems),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                title: 'Report User',
                message: 'Are you sure you want to report this user?',
                onCancel: () => Navigator.of(context).pop(false),
                onConfirm: () => Navigator.of(context).pop(true),
              );
            },
          );

          if (confirm == true) {
            ReportIssueController.launchGmailCompose('Report $employeruserName');
          }
        },
                child: Container(
                  padding: const EdgeInsets.all(Sizes.sm),
                  height: screenHeight * 0.08,
                  width: screenHeight * 0.08,
                  decoration: BoxDecoration(
                    color:
                        dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: CustomColors.darkGrey, width: 2),
                  ),
                  child: Icon(Icons.block, color: Colors.red, size: Sizes.iconMd),
                ),
              ),

              const SizedBox(height: Sizes.xs),
              Text('Report', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),

          Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (hasValidLocation) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => providerMapWidget,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Location not available")),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(Sizes.sm),
                  height: screenHeight * 0.08,
                  width: screenHeight * 0.08,
                  decoration: BoxDecoration(
                    color:
                        dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: CustomColors.darkGrey, width: 2),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color:
                        hasValidLocation
                            ? Colors.red
                            : Colors.grey, // ✅ color depends on validity
                    size: Sizes.iconMd,
                  ),
                ),
              ),

              const SizedBox(height: Sizes.xs),
              Text('Location', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),

          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => messageWidget,
                      ),
                    );
                },
                child: Container(
                  padding: const EdgeInsets.all(Sizes.sm),
                  height: screenHeight * 0.08,
                  width: screenHeight * 0.08,
                  decoration: BoxDecoration(
                    color: CustomColors.primary,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: CustomColors.darkGrey, width: 2),
                  ),
                  child: Center(
                    child: const Icon(
                      Iconsax.message,
                      color: Colors.white,
                      size: Sizes.iconMd,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: Sizes.xs),
              Text('Message', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
