// // screens/provider_profiles_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../controllers/user/provider_profiles_controller.dart';

// class ProviderProfilesScreen extends ConsumerWidget {
//   const ProviderProfilesScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final providersState = ref.watch(providerProfilesController);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Providers by City')),
//       body: providersState.when(
//         data: (grouped) {
//           if (grouped.isEmpty) {
//             return const Center(child: Text('No providers found.'));
//           }
//           final cities = grouped.keys.toList();
//           return DefaultTabController(
//             length: cities.length,
//             child: Column(
//               children: [
//                 TabBar(
//                   isScrollable: true,
//                   tabs: cities.map((city) => Tab(text: city)).toList(),
//                 ),
//                 Expanded(
//                   child: TabBarView(
//                     children: cities.map((city) {
//                       final providers = grouped[city]!;
//                       return ListView.builder(
//                         itemCount: providers.length,
//                         itemBuilder: (context, index) {
//                           final provider = providers[index];
//                           return ListTile(
//                             leading: CircleAvatar(
//                               backgroundImage: NetworkImage(provider['profileImage'] ?? ''),
//                             ),
//                             title: Text('${provider['firstname']} ${provider['lastname']}'),
//                             subtitle: Text(provider['service'] ?? ''),
//                           );
//                         },
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text('Error: $e')),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/user/provider_profiles_controller.dart';

class ProviderProfilesScreen extends ConsumerWidget {
  final double lat;
  final double lon;

  const ProviderProfilesScreen({
    super.key,
    required this.lat,
    required this.lon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesState = ref.watch(providerProfilesController);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Providers Nearby'),
      ),
      body: profilesState.when(
        data: (groupedProfiles) {
          final notifier = ref.read(providerProfilesController.notifier);

          return FutureBuilder<String>(
            future: notifier.getStateFromCoordinates(lat, lon),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final stateName = snapshot.data!;
              final providers = groupedProfiles[stateName] ?? [];

              if (providers.isEmpty) {
                return Center(
                  child: Text('No providers found in $stateName'),
                );
              }

              return SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: providers.length,
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    return _ProviderCard(provider: provider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;

  const _ProviderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: provider['profileImage'] != null
                ? NetworkImage(provider['profileImage'])
                : null,
            radius: 35,
            child: provider['profileImage'] == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            provider['firstname'] ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            provider['service'] ?? '',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
