// ignore_for_file: deprecated_member_use

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../repository/user/location_state_storage.dart';
import '../../utils/constants/custom_colors.dart';

final storage = FlutterSecureStorage();

/// Provider to manage switch state globally
final locationSwitchProvider =
    StateNotifierProvider<LocationSwitchNotifier, bool>(
      (ref) => LocationSwitchNotifier(),
    );

class LocationSwitchNotifier extends StateNotifier<bool> {
  LocationSwitchNotifier() : super(false);

  void setSwitch(bool value) => state = value;
}

/// Controller provider
final saveLocationProvider = Provider((ref) => SaveLocationController(ref));

class SaveLocationController {
  final Ref ref;
  SaveLocationController(this.ref);

  Future<void> getAndSaveLocation(BuildContext context) async {
    final bool isLocationEnabled = ref.read(persistentLocationSwitchProvider);
    String saveLocationURL =
        dotenv.env['SAVE_LOCATION_URL'] ?? 'https/defaulturl.com/api';

    double latitude = 0.0;
    double longitude = 0.0;
    final logger = Logger();

    try {
      if (isLocationEnabled) {
        // Step 1: Check permission status
        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception('Location permission denied by user.');
          }
        }

        if (permission == LocationPermission.deniedForever) {
          throw Exception(
            'Location permission permanently denied. Please enable it in app settings.',
          );
        }

        // Step 2: Get position
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        latitude = position.latitude;
        longitude = position.longitude;
      }

      final token = await storage.read(key: 'token');
      final response = await http.post(
        Uri.parse(saveLocationURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
      );

      if (response.statusCode == 201) {
        return;
      } else {
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to save user location: ${response.body}"),
            null,
            reason: 'Save location API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics save user location API response failed: $e');
        }

        CustomSnackbar.show(
          context: context,
          icon: Icons.error_outline,
          title: 'An error occurred',
          message: response.body,
          backgroundColor: CustomColors.error,
        );
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Save user location controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics save user location controller failed: $e');
      }

      CustomSnackbar.show(
        context: context,
        icon: Icons.error_outline,
        title: 'An error occured',
        message: 'Could not save location status',
        backgroundColor: CustomColors.error,
      );
    }
  }
}

/// Controller provider
final saveSimpleLocationProvider = Provider(
  (ref) => SaveSimpleLocationController(ref),
);

class SaveSimpleLocationController {
  final Ref ref;
  SaveSimpleLocationController(this.ref);

  Future<void> saveUserLocation(BuildContext context) async {
    String saveLocationURL =
        dotenv.env['SAVE_LOCATION_URL'] ?? 'https/defaulturl.com/api';
    double latitude = 0.0;
    double longitude = 0.0;
    final logger = Logger();

    try {
      // Step 1: Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied by user.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission permanently denied. Please enable it in app settings.',
        );
      }

      // Step 2: Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;

      final token = await storage.read(key: 'token');
      final response = await http.post(
        Uri.parse(saveLocationURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
      );

      if (response.statusCode == 201) {
        return;
      } else {
        await FirebaseCrashlytics.instance.recordError(
          Exception("Failed to save user location: ${response.body}"),
          null,
          reason: 'Save location API returned error ${response.statusCode}',
        );

        return;
      }
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Save user location controller failed',
      );

      CustomSnackbar.show(
        context: context,
        icon: Icons.error_outline,
        title: 'Error',
        message: error.toString(),
        backgroundColor: CustomColors.error,
      );

      logger.e('Save location error: $error');
    }
  }
}
