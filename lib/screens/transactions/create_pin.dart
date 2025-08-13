import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../controllers/transactions/pin_provider.dart';
import '../../controllers/transactions/wallet_controller.dart';
import '../../nav_menu.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../common/widgets/inputs/custom_keypad.dart';
import '../../utils/helpers/helper_function.dart';
import '../../utils/helpers/token_secure_storage.dart';

class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  bool isConfirming = false;
  String? originalPin;
  String? error;

  void onSubmitPin() async {
    final pin = ref.read(pinStateProvider.notifier).pin;

    if (pin.length < 4) return;

    if (!isConfirming) {
      originalPin = pin;
      isConfirming = true;
      ref.read(pinStateProvider.notifier).reset();
      setState(() {});
    } else {
      if (originalPin == pin) {

        await TokenSecureStorage.checkToken(context: context, ref: ref);
        
        final walletController = ref.read(walletControllerProvider);

        final result = await walletController.createPin(pin: pin);
        if (result == null) {
          // success
          if (mounted) {
            CustomSnackbar.show(
                          context: context,
                          title: 'Success',
                          message: 'Your transaction PIN has been created',
                          icon: Icons.check_circle,
                          backgroundColor: CustomColors.success,
                        );
            HelperFunction.navigateScreen(context, NavigationMenu());
          }
        } else {
          setState(() => error = result);
        }
      } else {
        setState(() => error = 'PINs do not match');
        ref.read(pinStateProvider.notifier).reset();
        isConfirming = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pin = ref.watch(pinStateProvider);

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Create Transaction PIN',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isConfirming ? "Confirm PIN" : "Enter a 4-digit PIN",
              style: Theme.of(context).textTheme.bodySmall,
            ),
        
            const SizedBox(height: Sizes.spaceBtwItems),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  pin.map((digit) {
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
                          digit.isEmpty ? "•" : "*",
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge!.copyWith(fontSize: 30),
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
              onDigitPressed: (digit) {
                ref.read(pinStateProvider.notifier).enterDigit(digit);
                if (ref.read(pinStateProvider).every((d) => d.isNotEmpty)) {
                  onSubmitPin();
                }
              },
              onBackspace:
                  () => ref.read(pinStateProvider.notifier).removeDigit(),
            ),
          ],
        ),
      ),
    );
  }
}
