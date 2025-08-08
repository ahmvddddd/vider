import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/custom_shapes/containers/button_container.dart';
import '../../../common/widgets/texts/title_and_description.dart';
import '../../../controllers/verification_controllers/reset_otp_controller.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';

class EnterEmailScreen extends ConsumerWidget {
  const EnterEmailScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final emailController = TextEditingController();
    final sendOtpState = ref.watch(sendOtpControllerProvider);
    final sendOtpController = ref.read(sendOtpControllerProvider.notifier);
    final dark = HelperFunction.isDarkMode(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Enter Email',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        showBackArrow: true,
      ),
      bottomNavigationBar: ButtonContainer(
        backgroundColor: CustomColors.primary,
        onPressed: () {
          sendOtpController.sendOtp(emailController.text.trim(), context);
        },
    
        text: 'Submit',
      ),
      body: sendOtpState.isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue,
                  ), // color
                  strokeWidth: 4.0, // thickness of the line
                  backgroundColor: dark ? Colors.white : Colors.black,
                ),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(Sizes.spaceBtwItems),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleAndDescription(
                        textAlign: TextAlign.left,
                        title: 'Enter your email',
                        description:
                            'Enter your current email registered to this account to recieve OTP',
                      ),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter email',
                          hintStyle: Theme.of(context).textTheme.labelSmall,
                          suffixIcon: Icon(Iconsax.direct),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter current password'
                                    : null,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
