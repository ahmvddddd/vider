import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../utils/constants/custom_colors.dart';

class ProviderMapScreen extends StatefulWidget {
  final double profileLatitude;
  final double profileLongitude;
  final String profileImage;

  const ProviderMapScreen({
    super.key,
    required this.profileLatitude,
    required this.profileLongitude,
    required this.profileImage
  });

  @override
  State<ProviderMapScreen> createState() => _ProviderMapScreenState();
}

class _ProviderMapScreenState extends State<ProviderMapScreen> {
  LatLng? currentUserLocation;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentUserLocation();
  }

  Future<void> _getCurrentUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentUserLocation = LatLng(position.latitude, position.longitude);
    });

    // 👇 once both locations exist, fit the map to show both
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToBounds();
    });
  }

  void _fitMapToBounds() {
    if (currentUserLocation == null) return;
    final profileLocation = LatLng(
      widget.profileLatitude,
      widget.profileLongitude,
    );

    final bounds = LatLngBounds.fromPoints([
      currentUserLocation!,
      profileLocation,
    ]);

    _mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileLocation = LatLng(
      widget.profileLatitude,
      widget.profileLongitude,
    );

    return Scaffold(
      appBar: TAppBar(
        title: Text('Map', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body:
          currentUserLocation == null
              ? const Center(child: CircularProgressIndicator())
              : ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: currentUserLocation, // 👈 temp center
                    zoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.myapp',
                    ),
                    MarkerLayer(
                      markers: [
                        // current user marker
                        
                        // profile marker
                        Marker(
                          point: profileLocation,
                          width: 40,
                          height: 40,
                          builder:
                              (ctx) => Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: CustomColors.alternate,
                                    width: 3
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(widget.profileImage,),
                                ),
                              ),
                        ),

                        Marker(
                          point: currentUserLocation!,
                          width: 40,
                          height: 40,
                          builder:
                              (ctx) => const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 30,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
