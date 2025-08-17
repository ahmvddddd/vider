import 'package:flutter/material.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../models/providers/providers_category_model.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../common/widgets/texts/section_heading.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';

class ProviderScreen extends StatelessWidget {
  final ProvidersCategoryModel profile;
  const ProviderScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(title: Text('Service Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileImage(
              imageAvatar: profile.profileImage,
              fullname: '${profile.firstname} ${profile.lastname}',
              ratingColor: Colors.brown,
              rating: 2,
              service: profile.service,
              hourlyRate: profile.hourlyRate,
            ),

            const SizedBox(height: Sizes.sm),
            Container(
              padding: const EdgeInsets.all(Sizes.spaceBtwItems),
              decoration: BoxDecoration(
                color:
                    dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: Sizes.spaceBtwSections),
                  SectionHeading(title: 'Skills', showActionButton: false),
                  const SizedBox(height: Sizes.sm),
                  HomeListView(
                    sizedBoxHeight: MediaQuery.of(context).size.height * 0.06,
                    scrollDirection: Axis.horizontal,
                    seperatorBuilder:
                        (context, index) => const SizedBox(width: Sizes.sm),
                    itemCount: profile.skills.length,
                    itemBuilder:
                        (context, index) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Sizes.cardRadiusSm,
                            ),
                            color: dark ? Colors.black : Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: Sizes.xs + 1,
                          ),
                          child: Center(
                            child: Text(
                              profile.skills[index],
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall!.copyWith(
                                color: dark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                  ),

                  const SizedBox(height: Sizes.spaceBtwSections),
                  SectionHeading(title: 'About', showActionButton: false),
                  const SizedBox(height: Sizes.sm),
                  Text(
                    profile.bio,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  ),

                  const SizedBox(height: Sizes.spaceBtwSections),
                  SectionHeading(title: 'Portfolio', showActionButton: false),
                  const SizedBox(height: Sizes.sm),
                  HomeListView(
                    sizedBoxHeight: MediaQuery.of(context).size.height * 0.40,
                    scrollDirection: Axis.horizontal,
                    seperatorBuilder:
                        (context, index) => const SizedBox(width: Sizes.sm),
                    itemCount: profile.portfolioImages.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Sizes.borderRadiusLg,
                        ),
                        child: Image.network(
                          profile.portfolioImages[index],
                          width: MediaQuery.of(context).size.height * 0.40,
                          height: MediaQuery.of(context).size.height * 0.30,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: Sizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  final String imageAvatar;
  final String fullname;
  final Color ratingColor;
  final double rating;
  final String service;
  final double hourlyRate;

  const ProfileImage({
    super.key,
    required this.imageAvatar,
    required this.fullname,
    required this.ratingColor,
    required this.rating,
    required this.service,
    required this.hourlyRate,
  });

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.20,
          width: MediaQuery.of(context).size.height * 0.20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: dark ? CustomColors.darkGrey : CustomColors.darkGrey,
              width: 2,
            ),
          ),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                imageAvatar,
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.20,
                width: MediaQuery.of(context).size.height * 0.20,
              ),
            ),
          ),
        ),

        const SizedBox(height: Sizes.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              fullname,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: Sizes.xs),
            RoundedContainer(
              backgroundColor: ratingColor,
              radius: Sizes.cardRadiusXs,
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.xs + 2,
                vertical: 2,
              ),
              child: Center(
                child: Text(
                  rating.toString(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        Text(service, style: Theme.of(context).textTheme.bodySmall),
        Text(
          '\$$hourlyRate',
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: CustomColors.success,
            fontFamily: 'JosefinSans',
          ),
        ),

        const SizedBox(height: Sizes.sm),
      ],
    );
  }
}
