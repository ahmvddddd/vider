import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:vider/screens/providers/provider_screen.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../controllers/providers/provider_profiles_controller.dart';
import '../../models/providers/providers_category_model.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/helpers/helper_function.dart';
import '../providers/all_provider_categories.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _ProvidersMapScreenState();
}

class _ProvidersMapScreenState extends ConsumerState<MapScreen> {
  LatLng? currentUserLocation;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  /// Request location permission & get current position
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Check for permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Get current position
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentUserLocation = LatLng(9.0882, 7.4934);
      // ignore: avoid_print
      print("Latitude: ${pos.latitude}, Longitude: ${pos.longitude}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final providersState = ref.watch(providerProfilesController);

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          "Providers Map",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          TextButton(
            onPressed: () {
              HelperFunction.navigateScreen(context, AllProviderCategories());
            },
            child: Text(
              'Categories',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: CustomColors.primary),
            ),
          ),
        ],
        showBackArrow: true,
      ),
      body: providersState.when(
        data: (groupedProviders) {
          if (currentUserLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Convert providers into markers
          final markers = <Marker>[
            // Current user marker
            Marker(
              point: LatLng(
                currentUserLocation!.latitude,
                currentUserLocation!.longitude,
              ),
              width: 40,
              height: 40,
              builder:
                  (ctx) => const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
            ),
          ];

          // Add providers markers
          for (final entry in groupedProviders.entries) {
            for (final provider in entry.value) {
              final lat = (provider['latitude'] as num).toDouble();
              final lon = (provider['longitude'] as num).toDouble();
              final profileImage = provider['profileImage'] as String?;

              markers.add(
                Marker(
                  point: LatLng(lat, lon),
                  width: 40,
                  height: 40,
                  builder: (ctx) {
                    if (profileImage != null && profileImage.isNotEmpty) {
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
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: CustomColors.alternate,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(profileImage),
                          ),
                        ),
                      );
                    } else {
                      return const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      );
                    }
                  },
                ),
              );
            }
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: FlutterMap(
              options: MapOptions(
                center: currentUserLocation, // 👈 Center on user
                zoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
