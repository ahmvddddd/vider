import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../common/widgets/pop_up/custom_snackbar.dart';
import '../../../common/widgets/texts/title_and_description.dart';
import '../../../controllers/auth/change_password_controller.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/helpers/responsive_size.dart';
import '../../../utils/validators/validation.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final hideCurrentPassword = ValueNotifier<bool>(true);
  final hideNewPassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(changePasswordProvider.notifier)
          .changePassword(
            context: context,
            currentPassword: _currentController.text,
            newPassword: _newController.text,
          );
      final state = ref.read(changePasswordProvider);
      if (!state.hasError) {
        CustomSnackbar.show(
          context: context,
          title: 'Password changed',
          message: 'Password changed successfully',
          backgroundColor: CustomColors.success,
          icon: Icons.check_circle,
        );
        _currentController.clear();
        _newController.clear();
      } else {
        CustomSnackbar.show(
          context: context,
          title: 'An error occured',
          message: state.error.toString(),
          backgroundColor: CustomColors.error,
          icon: Icons.cancel,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final dark = HelperFunction.isDarkMode(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: TAppBar(
          title: Text(
            'Change Password',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          showBackArrow: true,
        ),
        bottomNavigationBar: SizedBox(
          width: double.infinity,
          child: Container(
            padding: EdgeInsets.all(responsiveSize(context, Sizes.spaceBtwItems)),
            color:
                dark
                    ? CustomColors.white.withValues(alpha: 0.1)
                    : CustomColors.black.withValues(alpha: 0.1),
            child: SizedBox(
              width: double.infinity,
              height: screenHeight * 0.06,
              child: GestureDetector(
                onTap: state.isLoading ? null : _handleChangePassword,
                child: RoundedContainer(
                  height: screenHeight * 0.06,
                  padding: const EdgeInsets.all(Sizes.sm),
                  backgroundColor: CustomColors.primary,
                  child: Center(
                    child:
                        state.isLoading
                            ? Text(
                              'Saving Password...',
                              style: Theme.of(context).textTheme.labelSmall!
                                  .copyWith(color: Colors.white),
                            )
                            : Text(
                              'Change Password',
                              style: Theme.of(context).textTheme.labelSmall!
                                  .copyWith(color: Colors.white),
                            ),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(responsiveSize(context, Sizes.spaceBtwItems)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleAndDescription(
                      textAlign: TextAlign.left,
                      title: 'Enter current password',
                      description:
                          'Enter your current password bellow, ensure the textfield is filled correctly',
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    ValueListenableBuilder<bool>(
                      valueListenable: hideCurrentPassword,
                      builder: (context, value, child) {
                        return TextFormField(
                          controller: _currentController,
                          obscureText: value,
                          decoration: InputDecoration(
                            hintText: 'Current Password',
                            hintStyle: Theme.of(context).textTheme.labelSmall,
                            suffixIcon: IconButton(
                              onPressed:
                                  () => hideCurrentPassword.value = !value,
                              icon: Icon(
                                value ? Iconsax.eye_slash : Iconsax.eye,
                              ),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter current password'
                                      : null,
                        );
                      },
                    ),
                    SizedBox(height: responsiveSize(context, Sizes.spaceBtwItems)),
                    TitleAndDescription(
                      textAlign: TextAlign.left,
                      title: 'Enter new password ',
                      description:
                          'Password must contain at least one uppercase, one lower case one special character and at least 6 characters long',
                    ),
                    SizedBox(height: responsiveSize(context, Sizes.spaceBtwItems)),
                    ValueListenableBuilder<bool>(
                      valueListenable: hideNewPassword,
                      builder: (context, value, child) {
                        return TextFormField(
                          controller: _newController,
                          obscureText: value,
                          decoration: InputDecoration(
                            hintText: 'Enter New Password',
                            hintStyle: Theme.of(context).textTheme.labelSmall,
                            suffixIcon: IconButton(
                              onPressed: () => hideNewPassword.value = !value,
                              icon: Icon(
                                value ? Iconsax.eye_slash : Iconsax.eye,
                              ),
                            ),
                          ),
                          validator: (value) {
                            return Validator.validatePassword(value);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
