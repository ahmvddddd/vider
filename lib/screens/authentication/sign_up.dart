import 'package:flutter/material.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import 'widgets/form_divider.dart';
import 'widgets/sign_up_form.dart';

class SignupScreen extends StatelessWidget {
  final VoidCallback toggleScreen;
  const SignupScreen({super.key, required this.toggleScreen});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.spaceBtwItems),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),
              Text(
                'Create Your Account',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: CustomColors.primary,
                ),
              ),
              SizedBox(
                width: screenWidth * 0.70,
                child: Text(
                  'Enter your personal details to sign up',
                  style: Theme.of(context).textTheme.bodySmall,
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: Sizes.spaceBtwItems),
              const SignUpForm(),

              const SizedBox(height: Sizes.spaceBtwItems),
              const FormDivider(dividerText: 'Already a user ?'),

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
                        'Sign in',
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
    );
  }
}
