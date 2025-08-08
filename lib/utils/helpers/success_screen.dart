import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../common/widgets/custom_shapes/containers/button_container.dart';
import '../constants/custom_colors.dart';
import '../constants/image_strings.dart';
import '../constants/sizes.dart';

class SuccessScreen extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final String subtitle;

  const SuccessScreen({super.key, required this.onPressed, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ButtonContainer(text: 'Done', onPressed: onPressed),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                Images.successAnimation,
                height: MediaQuery.of(context).size.height * 0.3,
              ), // your asset path
              const SizedBox(height: Sizes.spaceBtwItems),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: CustomColors.success,
                ),
              ),
              const SizedBox(height: Sizes.sm),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
