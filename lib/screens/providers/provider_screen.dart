import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/helpers/capitalize_text.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/custom_shapes/containers/button_container.dart';
import '../../common/widgets/image/full_screen_image_view.dart';
import '../../controllers/jobs/pending_jobs_controller.dart';
import '../../controllers/services/user_id_controller.dart';
import '../../controllers/user/user_controller.dart';
import '../../models/providers/providers_category_model.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../common/widgets/texts/section_heading.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import '../messages/message.dart';
import 'hire_provider_screen.dart';
import 'provider_map.dart';
import 'widgets/provider_buttons.dart';
import 'widgets/provider_profile_image.dart';
import 'widgets/provider_services.dart';

class ProviderScreen extends ConsumerStatefulWidget {
  final ProvidersCategoryModel profile;
  const ProviderScreen({super.key, required this.profile});

  @override
  ConsumerState<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends ConsumerState<ProviderScreen> {
  String? currentUserId;
  final UserIdService userIdService = UserIdService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userProvider.notifier).fetchUserDetails();
    });
    getCurrentUserId();
  }

  Future<void> getCurrentUserId() async {
    final userId = await userIdService.getCurrentUserId();
    if (!mounted) return;
    setState(() {
      currentUserId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    final participants = [currentUserId, widget.profile.userId];

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
      appBar: TAppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      bottomNavigationBar: Consumer(
  builder: (context, ref, _) {
    final pendingJobAsync =
        ref.watch(pendingJobsProvider(widget.profile.userId));
    final userProfile = ref.watch(userProvider);

    return pendingJobAsync.when(
      data: (pendingResult) {
        final isBusy = pendingResult.hasPendingJob;

        return userProfile.when(
          data: (user) {
            final isVerified = user.isIdVerified == true;

            return ButtonContainer(
              onPressed: (isBusy || !isVerified || !widget.profile.isIdVerified)
                  ? null
                  : () {
                      HelperFunction.navigateScreen(
                        context,
                        HireProvider(profile: widget.profile),
                      );
                    },
              text: 'Hire',
              backgroundColor:
                  (isBusy || !isVerified) ? Colors.grey : CustomColors.primary,
            );
          },
          loading: () => ButtonContainer(
            onPressed: null,
            text: 'Hire',
            backgroundColor: Colors.grey,
          ),
          error: (error, stack) => ButtonContainer(
            onPressed: null,
            text: 'Hire',
            backgroundColor: Colors.grey,
          ),
        );
      },
      loading: () => ButtonContainer(
        onPressed: null,
        text: 'Hire',
        backgroundColor: Colors.grey,
      ),
      error: (error, stack) => ButtonContainer(
        onPressed: null,
        text: 'Hire',
        backgroundColor: Colors.grey,
      ),
    );
  },
),


      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => FullScreenImageView(
                          images: [
                            widget.profile.profileImage,
                          ], // Pass all images
                          initialIndex: 0, // Start from tapped image
                        ),
                  ),
                );
              },
              child: ProfileImage(
                imageAvatar: widget.profile.profileImage,
                fullname:
                    '${widget.profile.firstname.capitalizeEachWord()} ${widget.profile.lastname.capitalizeEachWord()}',
                ratingColor: ratingColor,
                rating: widget.profile.rating,
                service: widget.profile.service,
                hourlyRate: widget.profile.hourlyRate,
              ),
            ),

            const SizedBox(height: Sizes.sm),
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
                  ProviderButtons(
                    hasValidLocation: hasValidLocation,
                    employeruserName: widget.profile.username,
                    messageWidget: MessageScreen(
                      participants: participants,
                      receiverImage: widget.profile.profileImage,
                      receiverName: '${widget.profile.firstname.capitalizeEachWord()} ${widget.profile.lastname.capitalizeEachWord()}',
                    ),
                    providerMapWidget: ProviderMapScreen(
                      profileLatitude: widget.profile.latitude,
                      profileLongitude: widget.profile.longitude,
                      profileImage: widget.profile.profileImage,
                    ),
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
                      final images = widget.profile.portfolioImages;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => FullScreenImageView(
                                    images: images, // Pass all images
                                    initialIndex:
                                        index, // Start from tapped image
                                  ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Sizes.borderRadiusLg,
                          ),
                          child: Image.network(
                            widget.profile.portfolioImages[index],
                            width: MediaQuery.of(context).size.height * 0.40,
                            height: MediaQuery.of(context).size.height * 0.30,
                            fit: BoxFit.cover,
                          ),
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
