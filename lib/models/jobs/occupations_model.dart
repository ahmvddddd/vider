class Occupation {
  final String category;
  final List<String> service;

  Occupation({
    required this.category,
    required this.service,
  });

  factory Occupation.fromJson(Map<String, dynamic> json) {
    return Occupation(
      category: json['category'],
      service: List<String>.from(json['service'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'service': service,
    };
  }
}
