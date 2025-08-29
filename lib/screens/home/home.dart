import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/widgets/texts/section_heading.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import '../providers/all_providers_screen.dart';
import '../providers/widgets/providers_grid.dart';
import 'components/home_shimmer.dart';
import 'widgets/home_appbar.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/provider_profiles_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showShimmer = true;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showShimmer = false;
        });
      }
    });
  }

  

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final dark = HelperFunction.isDarkMode(context);
    int unreadCount = 5;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                expandedHeight: screenHeight * 0.09,
                backgroundColor: dark ? Colors.black : Colors.white,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.all(Sizes.sm),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [HomeAppBar(unreadCount: unreadCount)],
                  ),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.spaceBtwItems),
              child: _showShimmer
                  ? const HomeShimmer()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Sizes.spaceBtwSections),
                        HomeSearchBar(),
                        
                        const SizedBox(height: Sizes.spaceBtwItems),
                        ProvidersGrid(),
                        const SizedBox(height: Sizes.spaceBtwSections),
                        SectionHeading(
                          title: 'Providers near you',
                          onPressed: () => HelperFunction.navigateScreen(
                            context,
                            AllProvidersScreen(),
                          ),
                        ),
                        const SizedBox(height: Sizes.sm),
                        ProviderProfilesWidget(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
