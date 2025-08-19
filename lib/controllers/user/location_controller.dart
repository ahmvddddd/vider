import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/user/custom_location.dart';

class LocationState {
  final List<CustomLocation> locations;
  final bool isLoading;

  LocationState({required this.locations, required this.isLoading});

  LocationState copyWith({
    List<CustomLocation>? locations,
    bool? isLoading,
  }) {
    return LocationState(
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationController extends StateNotifier<LocationState> {
  LocationController() : super(LocationState(locations: [], isLoading: false));

  final _storage = const FlutterSecureStorage();

  Future<void> fetchLocations() async {
    state = state.copyWith(isLoading: true);

    try {
      final token = await _storage.read(key: 'token');

      final response = await http.get(
        Uri.parse('http://localhost:3000/api/getlocation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetchedLocations = List<Map<String, dynamic>>.from(data['data']);

        final locations = fetchedLocations
            .map((json) => CustomLocation.fromJson(json))
            .toList();

        state = LocationState(locations: locations, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
        throw Exception('Failed to fetch locations.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final locationProvider =
    StateNotifierProvider<LocationController, LocationState>(
        (ref) => LocationController());
