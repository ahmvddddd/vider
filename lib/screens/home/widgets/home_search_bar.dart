import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vider/utils/helpers/capitalize_text.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../common/widgets/layouts/listview.dart';
import '../../../common/widgets/shimmer/shimmer_widget.dart';
import '../../../common/widgets/texts/error_retry.dart';
import '../../../controllers/providers/search_providers_controller.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../map/providers_map.dart';
import '../../providers/provider_screen.dart';

class HomeSearchBar extends ConsumerStatefulWidget {
  const HomeSearchBar({super.key});

  @override
  ConsumerState<HomeSearchBar> createState() => _HomeSearchbarState();
}

class _HomeSearchbarState extends ConsumerState<HomeSearchBar> {
  Timer? _debounce;
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final dark = HelperFunction.isDarkMode(context);
    final profilesAsync = ref.watch(searchProfilesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What Service do you need ?',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: dark ? CustomColors.alternate : CustomColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Sizes.spaceBtwItems),

        SearchContainer(
          text: 'search name or service',
          width: screenWidth * 0.90,
          onChanged: _onSearchChanged,
          onTap: () => FocusScope.of(context).unfocus(),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color:
                    dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onTap:
                    () => HelperFunction.navigateScreen(
                      context,
                      ProvidersMapPage(),
                    ),
                child: Icon(
                  Icons.location_pin,
                  size: Sizes.iconM,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: Sizes.sm),

        // 🔹 Show live search results
        profilesAsync.when(
          data: (profiles) {
            if (profiles.isEmpty) {
              return const SizedBox.shrink();
            }
            return HomeListView(
              seperatorBuilder:
                  (context, index) => const SizedBox(height: Sizes.sm),
              scrollDirection: Axis.vertical,
              scrollPhysics: NeverScrollableScrollPhysics(),
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final p = profiles[index];

                Color ratingColor = Colors.brown;

                if (p.rating < 1.66) {
                  ratingColor = Colors.brown; // Low rating
                } else if (p.rating < 3.33) {
                  ratingColor = CustomColors.silver; // Medium rating
                } else if (p.rating >= 3.33) {
                  ratingColor = CustomColors.gold; // High rating
                }
                return RoundedContainer(
                  backgroundColor: dark ? Colors.black : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: CustomColors.darkGrey,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  radius: Sizes.cardRadiusLg,
                  padding: const EdgeInsets.all(0),
                  child: ListTile(
                    onTap: () {
                      HelperFunction.navigateScreen(
                        context,
                        ProviderScreen(profile: p),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(p.profileImage),
                    ),
                    title: Row(
                      children: [
                        Text(
                          "${p.firstname.capitalizeEachWord()} ${p.lastname.capitalizeEachWord()}",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),

                        const SizedBox(width: Sizes.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: ratingColor,
                              size: Sizes.iconMd,
                            ),
                            Text(
                              p.rating.toString(),
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
                    subtitle: Text(
                      p.category,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                );
              },
            );
          },
          loading:
              () => Center(
                child: ShimmerWidget(
                  height: screenHeight * 0.08,
                  width: screenWidth * 0.90,
                  radius: Sizes.cardRadiusLg,
                ),
              ),
          error:
              (err, stack) => ErrorRetry(
                err: 'An error occured, failed to fetch providers',
                onPressed: () {
                  ref.refresh(searchProfilesProvider);
                },
              ),
        ),
      ],
    );
  }
}
