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
                    Text('$err', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: Sizes.sm),
                    TextButton(
                      onPressed: onPressed,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(Sizes.sm),
                        backgroundColor: CustomColors.primary,
                      ),
                      child: Text("Retry",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.white),),
                    ),
                  ],
                ),
              );
  }
}