import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vider/utils/helpers/capitalize_text.dart';
import '../../../common/widgets/custom_shapes/cards/provider_card.dart';
import '../../../common/widgets/layouts/listview.dart';
import '../../../common/widgets/texts/section_heading.dart';
import '../../../controllers/providers/provider_profiles_controller.dart';
import '../../../models/providers/providers_category_model.dart';
import '../../../repository/user/get_matching_location_storage.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/helpers/responsive_size.dart';
import '../../providers/all_providers_screen.dart';
import '../../providers/provider_screen.dart';
import '../components/provider_profiles_shimmer.dart';

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
  String? _stateName;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
  try {
    // 🔹 Step 1: Check SharedPreferences cache
    final cached = await MatchingLocationStorage.loadLocation();
    if (cached != null) {
      setState(() {
        lat = cached['lat'];
        lon = cached['lon'];
        _stateName = cached['state'];
        _loadingLocation = false;
      });
      return;
    }

    // 🔹 Step 2: Request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _locationError = "Location permission denied";
          _loadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() {
        _locationError = "Location permissions are permanently denied";
        _loadingLocation = false;
      });
      return;
    }

    // 🔹 Step 3: Get location from GPS
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final notifier = ref.read(providerProfilesController.notifier);
    final stateName = await notifier.getStateFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    // 🔹 Step 4: Save to SharedPreferences
    await MatchingLocationStorage.saveLocation(pos.latitude, pos.longitude, stateName);

    if (!mounted) return;
    setState(() {
      lat = pos.latitude;
      lon = pos.longitude;
      _stateName = stateName;
      _loadingLocation = false;
    });
  } catch (e) {
    setState(() {
      _locationError = "Failed to get location";
      _loadingLocation = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final profilesState = ref.watch(providerProfilesController);
    double screenHeight = MediaQuery.of(context).size.height;

    if (_loadingLocation) {
      return ProviderProfilesShimmer();
    }

    if (_locationError != null) {
      return Center(
        child: Text(
          'No providers in your location',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    if (_stateName == null) {
      return ProviderProfilesShimmer();
    }

    return profilesState.when(
      data: (groupedProfiles) {
        final providers = groupedProfiles[_stateName] ?? [];

        if (providers.isEmpty) {
          return Center(
            child: Text(
              'No providers in your location yet',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(
                            title: 'Providers near you',
                            onPressed: () => HelperFunction.navigateScreen(
                              context,
                              AllProvidersScreen(),
                            ),
                          ),
                          SizedBox(height: responsiveSize(context, Sizes.sm)),
            HomeListView(
              sizedBoxHeight: screenHeight * 0.28,
              seperatorBuilder:
                  (context, index) => SizedBox(width: responsiveSize(context, Sizes.sm)),
              scrollDirection: Axis.horizontal,
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final provider = providers[index];
                final p = ProvidersCategoryModel.fromJson(provider);
            
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
                  child: ProviderCard(
                    fullname:
                        '${p.firstname.capitalizeEachWord()} ${p.lastname.capitalizeEachWord()}',
                    service: p.service,
                    portfolioImage: p.portfolioImages[1],
                    imageAvatar: p.profileImage,
                    rating: p.rating,
                    ratingColor: ratingColor,
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const ProviderProfilesShimmer(),
      error:
          (err, _) => SizedBox.shrink()
    );
  }
}
