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

final searchFocusProvider = StateProvider<bool>((ref) => false);


class _HomeSearchbarState extends ConsumerState<HomeSearchBar> {
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

   @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      ref.read(searchFocusProvider.notifier).state = _focusNode.hasFocus;
    });
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
          onTap: () => FocusScope.of(context).requestFocus(_focusNode),
          focusNode: _focusNode,
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
                return GestureDetector(
                                      onTap: () {
                      HelperFunction.navigateScreen(
                        context,
                        ProviderScreen(profile: p),
                      );
                    },
                  child: someContainer(context, "${p.firstname.capitalizeEachWord()} ${p.lastname.capitalizeEachWord()}",
                   ratingColor, p.profileImage, "${p.rating}"),
                );
              },
            );
          },
          loading:
              () => Center(
                child: ShimmerWidget(
                  height: screenHeight * 0.07,
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
  Widget someContainer(BuildContext context,
  String fullname,
  Color ratingColor,
  String profileImage,
  String rating
  ) {
    final dark = HelperFunction.isDarkMode(context);
    return RoundedContainer(
      width: MediaQuery.of(context).size.width * 0.90,
      height: MediaQuery.of(context).size.height * 0.07,
      padding: const EdgeInsets.all(Sizes.xs),
      radius: Sizes.cardRadiusLg,
      backgroundColor: dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
      child: Column(
          children: [
            Row(
              children: [
                 CircleAvatar(
                            backgroundImage: NetworkImage(profileImage),
                          ),
                          const SizedBox(width: Sizes.sm,),
                          Row(
                      children: [
                        Text(
                          fullname,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),

                        const SizedBox(width: Sizes.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: ratingColor,
                                  size: Sizes.iconMd,
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
    ]));
  }
}

