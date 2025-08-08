// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../../utils/constants/sizes.dart';

class DetailsText extends StatelessWidget {
  const DetailsText({
    super.key, 
    this.textColor, 
    this.showActionButton = true, 
    required this.title, 
    required this.details,
  });

  final Color? textColor;
  final bool showActionButton;
  final String title;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
             style: Theme.of(context).textTheme.labelMedium!.apply(color: textColor),),
            Text(details,
             style: Theme.of(context).textTheme.bodyMedium!.apply(color: textColor),),
          ],
        ),
        SizedBox(height: Sizes.spaceBtwItems)
      ],
    );
  }
}

