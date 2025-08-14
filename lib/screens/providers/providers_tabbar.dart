import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/custom_shapes/cards/category_card.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../controllers/user/provider_profiles_controller.dart';

class ProvidersTabbar extends ConsumerWidget {
  final double lat;
  final double long;
  final List<String> service;

  const ProvidersTabbar({
    super.key,
    required this.lat,
    required this.long,
    required this.service,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenHeight = MediaQuery.of(context).size.height;
    final profilesState = ref.watch(providerProfilesController);

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'All Categories',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: profilesState.when(
        data: (groupedProfiles) {
          // Find the state name for the given lat/long from cache in controller
          final notifier = ref.read(providerProfilesController.notifier);
          return FutureBuilder<String>(
            future: notifier.getStateFromCoordinates(lat, long),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final stateName = snapshot.data!;
              final providersInState = groupedProfiles[stateName] ?? [];

              return Padding(
                padding: const EdgeInsets.all(Sizes.spaceBtwItems),
                child: DefaultTabController(
                  length: service.length,
                  child: Builder(
                    builder: (context) {
                      final tabController =
                          DefaultTabController.of(context);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 50,
                            child: AnimatedBuilder(
                              animation: tabController,
                              builder: (context, _) {
                                return TabBar(
                                  isScrollable: true,
                                  labelPadding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  indicator: const BoxDecoration(),
                                  indicatorColor: Colors.transparent,
                                  tabs: List.generate(service.length, (index) {
                                    final isSelected =
                                        tabController.index == index;
                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Sizes.md,
                                        vertical: Sizes.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? CustomColors.primary
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        service[index],
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.blueGrey,
                                            ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: screenHeight,
                            child: TabBarView(
                              children: service.map((category) {
                                // Filter providers by service
                                final filteredProviders =
                                    providersInState.where((p) {
                                  final providerService =
                                      (p['service'] ?? '').toString();
                                  return providerService
                                      .toLowerCase()
                                      .contains(category.toLowerCase());
                                }).toList();

                                if (filteredProviders.isEmpty) {
                                  return const Center(
                                      child: Text('No providers found.'));
                                }

                                return ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Sizes.sm,
                                    horizontal: Sizes.md,
                                  ),
                                  itemCount: filteredProviders.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: Sizes.md),
                                  itemBuilder: (context, index) {
                                    final provider =
                                        filteredProviders[index];
                                    return CategoryCard(
                                      imageAvatar: provider['image'] ??
                                          Images.carpenter,
                                      fullname:
                                          provider['fullname'] ?? 'Unknown',
                                      ratingColor: Colors.brown,
                                      rating: provider['rating'] ?? 0,
                                      service: provider['service'] ??
                                          category,
                                      description:
                                          provider['description'] ??
                                              'No description provided.',
                                      hourlyRate:
                                          provider['hourlyRate'] ?? 0,
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
      ),
    );
  }
}
