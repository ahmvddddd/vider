import 'package:latlong2/latlong.dart';

class CustomLocation {
  final String userId;
  final String username;
  final double latitude;
  final double longitude;

  CustomLocation({
    required this.userId,
    required this.username,
    required this.latitude,
    required this.longitude,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  factory CustomLocation.fromJson(Map<String, dynamic> json) {
    return CustomLocation(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}