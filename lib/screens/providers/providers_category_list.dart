import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/custom_shapes/cards/category_card.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../controllers/user/provider_profiles_controller.dart';
import '../../utils/constants/sizes.dart';

class ProvidersCategoryList extends ConsumerWidget {
  final double lat;
  final double lon;
  final String category;

  const ProvidersCategoryList({
    super.key,
    required this.lat,
    required this.lon,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesState = ref.watch(providerProfilesController);

    return Scaffold(
      appBar: TAppBar(
        title: Text(category, style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: profilesState.when(
        data: (groupedProfiles) {
          final notifier = ref.read(providerProfilesController.notifier);

          return FutureBuilder<String>(
            future: notifier.getStateFromCoordinates(lat, lon),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final stateName = snapshot.data!;
              final providers =
                  (groupedProfiles[stateName] ?? [])
                      .where(
                        (p) =>
                            (p['category'] ?? '').toLowerCase() ==
                            category.toLowerCase(),
                      )
                      .toList();

              if (providers.isEmpty) {
                return Center(
                  child: Text('No $category providers found in $stateName'),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(Sizes.spaceBtwItems),
                child: HomeListView(
                  scrollDirection: Axis.vertical,
                  seperatorBuilder:
                      (context, index) => const SizedBox(height: Sizes.sm),
                  itemCount: providers.length,
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    return CategoryCard(
                      potfolioImage: provider['portfolioImages'][0],
                      imageAvatar: provider['profileImage'],
                      fullname: '${provider['firstname']} ${provider['lastname']}',
                      service: provider['service'],
                      hourlyRate: provider['hourlyRate'],
                      description: provider['bio'],
                      rating: 4.5,
                      ratingColor: Colors.amber,
                    );
                    // ListTile(
                    //   leading: CircleAvatar(
                    //     backgroundImage: provider['profileImage'] != null
                    //         ? NetworkImage(provider['profileImage'])
                    //         : null,
                    //     child: provider['profileImage'] == null
                    //         ? const Icon(Icons.person)
                    //         : null,
                    //   ),
                    //   title: Text(provider['firstname'] ?? 'Unknown'),
                    //   subtitle: Text(provider['profession'] ?? ''),
                    // );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
