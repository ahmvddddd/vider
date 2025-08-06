// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../common/widgets/appbar/appbar.dart';
// import '../../../common/widgets/custom_shapes/containers/button_container.dart';
// import '../../../common/widgets/pop_up/custom_snackbar.dart';
// import '../../../common/widgets/texts/title_and_description.dart';
// import '../../../controllers/verification_controllers/otp_timer_controller.dart';
// import '../../../controllers/verification_controllers/send_otp_controller.dart';
// import '../../../controllers/verification_controllers/verify_otp_controller.dart';
// import '../../../utils/constants/custom_colors.dart';
// import '../../../utils/constants/sizes.dart';
// import '../../../utils/helpers/helper_function.dart';
// import '../../../utils/helpers/token_secure_storage.dart';
// import '../../transactions/create_pin.dart';

// class VerifyEmailScreen extends ConsumerStatefulWidget {
//   const VerifyEmailScreen({super.key});

//   @override
//   ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
// }

// class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
//   final List<TextEditingController> _controllers =
//       List.generate(6, (_) => TextEditingController());
//   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
//   bool _hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       ref.read(sendOtpProvider.notifier).sendOtp();
//     });
//     _focusNodes.first.requestFocus();
//   }

//   String _formatTime(int seconds) {
//     final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
//     final secs = (seconds % 60).toString().padLeft(2, '0');
//     return '$minutes:$secs';
//   }

//   void _handlePaste(String pastedText) {
//     final digitsOnly = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
//     if (digitsOnly.length == 6) {
//       for (int i = 0; i < 6; i++) {
//         _controllers[i].text = digitsOnly[i];
//       }
//       FocusScope.of(context).unfocus();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dark = HelperFunction.isDarkMode(context);
//     final sendOtpState = ref.watch(sendOtpProvider);
//     final verifyOtpState = ref.watch(verifyOtpProvider);
//     final secondsLeft = ref.watch(otpTimerProvider);

//     return Scaffold(
//       appBar: TAppBar(
//         title: Text(
//           'Verify Email',
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//         showBackArrow: true,
//       ),
//       bottomNavigationBar: ButtonContainer(
//               text: verifyOtpState.isLoading ? 'Verifyng' : 'Proceed',
//               onPressed: () async {
//                 final code = _controllers.map((c) => c.text).join();
//                 if (code.length < 6) {
//                   setState(() => _hasError = true);
//                   return;
//                 }
    
//                 setState(() => _hasError = false);
    
//                 await ref
//                     .read(verifyOtpProvider.notifier)
//                     .verifyOtp(code, context, ref);
    
//                 final result = ref.read(verifyOtpProvider);
//                 result.whenOrNull(
//                   data: (_) => HelperFunction.navigateScreen(
//                     context,
//                     const CreatePinScreen(),
//                   ),
//                   error: (e, _) => CustomSnackbar.show(
//                     context: context,
//                     title: 'An error occured',
//                     message: 'Failed to verify OTP. Try agin later',
//                     icon: Icons.error_outline,
//                     backgroundColor: CustomColors.error,
//                   ),
//                 );
//               },
//             ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(Sizes.spaceBtwItems),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: Sizes.spaceBtwItems),
//               const TitleAndDescription(
//                 textAlign: TextAlign.left,
//                 title: 'Almost There',
//                 description:
//                     'Please enter the verification code sent to your email. Check your spam folder if you can not find the OTP email',
//               ),
//               const SizedBox(height: Sizes.spaceBtwSections),
    
//               // OTP INPUT ROW
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: List.generate(6, (index) {
//                   return AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     width: 45,
//                     height: 55,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: _hasError ? Colors.red : Colors.transparent,
//                         width: 1.5,
//                       ),
//                       color: dark ? CustomColors.dark : CustomColors.light,
//                     ),
//                     child: TextFormField(
//                       controller: _controllers[index],
//                       focusNode: _focusNodes[index],
//                       keyboardType: TextInputType.number,
//                       textAlign: TextAlign.center,
//                       maxLength: 1,
//                       style: Theme.of(context).textTheme.titleLarge,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly
//                       ],
//                       onChanged: (value) {
//                         if (value.length > 1) {
//                           _handlePaste(value);
//                           return;
//                         }
//                         if (value.isNotEmpty && index < 5) {
//                           FocusScope.of(context)
//                               .requestFocus(_focusNodes[index + 1]);
//                         } else if (value.isEmpty && index > 0) {
//                           FocusScope.of(context)
//                               .requestFocus(_focusNodes[index - 1]);
//                         }
//                         setState(() => _hasError = false); // reset error
//                       },
//                       decoration: const InputDecoration(
//                         counterText: '',
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   );
//                 }),
//               ),
    
//               const SizedBox(height: Sizes.spaceBtwItems),
    
//               // TIMER OR SEND OTP
//               secondsLeft > 0
//                   ? Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           'Code expires in',
//                           style: Theme.of(context).textTheme.labelSmall,
//                         ),
//                         const SizedBox(width: Sizes.xs),
//                         Text(
//                           _formatTime(secondsLeft),
//                           style: Theme.of(context)
//                               .textTheme
//                               .labelSmall!
//                               .copyWith(color: Colors.red[900]),
//                         ),
//                       ],
//                     )
//                   : TextButton(
//                       onPressed: sendOtpState.isLoading
//                           ? null
//                           : () async {
//                               await TokenSecureStorage.checkToken(
//                                   context: context, ref: ref);
//                               await ref
//                                   .read(sendOtpProvider.notifier)
//                                   .sendOtp();
//                               final result = ref.read(sendOtpProvider);
//                               result.whenOrNull(
//                                 error: (e, _) => ScaffoldMessenger.of(
//                                   context,
//                                 ).showSnackBar(
//                                   SnackBar(content: Text(e.toString())),
//                                 ),
//                               );
//                               ref
//                                   .read(otpTimerProvider.notifier)
//                                   .start(); // restart timer
//                             },
//                       child: Text(
//                         sendOtpState.isLoading ? 'Sending...' : 'Send OTP',
//                         style: TextStyle(
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                       ),
//                     ),
    
//               const SizedBox(height: Sizes.spaceBtwItems),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
