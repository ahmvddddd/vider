import 'package:flutter/material.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import 'widgets/form_divider.dart';
import 'widgets/sign_in_form.dart';

class SignInScreen extends StatelessWidget {
  final VoidCallback toggleScreen;
  const SignInScreen({super.key, required this.toggleScreen});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.spaceBtwItems),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.15),
                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: CustomColors.primary,
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.90,
                  child: Text(
                    'Enter your username and password to sign in',
                    style: Theme.of(context).textTheme.bodySmall,
                    softWrap: true,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
      
                const SizedBox(height: Sizes.spaceBtwItems),
                const SignInForm(),
      
                const SizedBox(height: Sizes.spaceBtwItems),
                const FormDivider(dividerText: 'Create an account'),
      
                //signup button
                const SizedBox(height: Sizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: toggleScreen,
                    child: RoundedContainer(
                      height: screenHeight * 0.06,
                      padding: const EdgeInsets.all(Sizes.sm),
                      backgroundColor: CustomColors.primary,
                      child: Center(
                        child: Text(
                          'Sign up',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall!.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
