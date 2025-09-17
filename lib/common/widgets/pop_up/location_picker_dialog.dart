import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import 'custom_snackbar.dart';

class LocationPickerDialog extends StatefulWidget {
  const LocationPickerDialog({super.key});

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final MapController _mapController = MapController();
  LatLng? _pickedLocation;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _pickedLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_pickedLocation!, 15);
    });
  }


Future<void> searchLocation(String query) async {
  final encodedQuery = Uri.encodeComponent(query);
  final url =
      "https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&addressdetails=1&limit=5";

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {"User-Agent": "vider/1.0 (vider_support@gmail.com)"},
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is List && decoded.isNotEmpty) {
        // find first result with valid lat/lon
        final place = decoded.firstWhere(
          (p) => p['lat'] != null && p['lon'] != null,
          orElse: () => null,
        );

        if (place != null) {
          final lat = double.tryParse(place['lat'].toString());
          final lon = double.tryParse(place['lon'].toString());

          if (lat != null && lon != null) {
            final target = LatLng(lat, lon);

            setState(() {
              _pickedLocation = target;
            });

            _mapController.moveAndRotate(target, 15, 0);
            return;
          }
        }
      }

      // fallback if no valid results
      CustomSnackbar.show(
        context: context,
        icon: Icons.error_outline,
        title: 'No Results',
        message: 'Could not find a valid location.',
        backgroundColor: CustomColors.error,
      );
    } else {
      CustomSnackbar.show(
        context: context,
        icon: Icons.error_outline,
        title: 'Search Failed',
        message: 'Could not find a valid location.',
        backgroundColor: CustomColors.error,
      );
    }
  } catch (e) {
    CustomSnackbar.show(
      context: context,
      icon: Icons.error_outline,
      title: 'Error',
      message: 'Something went wrong: $e',
      backgroundColor: CustomColors.error,
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);

    return AlertDialog(
      title: Text(
        "Pick Location",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search location...",
                hintStyle: Theme.of(context).textTheme.labelSmall,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  searchLocation(_searchController.text);
                }
              },
            ),

            const SizedBox(height: Sizes.sm),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
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
                            builder:
                                (ctx) => const Icon(
                                  Icons.location_pin,
                                  size: 40,
                                  color: Colors.red,
                                ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _getCurrentLocation,
          child: Text(
            "Use My Location",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: dark ? CustomColors.alternate : CustomColors.primary,
            ),
          ),
        ),
        TextButton(
          onPressed:
              _pickedLocation == null
                  ? null // disable button until location available
                  : () => Navigator.pop(context, _pickedLocation),
          child: Text(
            "Select",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: dark ? CustomColors.alternate : CustomColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
