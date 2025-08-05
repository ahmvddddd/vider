import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../common/widgets/appbar/appbar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return LocationMapPage();
  }
}

class MockLocation {
  final String userId;
  final String username;
  final LatLng latLng;

  MockLocation({
    required this.userId,
    required this.username,
    required this.latLng,
  });
}

class LocationMapPage extends StatefulWidget {
  const LocationMapPage({super.key});

  @override
  State<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  List<MockLocation> randomLocations = [];
  final String currentUserId = 'user_0'; // Simulated current user ID

  @override
  void initState() {
    super.initState();
    generateRandomLocations();
  }

  void generateRandomLocations() {
    final random = Random();
    const baseLat = 37.7749; // Example: San Francisco
    const baseLng = -122.4194;

    randomLocations = List.generate(10, (index) {
      final latOffset = (random.nextDouble() - 0.5) * 0.1; // ~±0.05 deg
      final lngOffset = (random.nextDouble() - 0.5) * 0.1;

      return MockLocation(
        userId: 'user_$index',
        username: 'User $index',
        latLng: LatLng(baseLat + latOffset, baseLng + lngOffset),
      );
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final center =
        randomLocations.isNotEmpty
            ? randomLocations.first.latLng
            : const LatLng(0.0, 0.0);

    return Scaffold(
      appBar: TAppBar(
        title: Text('Map', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: FlutterMap(
          options: MapOptions(center: center, zoom: 13.0),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers:
                  randomLocations.map((loc) {
                    final isCurrentUser = loc.userId == currentUserId;
                    return Marker(
                      point: loc.latLng,
                      builder:
                          (ctx) => IconButton(
                            onPressed: () {
                              // You can handle click events here
                            },
                            icon: Icon(
                              Icons.location_pin,
                              color:
                                  isCurrentUser ? Colors.red[900] : Colors.blue,
                              size: 30,
                            ),
                          ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
