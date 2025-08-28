import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/user/provider_profiles_controller.dart';
import '../../common/widgets/appbar/appbar.dart';

class AllProvidersScreen extends ConsumerWidget {
  const AllProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersState = ref.watch(providerProfilesController);

    return Scaffold(
      appBar: TAppBar(title: Text('Providers by City',
      style: Theme.of(context).textTheme.headlineSmall,
      ),
      showBackArrow: true,
      ),
      body: providersState.when(
        data: (grouped) {
          if (grouped.isEmpty) {
            return const Center(child: Text('No providers found.'));
          }
          final cities = grouped.keys.toList();
          return DefaultTabController(
            length: cities.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: cities.map((city) => Tab(text: city)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: cities.map((city) {
                      final providers = grouped[city]!;
                      return ListView.builder(
                        itemCount: providers.length,
                        itemBuilder: (context, index) {
                          final provider = providers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(provider['profileImage'] ?? ''),
                            ),
                            title: Text('${provider['firstname']} ${provider['lastname']}'),
                            subtitle: Text(provider['service'] ?? ''),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}