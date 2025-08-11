import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../common/widgets/pop_up/custom_snackbar.dart';
import '../../../controllers/auth/sign_up_controller.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/validators/validation.dart';
import 'build_textfield.dart';
import 'terms_and_conditions.dart';

class SignUpForm extends ConsumerWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signupState = ref.watch(signupControllerProvider);
    final signupController = ref.read(signupControllerProvider.notifier);

    final formKey = GlobalKey<FormState>();
    final firstnameController = TextEditingController();
    final lastnameController = TextEditingController();
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final hidePassword = ValueNotifier<bool>(true);
    final hideConfirmPassword = ValueNotifier<bool>(true);
    final termsAccepted = ValueNotifier<bool>(false);

    final isDark = HelperFunction.isDarkMode(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Form(
      key: formKey,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            const SizedBox(height: Sizes.spaceBtwItems),
            BuildTextfield(
              controller: firstnameController,
              icon: Iconsax.user,
              hint: 'Firstname',
              validator: (value) => Validator.validateTextField(value),
            ),
            const SizedBox(height: Sizes.spaceBtwItems),
            BuildTextfield(
              controller: lastnameController,
              icon: Iconsax.user,
              hint: 'Lastname',
              validator: (value) => Validator.validateTextField(value),
            ),
            const SizedBox(height: Sizes.spaceBtwItems),
            BuildTextfield(
              controller: usernameController,
              icon: Iconsax.user,
              hint: 'Username',
              validator: (value) => Validator.validateTextField(value),
            ),
            const SizedBox(height: Sizes.spaceBtwItems),
            BuildTextfield(
              controller: emailController,
              icon: Iconsax.direct,
              hint: 'Email',
              isEmail: true,
              validator: (value) => Validator.validateEmail(value),
            ),
            const SizedBox(height: Sizes.spaceBtwItems),

            /// Password
            _buildPasswordField(
              context,
              controller: passwordController,
              hidePassword: hidePassword,
              label: 'Password',
              isDark: isDark,
            ),
            const SizedBox(height: Sizes.spaceBtwItems),

            /// Confirm Password
            _buildPasswordField(
              context,
              controller: confirmPasswordController,
              hidePassword: hideConfirmPassword,
              label: 'Confirm Password',
              isDark: isDark,
              validator: (value) {
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            const SizedBox(height: Sizes.spaceBtwItems),

            /// Terms & Conditions Checkbox
            ValueListenableBuilder<bool>(
              valueListenable: termsAccepted,
              builder: (context, value, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: value,
                          onChanged:
                              (checked) =>
                                  termsAccepted.value = checked ?? false,
                        ),
                        GestureDetector(
                          onTap:
                              () => showDialog(
                                context: context,
                                builder:
                                    (_) => const TermsAndConditionsDialog(),
                              ),
                          child: Text.rich(
                            TextSpan(
                              text: 'I accept the ',
                              style: Theme.of(context).textTheme.labelSmall,
                              children: [
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(color: CustomColors.primary),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: Sizes.spaceBtwItems),

            /// Sign Up Button
            signupState.isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ), // color
                    strokeWidth: 4.0, // thickness of the line
                    backgroundColor:
                        isDark
                            ? Colors.white
                            : Colors.black, // background circle color
                  ),
                )
                : SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      if (!termsAccepted.value) {
                        CustomSnackbar.show(
                          context: context,
                          title: 'Accept Terms and conditions',
                          message: 'Please accept the terms and conditions',
                          backgroundColor: CustomColors.error,
                          icon: Icons.error_outline,
                        );
                        return;
                      }

                      if (formKey.currentState!.validate()) {
                        signupController.signup(
                          context,
                          firstnameController.text.trim(),
                          lastnameController.text.trim(),
                          usernameController.text.trim(),
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      }
                    },
                    child: RoundedContainer(
                      height: screenHeight * 0.06,
                      padding: const EdgeInsets.all(Sizes.sm),
                      backgroundColor: CustomColors.primary,
                      child: Center(
                        child: Text(
                          'Sign Up',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall!.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),

            if (signupState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  signupState.error!,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium!.copyWith(color: Colors.red[900]),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required TextEditingController controller,
    required ValueNotifier<bool> hidePassword,
    required String label,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.borderRadiusLg),
        color: isDark ? CustomColors.dark : CustomColors.light,
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: hidePassword,
        builder: (context, hide, child) {
          return TextFormField(
            controller: controller,
            obscureText: hide,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: const Icon(Iconsax.password_check),
              hintText: label,
              hintStyle: Theme.of(context).textTheme.labelSmall,
              suffixIcon: IconButton(
                icon: Icon(hide ? Iconsax.eye_slash : Iconsax.eye),
                onPressed: () => hidePassword.value = !hide,
              ),
            ),
            validator:
                validator ?? (value) => Validator.validatePassword(value),
          );
        },
      ),
    );
  }
}
