import 'package:flutter/material.dart';

import '../../../utils/helpers/helper_function.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = "Ok",
    this.cancelText = "Cancel",
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return AlertDialog(
      backgroundColor: dark ? Colors.black : Colors.white,
      title: Text(title, style: Theme.of(context).textTheme.labelLarge),
      content: Text(message, style: Theme.of(context).textTheme.labelLarge),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            cancelText,
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmText,
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(color: Colors.green),
          ),
        ),
      ],
    );
  }
}
