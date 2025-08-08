import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersistentLocationSwitchNotifier extends StateNotifier<bool> {
  static const _prefKey = 'location_switch';

  PersistentLocationSwitchNotifier() : super(false) {
    _loadSwitchState();
  }

  Future<void> _loadSwitchState() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefKey);
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> setSwitch(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }
}


final persistentLocationSwitchProvider  =
    StateNotifierProvider<PersistentLocationSwitchNotifier, bool>(
  (ref) => PersistentLocationSwitchNotifier(),
);
