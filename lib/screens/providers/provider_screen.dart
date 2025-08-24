import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/providers/providers_category_model.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../common/widgets/texts/section_heading.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import 'provider_map.dart';
import 'widgets/provider_profile_image.dart';
import 'widgets/provider_services.dart';

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
    double screenHeight = MediaQuery.of(context).size.height;

    // ✅ Boolean variable instead of function
    final bool hasValidLocation =
        (widget.profile.latitude != null &&
            widget.profile.longitude != null &&
            widget.profile.latitude > 0 &&
            widget.profile.longitude > 0);

    Color ratingColor = Colors.brown;

    if (widget.profile.rating < 1.66) {
      ratingColor = Colors.brown; // Low rating
    } else if (widget.profile.rating < 3.33) {
      ratingColor = CustomColors.silver; // Medium rating
    } else if (widget.profile.rating >= 3.33) {
      ratingColor = CustomColors.gold; // High rating
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

            const SizedBox(height: Sizes.spaceBtwItems),
            HomeListView(
              sizedBoxHeight: MediaQuery.of(context).size.height * 0.06,
              scrollDirection: Axis.horizontal,
              seperatorBuilder:
                  (context, index) => const Padding(
                    padding: EdgeInsets.all(Sizes.sm),
                    child: VerticalDivider(color: CustomColors.primary),
                  ),
              itemCount: widget.profile.skills.length,
              itemBuilder:
                  (context, index) =>
                      Services(service: widget.profile.skills[index]),
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
                      Container(
                        padding: const EdgeInsets.all(Sizes.sm),
                      height: screenHeight * 0.08,
                      width: screenHeight * 0.08,
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
                          Icons.block,
                          color:
                              hasValidLocation
                                  ? Colors.red
                                  : Colors.grey, // ✅ color depends on validity
                          size: Sizes.iconMd,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          if (hasValidLocation) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProviderMapScreen(
                                      profileLatitude: widget.profile.latitude,
                                      profileLongitude:
                                          widget.profile.longitude,
                                      profileImage: widget.profile.profileImage,
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
                      height: screenHeight * 0.08,
                      width: screenHeight * 0.08,
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

                      Container(
                      padding: const EdgeInsets.all(Sizes.sm),
                      height: screenHeight * 0.08,
                      width: screenHeight * 0.08,
                      decoration: BoxDecoration(
                        color: CustomColors.primary,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: CustomColors.darkGrey,
                          width: 2,
                        ),
                      ),
                        child: Center(
                          child: const Icon(
                            Iconsax.message,
                            color: Colors.white,
                            size: Sizes.iconMd,
                          ),
                        ),
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