import 'package:shared_preferences/shared_preferences.dart';

class MatchingLocationStorage {
  static const _latKey = 'user_latitude';
  static const _lonKey = 'user_longitude';
  static const _stateKey = 'user_state';

  /// Save location data
  static Future<void> saveLocation(double lat, double lon, String state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lonKey, lon);
    await prefs.setString(_stateKey, state);
  }

  /// Load location data
  static Future<Map<String, dynamic>?> loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lon = prefs.getDouble(_lonKey);
    final state = prefs.getString(_stateKey);

    if (lat != null && lon != null && state != null) {
      return {'lat': lat, 'lon': lon, 'state': state};
    }
    return null;
  }

  /// Clear location (optional)
  static Future<void> clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latKey);
    await prefs.remove(_lonKey);
    await prefs.remove(_stateKey);
  }
}
