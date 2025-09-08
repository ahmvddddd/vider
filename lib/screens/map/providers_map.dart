import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../controllers/providers/provider_map_controller.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import '../providers/provider_screen.dart';

class ProvidersMapPage extends ConsumerStatefulWidget {
  const ProvidersMapPage({super.key});

  @override
  ConsumerState<ProvidersMapPage> createState() => _ProvidersMapPageState();
}

class _ProvidersMapPageState extends ConsumerState<ProvidersMapPage> {
  final MapController _mapController = MapController();
  LatLng? _currentUserLocation;
  final TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];

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

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentUserLocation = LatLng(pos.latitude, pos.longitude); // demo location
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProvidersForBounds();
    });
  }

  void _fetchProvidersForBounds() {
    final bounds = _mapController.bounds;
    if (bounds == null) return;

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
      ratingColor = Colors.brown;
    } else if (provider.rating < 3.33) {
      ratingColor = CustomColors.silver;
    } else {
      ratingColor = CustomColors.gold;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
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
                  const SizedBox(width: Sizes.sm),
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
                  Navigator.pop(ctx);
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

  Future<void> searchLocation({
    required String query,
    required MapController mapController,
  }) async {
    if (query.isEmpty) {
      return;
    }

    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1",
      );

      final response = await http.get(
        url,
        headers: {
          "User-Agent":
              "ViderApp/1.0 (your_email@example.com)", // required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final List results = jsonDecode(response.body);
        if (results.isNotEmpty) {
          final lat = double.parse(results[0]['lat']);
          final lon = double.parse(results[0]['lon']);

          // 2. Move the map to the searched location
          mapController.move(LatLng(lat, lon), 14);

          // 3. Define bounding box around the location (±0.05 for example)
          final northEastLat = lat + 0.05;
          final northEastLng = lon + 0.05;
          final southWestLat = lat - 0.05;
          final southWestLng = lon - 0.05;

          // 4. Fetch providers in that bounding box
          await ref
              .read(providersMapController.notifier)
              .fetchProviders(
                northEastLat: northEastLat,
                northEastLng: northEastLng,
                southWestLat: southWestLat,
                southWestLng: southWestLng,
              );
        } else {
          return;
        }
      } else {
        return;
      }
    } catch (e) {
      throw Exception("Failed to fetch location");
    }
  }

  bool _isSearching = false;

  Future<void> _onSearch() async {
    if (_isSearching) return; // ✅ ignore if already searching

    final query = searchController.text.trim();

    if (query.isEmpty) {
      return;
    }

    _isSearching = true;
    await searchLocation(query: query, mapController: _mapController);
    _isSearching = false;
  }

  @override
  Widget build(BuildContext context) {
    final providersState = ref.watch(providersMapController);

    return Scaffold(
      appBar: TAppBar(
        title: Text("Map", style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body:
          _currentUserLocation == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  SizedBox(
                    child: SearchContainer(
                      text: 'Search locations for providers',
                      controller: searchController,
                      width: MediaQuery.of(context).size.width * 0.90,
                      onTap: () => FocusScope.of(context).unfocus(),
                      onEditingComplete: () {
                        _onSearch();
                        FocusScope.of(context).unfocus();
                        searchController.clear();
                      },
                      onSubmitted: (value) {
                        _onSearch();
                        FocusScope.of(context).unfocus();
                        searchController.clear();
                      },
                    ),
                  ),
                  const SizedBox(height: Sizes.sm),
                  Expanded(
                    // ✅ Expanded fixes overflow
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: FlutterMap(
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
                                  ...providers
                                      .where(
                                        (p) =>
                                            p.latitude.isFinite &&
                                            p.longitude.isFinite,
                                      )
                                      .map(
                                        (p) => Marker(
                                          point: LatLng(
                                            p.latitude,
                                            p.longitude,
                                          ),
                                          width: 40,
                                          height: 40,
                                          builder: (ctx) {
                                            IconData providerIcon =
                                                Icons.location_on;

                                            switch (p.category.toLowerCase()) {
                                              case 'beauty':
                                                providerIcon = Icons.spa;
                                                break;
                                              case 'construction':
                                                providerIcon = Icons.handyman;
                                                break;
                                              case 'food':
                                                providerIcon = Icons.restaurant;
                                                break;
                                              case 'maintenance':
                                                providerIcon = Icons.build;
                                                break;
                                              case 'health & fitness':
                                                providerIcon = Icons.fitness_center;
                                              
                                            }
                                            return GestureDetector(
                                              onTap:
                                                  () => _showProviderPopup(
                                                    context,
                                                    p,
                                                  ),
                                              child: Icon(
                                                providerIcon,
                                                size: 40,
                                                color: CustomColors.primary,
                                              ),
                                            );
                                          },
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
                            error:
                                (err, _) => MarkerLayer(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
