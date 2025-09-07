import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/widgets/custom_shapes/containers/button_container.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';

class DepositScreen extends StatelessWidget {
  final String cryptoAddress;
  const DepositScreen({super.key, required this.cryptoAddress});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final dark = HelperFunction.isDarkMode(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          "Deposit",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      bottomNavigationBar: ButtonContainer(
        text: 'Copy Address',
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: cryptoAddress));
          CustomSnackbar.show(
            context: context,
            title: 'Success',
            message: 'Address copied to clipboard',
            icon: Icons.check_circle,
            backgroundColor: CustomColors.success,
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.spaceBtwItems),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Crypto Address',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Click the button bellow to copy to clipboard',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: Sizes.spaceBtwSections),
            RoundedContainer(
              width: screenWidth * 0.90,
              padding: const EdgeInsets.all(Sizes.sm),
              radius: Sizes.cardRadiusLg,
              backgroundColor:
                  dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cryptoAddress,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
