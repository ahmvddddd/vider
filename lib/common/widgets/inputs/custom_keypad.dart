import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';

class CustomKeypad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspace;

  const CustomKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final dark = HelperFunction.isDarkMode(context);

    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '<'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((e) {
              if (e == '') {
                return const SizedBox(width: 60, height: 60);
              } else if (e == '<') {
                return IconButton(
                  icon: const Icon(Icons.backspace),
                  onPressed: onBackspace,
                  iconSize: Sizes.iconMd,
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => onDigitPressed(e),
                    child: Container(
                      height: screenHeight * 0.08,
                      width: screenHeight * 0.08,
                      decoration: BoxDecoration(
                        color: dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Sizes.cardRadiusLg),
                      ),
                      child: Center(
                        child: Text(
                          e,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                );
              }
            }).toList(),
          ),
      ],
    );
  }
}