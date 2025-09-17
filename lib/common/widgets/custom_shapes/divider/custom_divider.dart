import 'package:flutter/material.dart';
import '../../../../utils/helpers/helper_function.dart';
import '../../../../utils/constants/custom_colors.dart';

class CustomDivider extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  const CustomDivider({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return Padding(
      padding: padding,
      child: Divider(color: dark ? CustomColors.alternate : CustomColors.primary),
    );
  }
}
