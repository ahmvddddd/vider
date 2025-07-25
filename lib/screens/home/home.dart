import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import 'widgets/home_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool dark = Theme.of(context).brightness == Brightness.dark;
    int unreadCount = 5;
    return Scaffold(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What Service do you need ?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: Sizes.spaceBtwItems),
                SearchContainer(width: screenWidth * 0.90),

                const SizedBox(height: Sizes.spaceBtwItems),
                Text(
                  'Recommended',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: Sizes.sm),
                HomeListView(
                  sizedBoxHeight: screenHeight * 0.25,
                  scrollDirection: Axis.horizontal,
                  seperatorBuilder:
                      (context, index) => const SizedBox(width: Sizes.sm),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return RoundedContainer(
                      height: screenHeight * 0.24,
                      width: screenWidth * 0.35,
                      radius: Sizes.cardRadiusSm,
                      backgroundColor:
            dark
                ? CustomColors.white.withValues(alpha: 0.1)
                : CustomColors.black.withValues(alpha: 0.1),
        showBorder: true,
        borderColor: CustomColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ClipRRect(
                //     borderRadius: BorderRadius.circular(100),
                //   child: Container(
                //     width: horizontalCardHeight * 0.4,
                //     height: horizontalCardHeight * 0.4,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(100),
                //     color: dark ? Colors.black : Colors.white,),
                //     child: Center(
                //       child: Image.network(
                //         profileImage,
                //         fit: BoxFit.cover,
                //         height: horizontalCardHeight * 0.4,
                //       ),
                //     ),
                //   ),
                // ),
      
                //name
                const SizedBox(height: Sizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'profileName',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Iconsax.verify,
                      color: Colors.amber,
                      size: Sizes.iconSm,
                    ),
                  ],
                ),
              ],
            ),
      
            //no of jobs
            const SizedBox(height: Sizes.sm),
            Container(
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle
              ),
              padding: const EdgeInsets.all(Sizes.sm),
              child: Text(
                2.toString(),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white, fontSize: 10),
              ),
            ),
      
            
          ],
        ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
