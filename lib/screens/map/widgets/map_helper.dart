import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../controllers/providers/provider_map_controller.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../providers/provider_screen.dart';

class MapHelper {
  static Future<void> searchLocation({
    required String query,
    required MapController mapController,
    required WidgetRef ref,
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

  static void showProviderPopup(BuildContext context, dynamic provider) {
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
                  Row(
                    children: [
                      Icon(Icons.star, color: ratingColor, size: Sizes.iconSm),
                      Text(
                        '${provider.rating}',
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: dark ? Colors.white : Colors.black,
                          fontFamily: 'JosefinSans',
                        ),
                      ),
                    ],
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

  static void fetchProvidersForBounds(
    MapController mapController,
    WidgetRef ref,
  ) {
    final bounds = mapController.bounds;
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

  
}
