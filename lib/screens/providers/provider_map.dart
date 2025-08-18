import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ProviderMapScreen extends StatefulWidget {
  final double profileLatitude;
  final double profileLongitude;

  const ProviderMapScreen({
    super.key,
    required this.profileLatitude,
    required this.profileLongitude,
  });

  @override
  State<ProviderMapScreen> createState() => _ProviderMapScreenState();
}

class _ProviderMapScreenState extends State<ProviderMapScreen> {
  LatLng? currentUserLocation;
  late final MapController _mapController;
  List<LatLng> routePoints = [];

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

    // After location is found → fetch route
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    if (currentUserLocation == null) return;

    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=YOUR_API_KEY'
      '&start=${currentUserLocation!.longitude},${currentUserLocation!.latitude}'
      '&end=${widget.profileLongitude},${widget.profileLatitude}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'] as List;
      setState(() {
        routePoints = coords
            .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
            .toList();
      });
    } else {
      print("Failed to fetch route: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileLocation = LatLng(
      widget.profileLatitude,
      widget.profileLongitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Map', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: currentUserLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                zoom: 12.0,
                onMapReady: () {
                  final bounds = LatLngBounds.fromPoints([
                    currentUserLocation!,
                    profileLocation,
                  ]);
                  _mapController.fitBounds(
                    bounds,
                    options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
                  );
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentUserLocation!,
                      builder: (ctx) => const Icon(
                        Icons.person_pin_circle,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    Marker(
                      point: profileLocation,
                      builder: (ctx) => const Icon(
                        Icons.location_pin,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                // ✅ Draw the route
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4.0,
                        color: Colors.green,
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}
