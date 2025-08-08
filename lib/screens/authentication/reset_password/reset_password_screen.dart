import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/custom_shapes/containers/button_container.dart';
import '../../../common/widgets/texts/title_and_description.dart';
import '../../../controllers/verification_controllers/reset_password_controller.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/validators/validation.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPaswwordController = TextEditingController();
  final hideNewPassword = ValueNotifier<bool>(true);
  final hideConfirmPassword = ValueNotifier<bool>(true);

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _hasError = false;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPaswwordController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String getOtpFromFields() {
    return _controllers.map((c) => c.text).join();
  }

  void _handlePaste(String value) {
    if (value.length == 6) {
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = value[i];
      }
      _focusNodes[5].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetState = ref.watch(resetPasswordControllerProvider);
    final resetController = ref.read(resetPasswordControllerProvider.notifier);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Reset Password',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      bottomNavigationBar: ButtonContainer(
         onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final otp = getOtpFromFields();
                  if (otp.length < 6) {
                    setState(() => _hasError = true);
                    return;
                  }
                  resetController.resetPassword(
                    email: widget.email,
                    code: otp,
                    newPassword: newPasswordController.text.trim(),
                    context: context
                  );
                }
              },
    
        text: 'Submit',
      ),
      body: resetState.isLoading
            ?  Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue,
                ), // color
                strokeWidth: 4.0, // thickness of the line
                backgroundColor:
                    dark
                        ? Colors.white
                        : Colors.black, ))
            : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.spaceBtwItems),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Sizes.spaceBtwItems),
                TitleAndDescription(
                  textAlign: TextAlign.left,
                  title: 'Enter 6-digit OTP',
                  description: 'Check your email for the OTP code we sent you.',
                ),
                const SizedBox(height: Sizes.spaceBtwItems),
    
                /// Styled OTP Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 45,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _hasError ? Colors.red : Colors.transparent,
                          width: 1.5,
                        ),
                        color: dark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F1F1),
                      ),
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: Theme.of(context).textTheme.titleLarge,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) {
                          if (value.length > 1) {
                            _handlePaste(value);
                            return;
                          }
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          setState(() => _hasError = false);
                        },
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                      ),
                    );
                  }),
                ),
    
                const SizedBox(height: Sizes.spaceBtwItems * 2),
                TitleAndDescription(
                  textAlign: TextAlign.left,
                  title: 'Enter new password',
                  description:
                      'Password must contain at least one uppercase, one lowercase, one special character and at least 6 characters.',
                ),
                const SizedBox(height: Sizes.spaceBtwItems),
                ValueListenableBuilder<bool>(
                  valueListenable: hideNewPassword,
                  builder: (context, value, child) {
                    return TextFormField(
                      controller: newPasswordController,
                      obscureText: value,
                      decoration: InputDecoration(
                        hintText: 'Enter New Password',
                        suffixIcon: IconButton(
                          onPressed: () => hideNewPassword.value = !value,
                          icon: Icon(value ? Iconsax.eye_slash : Iconsax.eye),
                        ),
                      ),
                      validator: (value) => Validator.validatePassword(value),
                    );
                  },
                ),
    
                const SizedBox(height: Sizes.spaceBtwItems),
                TitleAndDescription(
                  textAlign: TextAlign.left,
                  title: 'Confirm password',
                  description: 'Re-enter your password to confirm it matches.',
                ),
                const SizedBox(height: Sizes.spaceBtwItems),
                ValueListenableBuilder<bool>(
                  valueListenable: hideConfirmPassword,
                  builder: (context, value, child) {
                    return TextFormField(
                      controller: confirmPaswwordController,
                      obscureText: value,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        suffixIcon: IconButton(
                          onPressed: () => hideConfirmPassword.value = !value,
                          icon: Icon(value ? Iconsax.eye_slash : Iconsax.eye),
                        ),
                      ),
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

