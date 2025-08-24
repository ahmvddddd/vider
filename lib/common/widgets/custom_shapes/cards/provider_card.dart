import 'package:flutter/material.dart';
import 'package:myapp/common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../utils/constants/custom_colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_function.dart';

class ProviderCard extends StatelessWidget {
  final String imageAvatar;
  final String fullname;
  final String service;
  final Color ratingColor;
  final double rating;
  final String description;
  final String portfolioImage;
  final double hourlyRate;

  const ProviderCard({
    super.key,
    required this.imageAvatar,
    required this.fullname,
    required this.ratingColor,
    required this.rating,
    required this.service,
    required this.description,
    required this.portfolioImage,
    required this.hourlyRate
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final dark = HelperFunction.isDarkMode(context);
    return Container(
      height: screenHeight * 0.32,
      width: screenWidth * 0.63,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.cardRadiusLg),
        border: Border.all(
          color: dark ? CustomColors.darkGrey : CustomColors.darkGrey,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(Sizes.xs),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
              child: Image.network(
                portfolioImage,
                fit: BoxFit.cover,
                height: screenHeight * 0.13,
                width: screenWidth * 0.63,
              ),
            ),
          ),

          const SizedBox(height: Sizes.xs,),
          Container(
            color:
                dark
                    ? Colors.black.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.8),
            padding: const EdgeInsets.symmetric(horizontal: Sizes.sm, vertical: Sizes.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(height: Sizes.sm),
                    CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(imageAvatar),
                  ),

                  const SizedBox(width: Sizes.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullname,
                          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: dark ? Colors.white : Colors.black,
                          ),
                        ),

                //description
                Text(
                  service,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    fontSize: 9,
                    color: CustomColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                      ],
                    ),

                    const SizedBox(width: Sizes.sm),
                    RoundedContainer(
                      radius: Sizes.cardRadiusXs,
                      backgroundColor: ratingColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.xs + 2,
                        vertical: 3,
                      ),
                      child: Center(
                        child: Text(
                          rating.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium!.copyWith(
                            fontSize: 8,
                            color: Colors.black,
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Sizes.sm),
                SizedBox(
                  width: screenWidth * 0.60,
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),

          const SizedBox(height: Sizes.sm),
          Text(
            '\$$hourlyRate/hour',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: CustomColors.success),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
