import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/inputs/custom_keypad.dart';
import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../controllers/transactions/change_pin_controller.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';

class ChangePinPage extends ConsumerStatefulWidget {
  const ChangePinPage({super.key});

  @override
  ConsumerState<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends ConsumerState<ChangePinPage> {
  List<String> currentPin = ['', '', '', ''];
  List<String> newPin = ['', '', '', ''];
  bool isEnteringNewPin = false;
  String? error;

  void _enterDigit(String digit) {
    setState(() {
      final pin = isEnteringNewPin ? newPin : currentPin;
      for (int i = 0; i < 4; i++) {
        if (pin[i].isEmpty) {
          pin[i] = digit;
          break;
        }
      }

      if (!pin.contains('')) {
        if (isEnteringNewPin) {
          _submitPins();
        } else {
          isEnteringNewPin = true;
        }
      }
    });
  }

  void _removeDigit() {
    setState(() {
      final pin = isEnteringNewPin ? newPin : currentPin;
      for (int i = 3; i >= 0; i--) {
        if (pin[i].isNotEmpty) {
          pin[i] = '';
          break;
        }
      }
    });
  }

  Future<void> _submitPins() async {
    final controller = ref.read(changePinControllerProvider);
    final result = await controller.changePin(
      currentPin: currentPin.join(),
      newPin: newPin.join(),
    );

    if (result == null) {
      if (mounted) {
        CustomSnackbar.show(
          context: context,
          title: 'Success',
          message: 'Your PIN has been changed successfully.',
          icon: Icons.check_circle,
          backgroundColor: CustomColors.success,
        );
        Navigator.pop(context);
      }
    } else {
      setState(() {
        error = result;
        currentPin = ['', '', '', ''];
        newPin = ['', '', '', ''];
        isEnteringNewPin = false;
      });
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
    final pin = isEnteringNewPin ? newPin : currentPin;

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Change Transaction PIN',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isEnteringNewPin ? "Enter New PIN" : "Enter Current PIN",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: Sizes.spaceBtwItems),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pin.map((digit) {
              return Container(
                margin: const EdgeInsets.all(8),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    digit.isEmpty ? "•" : digit,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 30),
                  ),
                ),
              );
            }).toList(),
          ),
          if (error != null) ...[
            const SizedBox(height: Sizes.spaceBtwItems),
            Text(error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: Sizes.spaceBtwItems),
          CustomKeypad(
            onDigitPressed: _enterDigit,
            onBackspace: _removeDigit,
          ),
        ],
      ),
    );
  }
}


