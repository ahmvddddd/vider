import 'package:flutter/material.dart';
import '../../../utils/constants/sizes.dart';

class TextFieldContainer extends StatelessWidget {
    final String hintText;
    final int? maxLength;
    final int? maxLines;
    final TextEditingController controller;
    final TextInputType keyboardType;
    final void Function(String)? onSubmitted;
    final String? Function(String?)? validator;
    final String? errorText;
  const TextFieldContainer({
    super.key,
    this.maxLength,
    this.maxLines,
    required this.hintText,
    required this.controller,
    required this.keyboardType,
    this.onSubmitted,
    this.validator,
    this.errorText
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.spaceBtwItems),
      child: TextField(
        maxLength: maxLength,
        maxLines: maxLines,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.labelSmall,
          errorText: errorText
        ),
        onSubmitted: onSubmitted,
        // validator: validator
      ),
    );
  }
}

