import 'package:flutter/material.dart';
import '../../../utils/constants/custom_colors.dart';

class FormDivider extends StatelessWidget {
  final String dividerText;
  const FormDivider({
    super.key,required this.dividerText,
  });


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Flexible(child: Divider(color: CustomColors.primary, thickness: 0.5, indent: 60, endIndent: 5,)),
        Text(dividerText, style: Theme.of(context).textTheme.labelMedium,),
        const Flexible(child: Divider(color: CustomColors.primary, thickness: 0.5, indent: 5, endIndent: 60,))
       ],
      );
  }
}