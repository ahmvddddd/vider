class UserProfileModel {
  final String userId;
  final String profileImage;
  final String username;
  final String firstname;
  final String lastname;
  final String email;
  final String category;
  final String bio;
  final String service;
  final double hourlyRate;
  final List<String> skills;
  final List<String> portfolioImages;
  final double rating;
  final bool isIdVerified;
  final String verificationStatus;

  UserProfileModel({
    required this.userId,
    required this.profileImage,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.category,
    required this.bio,
    required this.service,
    required this.skills,
    required this.hourlyRate,
    required this.portfolioImages,
    required this.rating,
    required this.isIdVerified,
    required this.verificationStatus
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['_id'] ?? '',
      profileImage: json['profileImage'] ?? '',
      username: json['username'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      category: json['category'] ?? '',
      bio: json['bio'] ?? '',
      service: json['service'] ?? '',
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      skills: List<String>.from(json['skills'] ?? []),
      portfolioImages: List<String>.from(json['portfolioImages'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      isIdVerified: (json['isIdVerified'] ?? false),
      verificationStatus: json['verificationStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profileImage': profileImage,
      'username': username,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'category': category,
      'bio': bio,
      'service': service,
      'hourlyRate': hourlyRate,
      'skills': skills,
      'portfolioImages': portfolioImages,
      'rating': rating,
      'isIdVerified': isIdVerified,
      'verificationStatus': verificationStatus
    };
  }
}
