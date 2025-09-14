import 'package:flutter/material.dart';
import '../../../../utils/constants/custom_colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_function.dart';
import '../containers/rounded_container.dart';

class CategoryCard extends StatelessWidget {
  final String potfolioImage;
  final String imageAvatar;
  final String fullname;
  final String service;
  final Color ratingColor;
  final double rating;
  final String description;
  final double hourlyRate;

  const CategoryCard({
    super.key,
    required this.potfolioImage,
    required this.imageAvatar,
    required this.fullname,
    required this.ratingColor,
    required this.rating,
    required this.service,
    required this.description,
    required this.hourlyRate,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final dark = HelperFunction.isDarkMode(context);
    return RoundedContainer(
      width: screenWidth * 0.90,
      height: screenHeight * 0.32,
      backgroundColor: dark ? Colors.black : Colors.white,
      boxShadow: [
        BoxShadow(
          color: CustomColors.darkGrey,
          blurRadius: 5,
          spreadRadius: 0.5,
          offset: const Offset(0, 2),
        ),
      ],
      padding: const EdgeInsets.all(Sizes.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: screenHeight * 0.14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Sizes.cardRadiusMd),
                topRight: Radius.circular(Sizes.cardRadiusMd),
              ),
              image: DecorationImage(
                image: NetworkImage(potfolioImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: Sizes.sm),
          Padding(
            padding: const EdgeInsets.all(Sizes.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
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
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: dark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              service,
                              style: Theme.of(context).textTheme.labelMedium!
                                  .copyWith(color: CustomColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(width: Sizes.md),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: ratingColor,
                          size: Sizes.iconMd,
                        ),
                        Text(
                          rating.toString(),
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

                //description
                const SizedBox(height: Sizes.sm),
                SizedBox(
                  width: screenWidth * 0.80,
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),

                const SizedBox(height: Sizes.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '\$$hourlyRate',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: CustomColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
