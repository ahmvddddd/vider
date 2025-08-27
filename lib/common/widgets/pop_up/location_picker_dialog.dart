import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationPickerDialog extends StatefulWidget {
  const LocationPickerDialog({super.key});

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final MapController _mapController = MapController();
  LatLng? _pickedLocation;
  List<dynamic> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _pickedLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_pickedLocation!, 15);
    });
  }

  Future<void> _searchLocation(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _searchResults = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pick Location"),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search location...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchLocation(_searchController.text),
                ),
              ),
            ),
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: LatLng(0, 0),
                  zoom: 2,
                  onTap: (tapPos, latlng) {
                    setState(() => _pickedLocation = latlng);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  if (_pickedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _pickedLocation!,
                          width: 40,
                          height: 40,
                          builder: (ctx) => const Icon(Icons.location_pin,
                              size: 40, color: Colors.red),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (_searchResults.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final place = _searchResults[index];
                    return ListTile(
                      title: Text(place['display_name']),
                      onTap: () {
                        final lat =
                            double.parse(place['lat'] as String);
                        final lon =
                            double.parse(place['lon'] as String);
                        setState(() {
                          _pickedLocation = LatLng(lat, lon);
                          _mapController.move(_pickedLocation!, 15);
                          _searchResults = [];
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _getCurrentLocation,
          child: const Text("Use My Location"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _pickedLocation),
          child: const Text("Select"),
        ),
      ],
    );
  }
}
