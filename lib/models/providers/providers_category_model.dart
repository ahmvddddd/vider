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
    return ProvidersCategoryModel(
      userId: json['userId'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      isIdVerified: json['isIdVerified'] ?? false,
      category: json['category'] ?? '',
      service: json['service'] ?? '',
      bio: json['bio'] ?? '',
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      skills: List<String>.from(json['skills'] ?? []),
      profileImage: json['profileImage'],
      portfolioImages: List<String>.from(json['portfolioImages'] ?? []),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}
