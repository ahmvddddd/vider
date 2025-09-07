import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../common/widgets/custom_shapes/cards/provider_card.dart';
import '../../../common/widgets/layouts/listview.dart';
import '../../../common/widgets/texts/error_retry.dart';
import '../../../controllers/user/provider_profiles_controller.dart';
import '../../../models/providers/providers_category_model.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
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
      return ProviderProfilesShimmer();
    }

    if (_locationError != null) {
      return Center(child: Text(_locationError!));
    }

    if (_stateName == null) {
      return ProviderProfilesShimmer();
    }

    return profilesState.when(
      data: (groupedProfiles) {
        final providers = groupedProfiles[_stateName] ?? [];

        if (providers.isEmpty) {
          return const SizedBox.shrink();
        }

        return HomeListView(
          sizedBoxHeight: screenHeight * 0.28,
          seperatorBuilder: (context, index) =>
              const SizedBox(height: Sizes.sm),
          scrollDirection: Axis.horizontal,
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final provider = providers[index];
            final p = ProvidersCategoryModel.fromJson(
              provider,
            );
        
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
                fullname: '${p.firstname} ${p.lastname}',
                service: p.service,
                portfolioImage: p.portfolioImages[1],
                imageAvatar: p.profileImage,
                rating: p.rating,
                ratingColor: ratingColor,
              ),
            );
          },
        );
      },
      loading: () => const ProviderProfilesShimmer(),
      error: (err, _) => ErrorRetry(
                err: err,
                onPressed: () {
                  ref.refresh(providerProfilesController);
                },
              ),
    );
  }
}