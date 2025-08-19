import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../models/providers/providers_category_model.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../common/widgets/texts/section_heading.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import 'provider_map.dart';

class ProviderScreen extends StatefulWidget {
  final ProvidersCategoryModel profile;
  const ProviderScreen({super.key, required this.profile});

  @override
  State<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);

    // ✅ Boolean variable instead of function
    final bool hasValidLocation =
        (widget.profile.latitude != null &&
            widget.profile.longitude != null &&
            widget.profile.latitude > 0 &&
            widget.profile.longitude > 0);

    Color ratingColor = Colors.brown;
    if (widget.profile.rating < 1.66) {
      setState(() {
        ratingColor = Colors.brown;
      });
    } else if (widget.profile.rating < 1.66 && widget.profile.rating >= 3.33) {
      setState(() {
        ratingColor = CustomColors.silver;
      });
    } else if (widget.profile.rating >= 5.00) {
      setState(() {
        ratingColor = CustomColors.gold;
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Service Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileImage(
              imageAvatar: widget.profile.profileImage,
              fullname:
                  '${widget.profile.firstname} ${widget.profile.lastname}',
              ratingColor: ratingColor,
              rating: widget.profile.rating,
              service: widget.profile.service,
              hourlyRate: widget.profile.hourlyRate,
            ),

            const SizedBox(height: Sizes.sm),
            Container(
              padding: const EdgeInsets.all(Sizes.spaceBtwItems),
              decoration: BoxDecoration(
                color:
                    dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: Sizes.spaceBtwItems),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: HomeListView(
                          sizedBoxHeight:
                              MediaQuery.of(context).size.height * 0.06,
                          scrollDirection: Axis.horizontal,
                          seperatorBuilder:
                              (context, index) => const Padding(
                                padding: EdgeInsets.all(Sizes.sm),
                                child: VerticalDivider(
                                  color: CustomColors.primary,
                                ),
                              ),
                          itemCount: widget.profile.skills.length,
                          itemBuilder:
                              (context, index) => Services(
                                service: widget.profile.skills[index],
                              ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          /// ✅ Location icon wrapped with GestureDetector
                          GestureDetector(
                            onTap: () {
                              if (hasValidLocation) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProviderMapScreen(
                                          profileLatitude:
                                              widget.profile.latitude,
                                          profileLongitude:
                                              widget.profile.longitude,
                                          profileImage:
                                              widget.profile.profileImage,
                                        ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Location not available"),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(Sizes.sm),
                              decoration: BoxDecoration(
                                color:
                                    dark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: CustomColors.darkGrey,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color:
                                    hasValidLocation
                                        ? Colors.red
                                        : Colors
                                            .grey, // ✅ color depends on validity
                                size: Sizes.iconMd,
                              ),
                            ),
                          ),

                          const SizedBox(width: Sizes.sm),
                          Container(
                            padding: const EdgeInsets.all(Sizes.sm),
                            decoration: BoxDecoration(
                              color: CustomColors.primary,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: CustomColors.darkGrey,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Iconsax.message,
                              color: Colors.white,
                              size: Sizes.iconMd,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: Sizes.spaceBtwItems),
                  SectionHeading(title: 'About', showActionButton: false),
                  const SizedBox(height: Sizes.sm),
                  Text(
                    widget.profile.bio,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dark ? Colors.white : Colors.black,
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
                    itemCount: widget.profile.portfolioImages.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Sizes.borderRadiusLg,
                        ),
                        child: Image.network(
                          widget.profile.portfolioImages[index],
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
                  ).textTheme.bodySmall!.copyWith(color: Colors.black),
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

class Services extends StatelessWidget {
  final String service;
  const Services({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: Sizes.xs + 1,
      ),
      child: Center(
        child: Text(
          service,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: dark ? Colors.white : Colors.black,
          ),
          softWrap: true,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
