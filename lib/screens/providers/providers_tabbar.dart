import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/providers/providers_category_controller.dart';
import 'provider_screen.dart';

class ProvidersTabBarScreen extends ConsumerStatefulWidget {
  final String category;
  const ProvidersTabBarScreen({super.key, required this.category});

  @override
  ConsumerState<ProvidersTabBarScreen> createState() =>
      _ServicesTabBarScreenState();
}

class _ServicesTabBarScreenState extends ConsumerState<ProvidersTabBarScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider(widget.category));

    final profilesState = ref.read(debouncedProfilesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return const Center(child: Text("No services available"));
          }

          _tabController ??= TabController(length: services.length, vsync: this)
            ..addListener(() {
              if (!_tabController!.indexIsChanging) {
                final selectedService = services[_tabController!.index];
                ref
                    .read(debouncedProfilesProvider.notifier)
                    .fetchProfiles(widget.category, selectedService);
              }
            });

          if (_tabController!.index == 0 &&
              profilesState is AsyncData &&
              profilesState.value!.isEmpty) {
            ref
                .read(debouncedProfilesProvider.notifier)
                .fetchProfiles(widget.category, services[0]);
          }

          return Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: services.map((s) => Tab(text: s)).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children:
                      services.map((service) {
                        final profilesState = ref.watch(
                          debouncedProfilesProvider,
                        );

                        return profilesState.when(
                          data: (profiles) {
                            return ListView.builder(
                              itemCount: profiles.length,
                              itemBuilder: (context, index) {
                                final profile = profiles[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      profile.profileImage,
                                    ),
                                  ),
                                  title: Text(profile.firstname),
                                  subtitle: Text(profile.service),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ProviderScreen(
                                              profile: profile,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          loading:
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          error:
                              (err, stack) =>
                                  Center(child: Text(err.toString())),
                        );
                      }).toList(),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
