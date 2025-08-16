import 'package:flutter/material.dart';
import '../../models/providers/providers_category_model.dart';

class ProviderScreen extends StatelessWidget {
  final ProvidersCategoryModel profile;

  const ProviderScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(profile.firstname)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profile.profileImage),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              profile.firstname,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Category: ${profile.category}"),
            Text("Service: ${profile.service}"),
            const SizedBox(height: 20),
            // If you have description, bio, etc
            Text(profile.bio, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
