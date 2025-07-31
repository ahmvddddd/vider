import 'package:flutter/material.dart';
import '../../../../utils/constants/custom_colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_function.dart';
import '../containers/rounded_container.dart';

class CategoryCard extends StatelessWidget {
  final String imageAvatar;
  final String fullname;
  final String service;
  final Color ratingColor;
  final double rating;
  final String description;
  final double hourlyRate;

  const CategoryCard({
    super.key,
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
      width: screenWidth * 0.80,
      height: screenHeight * 0.23,
      backgroundColor: dark ? Colors.black : Colors.white,
      boxShadow: [
        BoxShadow(
          color: CustomColors.darkGrey,
          blurRadius: 5,
          spreadRadius: 0.5,
          offset: const Offset(0, 2),
        ),
      ],
      padding: const EdgeInsets.all(Sizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: dark ? Colors.white : Colors.white,
                      ),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          imageAvatar,
                          fit: BoxFit.contain,
                          height: screenHeight * 0.055,
                          width: screenHeight * 0.055,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: Sizes.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullname,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
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

              RoundedContainer(
                radius: 40,
                backgroundColor: ratingColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.xs + 2,
                  vertical: 2,
                ),
                child: Center(
                  child: Text(
                    rating.toString(),
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: Colors.white,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                ),
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
              maxLines: 3,
              softWrap: true,
            ),
          ),

          const SizedBox(height: Sizes.sm),
          Text(
            '\$$hourlyRate (hourly rate)',
            style: Theme.of(
              context,
            ).textTheme.labelSmall!.copyWith(color: CustomColors.success),
          ),
        ],
      ),
    );
  }
}
