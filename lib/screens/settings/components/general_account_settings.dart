import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../common/widgets/list_tile/settings_menu_tile.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../transactions/change_pin.dart';
import '../../transactions/transaction_history.dart';
import 'change_password.dart';

class GeneralAccountSettings extends StatelessWidget {
  const GeneralAccountSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return RoundedContainer(
      boxShadow: [
        BoxShadow(
          color: dark ? CustomColors.darkerGrey : CustomColors.darkGrey,
          blurRadius: 5,
          spreadRadius: 0.5,
          offset: const Offset(0, 1),
        ),
      ],
      backgroundColor: dark ? Colors.black : Colors.white,
      child: Column(
        children: [
          SettingsMenuTile(
            icon: Iconsax.bank,
            title: 'Transactions',
            subTitle: 'View all transactions.',
            onTap:
                () => HelperFunction.navigateScreen(
                  context,
                  TransactionHistory(),
                ),
            trailing: Icon(Icons.arrow_right),
          ),

          const SizedBox(height: Sizes.sm),
          SettingsMenuTile(
            onTap:
                () => HelperFunction.navigateScreen(
                  context,
                  ChangePasswordPage(),
                ),
            icon: Iconsax.password_check,
            title: 'Password',
            subTitle: 'Change password.',
            trailing: Icon(Icons.arrow_right),
          ),

          const SizedBox(height: Sizes.sm),
          SettingsMenuTile(
            onTap:
                () => HelperFunction.navigateScreen(context, ChangePinPage()),
            icon: Iconsax.security_card,
            title: 'Change Pin',
            subTitle: 'Change your transaction pin',
            trailing: Icon(Icons.arrow_right),
          ),

          const SizedBox(height: Sizes.sm),
          SettingsMenuTile(
            onTap: () async {
              // ReportIssueController.launchGmailCompose(context, 'Report An Issue');
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'vider_support@gmail.com',
                  query: Uri.encodeQueryComponent('subject=Report An Issue'),
                );
                await launchUrl(emailLaunchUri);
            },
            icon: Iconsax.security_safe,
            title: 'Safety',
            subTitle: 'Report a failed transaction or a problem.',
            trailing: Icon(Icons.arrow_right),
          ),

          const SizedBox(height: Sizes.spaceBtwItems),
        ],
      ),
    );
  }
}
