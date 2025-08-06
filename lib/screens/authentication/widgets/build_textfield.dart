import 'package:flutter/material.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';

class BuildTextfield extends StatelessWidget {
  const BuildTextfield(
      {super.key,
      required this.controller,
      required this.icon,
      required this.hint,
      this.isEmail = false,  this.validator
      });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool isEmail;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return Container(
      decoration: BoxDecoration(
        color: dark ? CustomColors.dark : CustomColors.light,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            size: Sizes.iconSm,
            color: dark ? CustomColors.light : CustomColors.dark,
          ),
          contentPadding: const EdgeInsets.all(2),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.labelSmall,
        ),
        validator: validator,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      ),
    );
  }
}
