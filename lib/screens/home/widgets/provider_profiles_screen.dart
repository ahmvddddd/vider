// // screens/provider_profiles_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../controllers/user/provider_profiles_controller.dart';

// class ProviderProfilesScreen extends ConsumerWidget {
//   const ProviderProfilesScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final providersState = ref.watch(providerProfilesController);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Providers by City')),
//       body: providersState.when(
//         data: (grouped) {
//           if (grouped.isEmpty) {
//             return const Center(child: Text('No providers found.'));
//           }
//           final cities = grouped.keys.toList();
//           return DefaultTabController(
//             length: cities.length,
//             child: Column(
//               children: [
//                 TabBar(
//                   isScrollable: true,
//                   tabs: cities.map((city) => Tab(text: city)).toList(),
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     children: cities.map((city) {
//                       final providers = grouped[city]!;
//                       return ListView.builder(
//                         itemCount: providers.length,
//                         itemBuilder: (context, index) {
//                           final provider = providers[index];
//                           return ListTile(
//                             leading: CircleAvatar(
//                               backgroundImage: NetworkImage(provider['profileImage'] ?? ''),
//                             ),
//                             title: Text('${provider['firstname']} ${provider['lastname']}'),
//                             subtitle: Text(provider['service'] ?? ''),
//                           );
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text('Error: $e')),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../common/widgets/custom_shapes/cards/provider_card.dart';
import '../../../common/widgets/layouts/listview.dart';
import '../../../controllers/user/provider_profiles_controller.dart';
import '../../../models/providers/providers_category_model.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../providers/provider_screen.dart';

class ProviderProfilesWidget extends ConsumerStatefulWidget {
  const ProviderProfilesWidget({super.key});

  @override
  ConsumerState<ProviderProfilesWidget> createState() =>
      _ProviderProfilesWidgetState();
}

class _ProviderProfilesWidgetState
    extends ConsumerState<ProviderProfilesWidget> {
  double? lat;
  double? lon;
  bool _loadingLocation = true;
  String? _locationError;
  String? _stateName; // <-- store fetched state here

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = "Location permission denied";
            _loadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = "Location permissions are permanently denied";
          _loadingLocation = false;
        });
        return;
      }

      // Get location
      // final position = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );

      setState(() {
        lat = 9.0882; // using fixed coords as before
        lon = 7.4934;
      });

      // fetch state once
      final notifier = ref.read(providerProfilesController.notifier);
      final stateName = await notifier.getStateFromCoordinates(lat!, lon!);

      setState(() {
        _stateName = stateName;
        _loadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = "Failed to get location: $e";
        _loadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilesState = ref.watch(providerProfilesController);
    double screenHeight = MediaQuery.of(context).size.height;

    if (_loadingLocation) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_locationError != null) {
      return Center(child: Text(_locationError!));
    }

    if (_stateName == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return profilesState.when(
      data: (groupedProfiles) {
        final providers = groupedProfiles[_stateName] ?? [];

        if (providers.isEmpty) {
          return const SizedBox.shrink();
        }

        return HomeListView(
          sizedBoxHeight: screenHeight * 0.32,
          seperatorBuilder: (context, index) =>
              const SizedBox(height: Sizes.sm),
          scrollDirection: Axis.horizontal,
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final provider = providers[index];
        
            Color ratingColor = Colors.brown;
            if (provider['rating'] < 1.66) {
              ratingColor = Colors.brown;
            } else if (provider['rating'] < 3.33) {
              ratingColor = CustomColors.silver;
            } else {
              ratingColor = CustomColors.gold;
            }
        
            return GestureDetector(
              onTap: () {
                final model = ProvidersCategoryModel.fromJson(
                            provider,
                          );
                HelperFunction.navigateScreen(
                  context,
                  ProviderScreen(profile: model),
                );
              },
              child: ProviderCard(
                fullname: '${provider['firstname']} ${provider['lastname']}',
                service: provider['service'] ?? '',
                portfolioImage: provider['portfolioImages'][1] ?? '',
                imageAvatar: provider['profileImage'] ?? '',
                description: provider['bio'],
                rating: provider['rating'],
                ratingColor: ratingColor,
                hourlyRate: 100,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}