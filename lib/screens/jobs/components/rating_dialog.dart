import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/pop_up/custom_snackbar.dart';
import '../../../controllers/rating/rating_controller.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';

class RatingDialog extends ConsumerStatefulWidget {
  final String profileId;

  const RatingDialog({super.key, required this.profileId});

  @override
  ConsumerState<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends ConsumerState<RatingDialog> {
  int _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    final ratingState = ref.watch(ratingControllerProvider);
    final dark = HelperFunction.isDarkMode(context);

    return AlertDialog(
      title: const Text("Rate Provider"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "How would you rate this provider?",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: Sizes.spaceBtwItems),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  Icons.star,
                  color: index < _selectedRating ? Colors.amber : Colors.grey,
                ),
                onPressed: () {
                  setState(() => _selectedRating = index + 1);
                },
              );
            }),
          ),
          if (ratingState.isLoading)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 4.0,
                backgroundColor: dark ? Colors.white : Colors.black,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(color: CustomColors.error),
          ),
        ),
        ElevatedButton(
          onPressed:
              _selectedRating == 0 || ratingState.isLoading
                  ? null
                  : () async {
                    await ref
                        .read(ratingControllerProvider.notifier)
                        .rateUser(widget.profileId, _selectedRating);

                    if (context.mounted) {
                      Navigator.pop(context);
                      CustomSnackbar.show(
                        context: context,
                        title: 'Success',
                        message: 'Rating submitted successfully',
                        icon: Icons.check_circle,
                        backgroundColor: CustomColors.success,
                      );
                    }
                  },
          child: Text("Submit", style: Theme.of(context).textTheme.labelMedium),
        ),
      ],
    );
  }
}
