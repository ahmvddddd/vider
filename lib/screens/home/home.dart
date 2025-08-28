import 'dart:async';
import 'package:flutter/material.dart';
// import '../../common/widgets/custom_shapes/cards/provider_card.dart';
import '../../common/widgets/custom_shapes/containers/search_container.dart';
// import '../../common/widgets/layouts/listview.dart';
import '../../common/widgets/texts/section_heading.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import '../map/providers_map.dart';
import '../providers/all_providers_screen.dart';
import '../providers/widgets/providers_grid.dart';
import 'components/home_shimmer.dart';
import 'widgets/home_appbar.dart';
import 'widgets/provider_profiles_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> serviceProviders = [
    {
      "imageUrl":
          "https://cdn.pixabay.com/photo/2017/09/26/11/10/plumber-2788330_1280.jpg",
      "fullname": "John Doe",
      "description": "Expert plumbing services with 10+ years of experience.",
      "service": "Plumber",
      "ratingColor": Colors.amber,
      "rating": 4.5,
    },
    {
      "imageUrl":
          "https://cdn.pixabay.com/photo/2015/09/09/19/57/cleaning-932936_960_720.jpg",
      "fullname": "Fatima Zarah",
      "description": "Professional home and office cleaning.",
      "service": "Cleaner",
      "ratingColor": Colors.brown,
      "rating": 2.0,
    },
    {
      "imageUrl":
          "https://cdn.pixabay.com/photo/2018/03/29/19/19/electrician-3273340_1280.jpg",
      "fullname": "Chukwu Emeka",
      "description": "Certified electrician for all electrical needs.",
      "service": "Electrician",
      "ratingColor": CustomColors.darkGrey,
      "rating": 3.2,
    },
    {
      "imageUrl":
          "https://cdn.pixabay.com/photo/2020/04/28/13/21/landscape-5104510_1280.jpg",
      "fullname": "Janette Dough",
      "description": "Beautiful garden designs and maintenance.",
      "service": "Landscaper",
      "ratingColor": Colors.amber,
      "rating": 4.8,
    },
    {
      "imageUrl":
          "https://cdn.pixabay.com/photo/2015/01/12/00/16/sushi-596930_960_720.jpg",
      "fullname": "Ada Obi",
      "description": "Catering and cullinary services for all type of events .",
      "service": "Chef",
      "ratingColor": Colors.brown,
      "rating": 2.4,
    },
  ];

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
    double screenWidth = MediaQuery.of(context).size.width;
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
              child:
                  _showShimmer
                      ? const HomeShimmer()
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Sizes.spaceBtwSections),
                          Text(
                            'What Service do you need ?',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall!.copyWith(
                              color:
                                  dark
                                      ? CustomColors.alternate
                                      : CustomColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: Sizes.spaceBtwItems),
                          SearchContainer(
                            width: screenWidth * 0.90,
                            onTap: () => FocusScope.of(context).unfocus(),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color:
                                      dark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: GestureDetector(
                                  onTap:
                                      () => HelperFunction.navigateScreen(
                                        context,
                                        ProvidersMapPage(),
                                      ),
                                  child: Icon(
                                    Icons.location_pin,
                                    size: Sizes.iconM,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: Sizes.spaceBtwSections),
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
