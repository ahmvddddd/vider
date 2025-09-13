import 'package:flutter/material.dart';

import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';

class SomeContainer extends StatelessWidget {
  const SomeContainer({
    super.key,
    required this.profileImage,
    required this.fullname,
    required this.ratingColor,
    required this.rating,
  });

  final String profileImage;
  final String fullname;
  final Color ratingColor;
  final String rating;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return RoundedContainer(
      width: MediaQuery.of(context).size.width * 0.90,
      padding: const EdgeInsets.all(Sizes.xs),
      radius: Sizes.cardRadiusLg,
      backgroundColor:
          dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(profileImage)),
              const SizedBox(width: Sizes.sm),
              Row(
                children: [
                  Text(fullname, style: Theme.of(context).textTheme.labelSmall),

                  const SizedBox(width: Sizes.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: ratingColor,
                            size: Sizes.iconSm,
                          ),
                          Text(
                            rating,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(
                              color: dark ? Colors.white : Colors.black,
                              fontFamily: 'JosefinSans',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
