import 'package:flutter/material.dart';

import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import 'home_tabbar.dart';

class HomeCategoryGrid extends StatefulWidget {
  const HomeCategoryGrid({super.key});

  @override
  State<HomeCategoryGrid> createState() => _HomeCategoryGridState();
}

class _HomeCategoryGridState extends State<HomeCategoryGrid> {
  final List<String> categories = [
    'Beauty',
    'Construction',
    'Entertaiment',
    'Fashion',
    'Food',
    'Health & Fitness',
    'Home repair',
    'Writing',
    'Programming',
    'Marketing'
  ];
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final dark = HelperFunction.isDarkMode(context);
    return GridLayout(
      itemCount: categories.length > 8 ? 8 : categories.length,
      crossAxisCount: 4,
      mainAxisExtent: screenHeight * 0.11,
      itemBuilder: (context, index) {
        final isViewMore = index == 7 && categories.length > 8;
        return isViewMore
            ? GestureDetector(
              onTap: () {
                HelperFunction.navigateScreen(context, HomeTabbar());
              },
              child: RoundedContainer(
                height: screenHeight * 0.11,
                width: screenHeight * 0.13,
                backgroundColor: dark ? CustomColors.alternate : CustomColors.primary,
                radius: Sizes.cardRadiusLg,
                child: Center(
                  child: Center(
                    child: Text(
                      'View More',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall!.copyWith(color: dark ? Colors.black : Colors.white),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
            : RoundedContainer(
              height: screenHeight * 0.13,
              width: screenHeight * 0.13,
              backgroundColor: dark ? Colors.black : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: dark ? CustomColors.darkerGrey : CustomColors.darkGrey,
                  blurRadius: 5,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 1),
                ),
              ],
              radius: Sizes.cardRadiusLg,
              child: Center(
                child: Center(
                  child: Text(
                    categories[index],
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: dark ? Colors.white : Colors.black,
                    ),
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
      },
    );
  }
}
