import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/widgets/inputs/custom_keypad.dart';
import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../controllers/auth/sign_out_controller.dart';
import '../../controllers/transactions/validate_pin_controller.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/responsive_size.dart';

class ValidatePinDialog extends ConsumerStatefulWidget {
  const ValidatePinDialog({super.key});

  @override
  ConsumerState<ValidatePinDialog> createState() => _ValidatePinDialogState();
}

class _ValidatePinDialogState extends ConsumerState<ValidatePinDialog> {
  List<String> currentPin = ['', '', '', ''];
  String? error;

  void _enterDigit(String digit) {
    setState(() {
      for (int i = 0; i < 4; i++) {
        if (currentPin[i].isEmpty) {
          currentPin[i] = digit;
          break;
        }
      }

      if (!currentPin.contains('')) {
        _submitPin();
      }
    });
  }

  void _removeDigit() {
    setState(() {
      for (int i = 3; i >= 0; i--) {
        if (currentPin[i].isNotEmpty) {
          currentPin[i] = '';
          break;
        }
      }
    });
  }

  Future<void> _submitPin() async {
  final controller = ref.read(validatePinControllerProvider);
  final result = await controller.validatePin(currentPin: currentPin.join());

  if (result == null) {
    if (mounted) Navigator.pop(context, true); // success
  } else {
    setState(() {
      error = result;
      currentPin = ['', '', '', ''];
    });
 
    if (result.toLowerCase().contains('suspended')) {
      await ref.read(signoutControllerProvider.notifier).signOut(context);
      return;
    }

    CustomSnackbar.show(
      context: context,
      title: 'Error',
      message: result,
      icon: Icons.error_outline,
      backgroundColor: CustomColors.error,
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Transaction PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: currentPin.map((digit) {
              return Container(
                margin: EdgeInsets.all(responsiveSize(context, 8)),
                width: responsiveSize(context, 30),
                height: responsiveSize(context, 30),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    digit.isEmpty ? "•" : "*",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: responsiveSize(context, 30)),
                  ),
                ),
              );
            }).toList(),
          ),
          if (error != null) ...[
            SizedBox(height: responsiveSize(context, Sizes.spaceBtwItems)),
            Text(error!, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: CustomColors.error),
            textAlign: TextAlign.center,),
          ],
          SizedBox(height: responsiveSize(context, Sizes.spaceBtwItems)),
          CustomKeypad(onDigitPressed: _enterDigit, onBackspace: _removeDigit),
        ],
      ),
    );
  }
}
