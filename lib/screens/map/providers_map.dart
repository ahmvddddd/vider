import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../controllers/providers/provider_map_controller.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import 'widgets/map_helper.dart';

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

    if (!mounted) return;
    setState(() {
      _currentUserLocation = LatLng(pos.latitude, pos.longitude);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      MapHelper.fetchProvidersForBounds(_mapController, ref);
    });
  }

  bool _isSearching = false;
  Future<void> _onSearch() async {
    if (_isSearching) return;
    final query = searchController.text.trim();
    if (query.isEmpty) {
      return;
    }
    _isSearching = true;
    await MapHelper.searchLocation(
      query: query,
      mapController: _mapController,
      ref: ref,
    );
    _isSearching = false;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providersState = ref.watch(providersMapController);
    final dark = HelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          "Map Screen",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body:
          _currentUserLocation == null
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 4.0,
                  backgroundColor: dark ? Colors.white : Colors.black,
                ),
              )
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: _currentUserLocation!,
                          zoom: 13,
                          onMapEvent: (event) {
                            if (event is MapEventMoveEnd) {
                              MapHelper.fetchProvidersForBounds(
                                _mapController,
                                ref,
                              );
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
                                                providerIcon = Icons.settings;
                                                break;
                                              case 'fitness':
                                                providerIcon =
                                                    Icons.fitness_center;
                                            }
                                            return GestureDetector(
                                              onTap:
                                                  () =>
                                                      MapHelper.showProviderPopup(
                                                        context,
                                                        p,
                                                      ),
                                              child: Center(
                                                child: Icon(
                                                  providerIcon,
                                                  size: 35,
                                                  color: CustomColors.primary,
                                                ),
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
