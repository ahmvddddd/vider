import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/user/user_profile_model.dart';
import '../../repository/user/user_local_storage.dart';

final FlutterSecureStorage storage = FlutterSecureStorage();
final userProvider = StateNotifierProvider<UserController, AsyncValue<UserProfileModel>>((ref) {
  return UserController();
});

class UserController extends StateNotifier<AsyncValue<UserProfileModel>> {
  UserController() : super(const AsyncLoading()) {
    fetchUserDetails();
  }
String profileURL = dotenv.env['PROFILE_URL'] ?? 'https://defaulturl.com/api';

  Future<void> fetchUserDetails() async {
    try {
      final token = await storage.read(key: 'token');
      final response = await http.get(Uri.parse(profileURL),
        headers: {
          'Authorization': 'Bearer $token',
        },
);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserProfileModel.fromJson(data);

        // Save to shared preferences
        await UserLocalStorage.saveUserProfile(user);
        state = AsyncData(user);
      } else {
        state = AsyncError('Failed to load user profile details', StackTrace.current);
        await FirebaseCrashlytics.instance.recordError(
          Exception("Failed to fetch user profile details: ${response.body}"),
          null,
          reason:
          'User profile details API returned error ${response.statusCode}',
        );
      }
    } catch (error, stackTrace) {
      state = AsyncError('Failed to load user profile details', stackTrace);
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Fetch user profile controller failed',
      );
    }
  }
}