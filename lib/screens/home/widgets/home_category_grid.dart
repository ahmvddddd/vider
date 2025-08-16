import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../controllers/jobs/occupations_controller.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../providers/providers_category_list.dart';
import 'home_tabbar.dart';

class HomeCategoryGrid extends ConsumerWidget {
  final double lat;
  final double lon;

  const HomeCategoryGrid({super.key, required this.lat, required this.lon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenHeight = MediaQuery.of(context).size.height;
    final dark = HelperFunction.isDarkMode(context);

    final occupationState = ref.watch(occupationControllerProvider);

    return occupationState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(err.toString(), style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(occupationControllerProvider.notifier)
                        .refreshOccupations();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
      data: (occupations) {
        final categories = occupations.map((e) => e.category).toList();

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
                  child: _buildCategoryBox(
                    context,
                    dark,
                    screenHeight,
                    'View More',
                    isViewMore: true,
                  ),
                )
                : GestureDetector(
                  onTap: () {
                    HelperFunction.navigateScreen(
                      context,
                      ProvidersCategoryList(
                        lat: lat,
                        lon: lon,
                        category: categories[index],
                      ),
                    );
                  },
                  child: _buildCategoryBox(
                    context,
                    dark,
                    screenHeight,
                    categories[index],
                  ),
                );
          },
        );
      },
    );
  }

  Widget _buildCategoryBox(
    BuildContext context,
    bool dark,
    double screenHeight,
    String title, {
    bool isViewMore = false,
  }) {
    return RoundedContainer(
      height: screenHeight * 0.11,
      width: screenHeight * 0.11,
      padding: const EdgeInsets.all(2),
      backgroundColor:
          isViewMore
              ? (dark ? CustomColors.alternate : CustomColors.primary)
              : (dark ? Colors.black : Colors.white),
      boxShadow:
          isViewMore
              ? null
              : [
                BoxShadow(
                  color: dark ? CustomColors.darkerGrey : CustomColors.darkGrey,
                  blurRadius: 5,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 1),
                ),
              ],
      radius: Sizes.cardRadiusLg,
      child: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color:
                isViewMore
                    ? (dark ? Colors.black : Colors.white)
                    : (dark ? Colors.white : Colors.black),
            fontSize: 10,
          ),
          softWrap: true,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
