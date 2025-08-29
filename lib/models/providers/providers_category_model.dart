class ProvidersCategoryModel {
  final String userId;
  final String firstname;
  final String lastname;
  final String username;
  final String email;
  final bool isIdVerified;
  final String category;
  final String service;
  final String bio;
  final double hourlyRate;
  final List<String> skills;
  final String profileImage;
  final List<String> portfolioImages;
  final double latitude;
  final double longitude;
  final double rating;

  ProvidersCategoryModel({
    required this.userId,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.email,
    required this.isIdVerified,
    required this.category,
    required this.service,
    required this.bio,
    required this.hourlyRate,
    required this.skills,
    required this.profileImage,
    required this.portfolioImages,
    required this.latitude,
    required this.longitude,
    required this.rating,
  });

  factory ProvidersCategoryModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '0') ?? 0.0;

    return ProvidersCategoryModel(
      userId: (json['userId'] ?? '').toString(),
      firstname: (json['firstname'] ?? '').toString(),
      lastname: (json['lastname'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      isIdVerified: (json['isIdVerified'] ?? false) == true,
      category: (json['category'] ?? '').toString(),
      service: (json['service'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      hourlyRate: _toDouble(json['hourlyRate']),
      skills: List<String>.from(json['skills'] ?? const []),
      profileImage: (json['profileImage'] ?? '').toString(),
      portfolioImages: List<String>.from(json['portfolioImages'] ?? const []),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      rating: _toDouble(json['rating']),
    );
  }
}
