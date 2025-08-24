import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../controllers/providers/provider_map_controller.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import '../providers/provider_screen.dart'; // ✅ import your ProviderScreen

class ProvidersMapPage extends ConsumerStatefulWidget {
  const ProvidersMapPage({super.key});

  @override
  ConsumerState<ProvidersMapPage> createState() => _ProvidersMapPageState();
}

class _ProvidersMapPageState extends ConsumerState<ProvidersMapPage> {
  final MapController _mapController = MapController();
  LatLng? _currentUserLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // Position pos = await Geolocator.getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.high,
    // );

    setState(() {
      _currentUserLocation = LatLng(9.0882, 7.4934);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProvidersForBounds();
    });
  }

  void _fetchProvidersForBounds() {
    final bounds = _mapController.bounds;
    if (bounds == null) {
      debugPrint("❌ Map bounds not ready yet.");
      return;
    }

    final northEast = bounds.northEast;
    final southWest = bounds.southWest;

    ref
        .read(providersMapController.notifier)
        .fetchProviders(
          northEastLat: northEast.latitude,
          northEastLng: northEast.longitude,
          southWestLat: southWest.latitude,
          southWestLng: southWest.longitude,
        );
  }

  /// ✅ Popup for provider
  void _showProviderPopup(BuildContext context, dynamic provider) {
    final dark = HelperFunction.isDarkMode(context);
    Color ratingColor = Colors.brown;

          if (provider.rating < 1.66) {
            ratingColor = Colors.brown; // Low rating
          } else if (provider.rating < 3.33) {
            ratingColor = CustomColors.silver; // Medium rating
          } else if (provider.rating >= 3.33) {
            ratingColor = CustomColors.gold; // High rating
          }
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(Sizes.spaceBtwItems),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoundedContainer(
                showBorder: true,
                borderColor: CustomColors.primary,
                radius: 100,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(provider.profileImage ?? ""),
                ),
              ),
              const SizedBox(height: Sizes.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${provider.firstname} ${provider.lastname}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(width: Sizes.sm,),
                  RoundedContainer(
                radius: 6,
                backgroundColor: ratingColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.xs + 4,
                  vertical: 2,
                ),
                child: Center(
                  child: Text(
                    provider.rating.toString(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: dark ? Colors.white : Colors.black,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                ),
              ),
                ],
              ),
              Text(
                provider.service ?? " ",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: dark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx); // close popup
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProviderScreen(profile: provider),
                    ),
                  );
                },
                child: RoundedContainer(
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 0.80,
                          padding: const EdgeInsets.all(Sizes.sm),
                          backgroundColor: CustomColors.primary,
                  child: Center(
                    child: Text(
                      "View Profile",
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall!.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: Sizes.spaceBtwItems),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final providersState = ref.watch(providersMapController);

    return Scaffold(
      appBar: AppBar(title: const Text("Map")),
      body:
          _currentUserLocation == null
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _currentUserLocation!,
                  zoom: 13,
                  onMapEvent: (event) {
                    if (event is MapEventMoveEnd) {
                      _fetchProvidersForBounds();
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  providersState.when(
                    data: (providers) {
                      return MarkerLayer(
                        markers: [
                          // ✅ Current user marker
                          Marker(
                            point: _currentUserLocation!,
                            width: 40,
                            height: 40,
                            builder:
                                (ctx) => const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                          ),
                          // ✅ Provider markers with popup
                          ...providers.map(
                            (p) => Marker(
                              point: LatLng(p.latitude, p.longitude),
                              width: 40,
                              height: 40,
                              builder:
                                  (ctx) => GestureDetector(
                                    onTap: () => _showProviderPopup(context, p),
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
                            backgroundImage: NetworkImage(p.profileImage),
                          ),
                        ),
                                  ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading:
                        () => MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentUserLocation!,
                              width: 40,
                              height: 40,
                              builder:
                                  (ctx) => const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                            ),
                          ],
                        ),
                    error: (err, _) {
                      return MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentUserLocation!,
                            width: 40,
                            height: 40,
                            builder:
                                (ctx) => const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
    );
  }
}
