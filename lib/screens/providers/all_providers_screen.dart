import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'widgets/some_container.dart';

class AllProvidersScreen extends ConsumerWidget {
  const AllProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersState = ref.watch(providerProfilesController);
    final dark = HelperFunction.isDarkMode(context);
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
          final cityMapping =
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

          final cities = cityMapping.map((e) => e.key).toList();
          return DefaultTabController(
            length: cities.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: cities.map((city) => Tab(text: city)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children:
                        cities.map((city) {
                          final originalKey =
                              cityMapping
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
                              scrollPhysics: NeverScrollableScrollPhysics(),
                              itemCount: providers.length,
                              itemBuilder: (context, index) {
                                final provider = providers[index];
                                final p = ProvidersCategoryModel.fromJson(
                                  provider,
                                );
                                Color ratingColor = Colors.brown;

                                if (p.rating < 1.66) {
                                  ratingColor = Colors.brown; // Low rating
                                } else if (p.rating < 3.33) {
                                  ratingColor =
                                      CustomColors.silver; // Medium rating
                                } else if (p.rating >= 3.33) {
                                  ratingColor =
                                      CustomColors.gold; // High rating
                                }
                                return GestureDetector(
                                  onTap: () {
                                      HelperFunction.navigateScreen(
                                        context,
                                        ProviderScreen(profile: p),
                                      );
                                    },
                                  child: SomeContainer(
                                    profileImage: p.profileImage,
                                    fullname: "${p.firstname.capitalizeEachWord()} ${p.lastname.capitalizeEachWord()}",
                                    rating: p.rating.toString(),
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
            () => CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              strokeWidth: 4.0,
              backgroundColor: dark ? Colors.white : Colors.black,
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
