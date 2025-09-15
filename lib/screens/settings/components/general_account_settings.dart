import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../common/widgets/pop_up/custom_snackbar.dart';
import '../../../controllers/user/user_controller.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../transactions/change_pin.dart';
import '../../transactions/transaction_history.dart';
import 'change_password.dart';

class GeneralAccountSettings extends ConsumerStatefulWidget {
  const GeneralAccountSettings({super.key});

  @override
  ConsumerState<GeneralAccountSettings> createState() =>
      _GeneralAccountSettingsState();
}

class _GeneralAccountSettingsState
    extends ConsumerState<GeneralAccountSettings> {
  @override
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userProvider.notifier).fetchUserDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return RoundedContainer(
      padding: const EdgeInsets.symmetric(vertical: Sizes.spaceBtwItems),
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
          _settingsTile(
            context,
            () => HelperFunction.navigateScreen(
                  context,
                  TransactionHistory(),
          ),
          Iconsax.bank,
          'Transactions',
          'View all transactions.',
          ),

          
          const SizedBox(height: Sizes.spaceBtwItems),
          _settingsTile(context, () => HelperFunction.navigateScreen(
                  context,
                  ChangePasswordPage(),
                ),
                Iconsax.password_check, 'Password', 'Change your account password'),

          const SizedBox(height: Sizes.spaceBtwItems),
          _settingsTile(
            context,
           () => HelperFunction.navigateScreen(context, ChangePinPage()),
           Iconsax.security_card, 
           'Change PIN', 
           'Change your transaction PIN'
           ),
          
          const SizedBox(height: Sizes.spaceBtwItems),
          _settingsTile(context, 
          () async {
              final userState = ref.read(userProvider);

              userState.when(
                data: (user) async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'vider_support@gmail.com',
                    query: Uri.encodeQueryComponent(
                      'subject=Report An Issue&body=I @${user.username} want to report an issue',
                    ),
                  );
                  await launchUrl(emailLaunchUri);
                },
                loading: () {},
                error: (err, stack) {
                  return CustomSnackbar.show(
                    title: 'An error occured',
                    message: 'Unable to send report at this time',
                    context: context,
                    icon: Icons.error_outline,
                    backgroundColor: CustomColors.error
                  );
                },
              );
            },
            Iconsax.security_safe, 
             'Safety', 
             'Report a failed transaction or a problem.',),
          

          const SizedBox(height: Sizes.spaceBtwItems),
        ],
      ),
    );
  }

  Widget _settingsTile(BuildContext context,
  VoidCallback onTap,
  IconData icon,
  String title,
  String subTitle
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.sm, horizontal: Sizes.spaceBtwItems),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: Sizes.iconSm,),
                
                const SizedBox(width: Sizes.spaceBtwItems),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.50,
                      child: Text(
                        subTitle,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                )
              ],
            ),
        
            Icon(Iconsax.arrow_right_1, size: Sizes.iconSm,)
          ],
        ),
      ),
    );
  }
}
