import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/widgets/custom_shapes/cards/category_card.dart';
import '../../utils/helpers/capitalize_text.dart';
import '../../controllers/providers/provider_profiles_controller.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../common/widgets/texts/error_retry.dart';
import '../../models/providers/providers_category_model.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import 'provider_screen.dart';

class AllProvidersScreen extends ConsumerWidget {
  const AllProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersState = ref.watch(providerProfilesController);

    return Scaffold(
      appBar: TAppBar(
        title: Text('City', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: providersState.when(
        data: (grouped) {
          if (grouped.isEmpty) {
            return Center(
              child: Text(
                'No providers found.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          /// Build city entries (display → originalKey)
          final cityEntries =
              grouped.keys.map((key) {
                String display = key;
                if (key.toLowerCase().contains('federal capital territory')) {
                  display = 'Abuja';
                } else {
                  display = key.replaceAll(
                    RegExp(r'\s*State$', caseSensitive: false),
                    '',
                  );
                }
                return MapEntry(display, key);
              }).toList();

          final cities = cityEntries.map((e) => e.key).toList();

          return DefaultTabController(
            length: cities.length,
            child: Column(
              children: [
                // --- TabBar ---
                Builder(
                  builder: (context) {
                    final tabController = DefaultTabController.of(context);
                    return AnimatedBuilder(
                      animation: tabController,
                      builder:
                          (context, _) => TabBar(
                            isScrollable: true,
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            indicator: const BoxDecoration(),
                            indicatorColor: Colors.transparent,
                            tabs:
                                cities.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final city = entry.value;
                                  final isSelected =
                                      tabController.index == index;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Sizes.md,
                                      vertical: Sizes.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? CustomColors.primary
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      city,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelLarge!.copyWith(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.blueGrey,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                    );
                  },
                ),

                // --- TabBarView ---
                Expanded(
                  child: TabBarView(
                    children:
                        cities.map((city) {
                          final originalKey =
                              cityEntries
                                  .firstWhere((entry) => entry.key == city)
                                  .value;

                          final providers = grouped[originalKey] ?? [];

                          return Padding(
                            padding: const EdgeInsets.all(Sizes.spaceBtwItems),
                            child: HomeListView(
                              seperatorBuilder:
                                  (context, index) =>
                                      const SizedBox(height: Sizes.sm),
                              scrollDirection: Axis.vertical,
                              itemCount: providers.length,
                              itemBuilder: (context, index) {
                                final provider = providers[index];
                                final p = ProvidersCategoryModel.fromJson(
                                  provider,
                                );

                                // rating color logic
                                Color ratingColor = Colors.brown;
                                if (p.rating < 1.66) {
                                  ratingColor = Colors.brown;
                                } else if (p.rating < 3.33) {
                                  ratingColor = CustomColors.silver;
                                } else {
                                  ratingColor = CustomColors.gold;
                                }

                                return GestureDetector(
                                  onTap: () {
                                    HelperFunction.navigateScreen(
                                      context,
                                      ProviderScreen(profile: p),
                                    );
                                  },
                                  child: CategoryCard(
                                    potfolioImage: p.portfolioImages[0],
                                    imageAvatar: p.profileImage,
                                    fullname:
                                        "${p.firstname.capitalizeEachWord()} ${p.lastname.capitalizeEachWord()}",
                                    service: p.service,
                                    hourlyRate: p.hourlyRate,
                                    description: p.bio,
                                    rating: p.rating,
                                    ratingColor: ratingColor,
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
        loading:
            () => Center(
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 4.0,
                backgroundColor: Colors.transparent,
              ),
            ),
        error:
            (err, _) => ErrorRetry(
              err: 'An error occured, failed to fetch providers',
              onPressed: () {
                ref.refresh(providerProfilesController);
              },
            ),
      ),
    );
  }
}
