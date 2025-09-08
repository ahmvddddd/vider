import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

final providerProfilesController = StateNotifierProvider<
  ProviderProfilesNotifier,
  AsyncValue<Map<String, List<dynamic>>>
>((ref) => ProviderProfilesNotifier());

class ProviderProfilesNotifier
    extends StateNotifier<AsyncValue<Map<String, List<dynamic>>>> {
  ProviderProfilesNotifier() : super(const AsyncValue.loading()) {
    fetchAndGroupProviders();
  }

  // Cache for coordinates -> state
  final Map<String, String> _stateCache = {};
  final logger = Logger();

  Future<void> fetchAndGroupProviders() async {
    state = const AsyncValue.loading();
    String providerProfilesURL =
        dotenv.env['PROVIDER_PROFILES_URL'] ?? 'https://defaulturl.com/api';
    try {
      final res = await http.get(
        Uri.parse(providerProfilesURL),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> providers = jsonDecode(res.body);

        // Filter out providers with hidden locations
        final visibleProviders =
            providers.where((p) {
              final lat = (p['latitude'] as num).toDouble();
              final lon = (p['longitude'] as num).toDouble();
              return !(lat == 0 && lon == 0);
            }).toList();

        // Get states in parallel with caching
        final futures = visibleProviders.map((provider) async {
          final lat = (provider['latitude'] as num).toDouble();
          final lon = (provider['longitude'] as num).toDouble();
          final state = await getStateFromCoordinates(lat, lon);
          return {'state': state, 'provider': provider};
        });

        final results = await Future.wait(futures);

        // Group by state
        final Map<String, List<dynamic>> grouped = {};
        for (final item in results) {
          final stateName = item['state'] as String;
          grouped.putIfAbsent(stateName, () => []).add(item['provider']);
        }

        // Remove "Unknown" if you don't want it
        grouped.removeWhere(
          (state, list) => state == 'Unknown' || list.isEmpty,
        );

        state = AsyncValue.data(grouped);
      } else {
        final body = jsonDecode(res.body);

        try {
        state = AsyncValue.error(
          'Failed to fetch providers',
          StackTrace.current,
        );
          await FirebaseCrashlytics.instance.recordError(
            '${body['message']}',
            null,
            reason: 'Fetch Providers API returned error ${res.statusCode}',
          );
        } catch (e) {
          logger.i("Crashlytics logging failed: $e");
        }
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error('An error occured, failed to fetch providers', stackTrace);
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Change Password controller failed',
      );
    }
  }

  Future<String> getStateFromCoordinates(double lat, double lon) async {
    final cacheKey = '$lat,$lon';
    if (_stateCache.containsKey(cacheKey)) {
      return _stateCache[cacheKey]!;
    }

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
      );
      final res = await http.get(
        url,
        headers: {
          'User-Agent':
              'vider/1.0 (vider_support@gmail.com)', // REQUIRED by Nominatim
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final address = data['address'] ?? {};
        String state = address['state'] ?? address['region'] ?? 'Unknown';
        _stateCache[cacheKey] = state;
        return state;
      } else {
        _stateCache[cacheKey] = 'Unknown';
        return 'Unknown';
      }
    } catch (_) {
      _stateCache[cacheKey] = 'Unknown';
      return 'Unknown';
    }
  }
}
