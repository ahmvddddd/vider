import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';

class TitleAndDescription extends StatelessWidget {
  const TitleAndDescription(
      {super.key, required this.title, required this.description, this.textAlign = TextAlign.center});

  final String title;
  final String description;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
      SizedBox(
          width: screenWidth * 0.70,  
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: textAlign,
        ),
      ),
      const SizedBox(height: Sizes.sm),
        SizedBox(
          width: screenWidth * 0.70,
          child: Text(
            description,
            style: Theme.of(context).textTheme.labelMedium,
            softWrap: true,
            maxLines: 3,
            textAlign: textAlign,
          ),
        )
      ],
    );
  }
}

