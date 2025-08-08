import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user/user_profile_model.dart';

class UserLocalStorage {
  static const String _key = 'user_profile';

  /// Save user profile to local storage
  static Future<void> saveUserProfile(UserProfileModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_key, userJson);
  }

  /// Load user profile from local storage
  static Future<UserProfileModel?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_key);
    if (userJson == null) return null;
    final Map<String, dynamic> userMap = jsonDecode(userJson);
    return UserProfileModel.fromJson(userMap);
  }

  /// Remove user profile from local storage
  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
