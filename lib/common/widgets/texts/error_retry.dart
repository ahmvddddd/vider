import 'package:flutter/material.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';

class ErrorRetry extends StatelessWidget {
  final Object err;
  final VoidCallback onPressed;
  const ErrorRetry({super.key,
  required this.err,
  required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$err', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: Sizes.sm),
                    IconButton(
                      onPressed: onPressed,
                        style: IconButton.styleFrom(
                          backgroundColor: CustomColors.primary,
                          padding: const EdgeInsets.all(Sizes.sm),
                        ),
                        icon: const Icon(Icons.refresh, color: Colors.white),)
                  ],
                ),
              );
  }
}