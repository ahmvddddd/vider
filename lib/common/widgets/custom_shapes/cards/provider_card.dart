import 'package:flutter/material.dart';
import '../../../../utils/constants/custom_colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_function.dart';

class ProviderCard extends StatelessWidget {
  final String imageAvatar;
  final String fullname;
  final String service;
  final Color ratingColor;
  final double rating;
  final String portfolioImage;

  const ProviderCard({
    super.key,
    required this.imageAvatar,
    required this.fullname,
    required this.ratingColor,
    required this.rating,
    required this.service,
    required this.portfolioImage,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final dark = HelperFunction.isDarkMode(context);
    return Container(
      height: screenHeight * 0.28,
      width: screenWidth * 0.48,
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
                height: screenHeight * 0.18,
                width: screenWidth * 0.48,
              ),
            ),
          ),

          const SizedBox(height: Sizes.sm),
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
                    radius: 16,
                    backgroundImage: NetworkImage(imageAvatar),
                  ),

                  const SizedBox(width: Sizes.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullname,
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: dark ? Colors.white : Colors.black,
                            overflow: TextOverflow.ellipsis
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

                    const SizedBox(width: Sizes.md),
                    Row(
                      children: [
                        Icon(Icons.star, color: ratingColor, size: Sizes.iconM,),
                        Text(
                          rating.toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium!.copyWith(
                            color: dark ? Colors.white : Colors.black,
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),],
            ),
          ),
        ],
      ),
    );
  }
}
