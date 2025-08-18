import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/custom_shapes/cards/category_card.dart';
import '../../../common/widgets/layouts/listview.dart';
import '../../../controllers/providers/providers_category_controller.dart';
import '../../../models/providers/providers_category_model.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/constants/custom_colors.dart';
import '../provider_screen.dart';

class ProvidersTabBarScreen extends ConsumerStatefulWidget {
  final String category;
  const ProvidersTabBarScreen({super.key, required this.category});

  @override
  ConsumerState<ProvidersTabBarScreen> createState() =>
      _ProvidersTabBarScreenState();
}

class _ProvidersTabBarScreenState extends ConsumerState<ProvidersTabBarScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider(widget.category));
    final dark = HelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          widget.category,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.sm),
        child: servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return const Center(child: Text("No services available"));
            }

            // Create or update TabController
            if (_tabController == null || _tabController!.length != services.length) {
              _tabController?.dispose();
              _tabController = TabController(
                length: services.length,
                vsync: this,
              );
            }

            return Column(
              children: [
                // 🔹 Animated TabBar with pill design
                SizedBox(
                  height: 50,
                  child: AnimatedBuilder(
                    animation: _tabController!,
                    builder: (context, _) {
                      return TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                        indicator: const BoxDecoration(), // remove default line
                        indicatorColor: Colors.transparent,
                        tabs: List.generate(services.length, (index) {
                          final isSelected = _tabController!.index == index;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Sizes.md,
                              vertical: Sizes.sm,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? CustomColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              services[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.blueGrey,
                                  ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 TabBarView for profiles
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(services.length, (index) {
                      final service = services[index];
                      return _ServiceTabBody(
                        category: widget.category,
                        service: service,
                      );
                    }),
                  ),
                ),
              ],
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              strokeWidth: 4.0,
              backgroundColor: dark ? Colors.white : Colors.black,
            ),
          ),
          error: (e, _) =>
              const Center(child: Text("An error occured, Could not load providers")),
        ),
      ),
    );
  }
}

class _ServiceTabBody extends ConsumerWidget {
  final String category;
  final String service;

  const _ServiceTabBody({
    required this.category,
    required this.service,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync =
        ref.watch(serviceProfilesProvider((category: category, service: service)));

    return profilesAsync.when(
      data: (profiles) => _buildProfileList(context, profiles),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildProfileList(
    BuildContext context,
    List<ProvidersCategoryModel> profiles,
  ) {
    if (profiles.isEmpty) {
      return const Center(child: Text("No profiles available"));
    }
    return Padding(
      padding: const EdgeInsets.all(Sizes.spaceBtwItems),
      child: HomeListView(
        scrollDirection: Axis.vertical,
        seperatorBuilder: (context, index) => const SizedBox(width: Sizes.sm),
        itemCount: profiles.length,
        itemBuilder: (_, i) {
          final profile = profiles[i];
          return GestureDetector(
            onTap: () {
              HelperFunction.navigateScreen(context, ProviderScreen(profile: profile));
            },
            child: CategoryCard(
              potfolioImage: profile.portfolioImages[0],
              imageAvatar: profile.profileImage,
              fullname: '${profile.firstname} ${profile.lastname}',
              service: profile.service,
              description: profile.bio,
              hourlyRate: profile.hourlyRate,
              rating: 5,
              ratingColor: Colors.amber,
            ),
          );
        },
      ),
    );
  }
}
