import 'package:flutter/material.dart';
import '../../../../utils/constants/custom_colors.dart';
class CustomDivider extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  const CustomDivider({
    super.key,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: const Divider(
        color: CustomColors.primary,
      ),
    );
  }
}