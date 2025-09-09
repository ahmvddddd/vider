import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../common/widgets/texts/error_retry.dart';
import '../../../controllers/providers/providers_category_controller.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../all_provider_categories.dart';
import '../components/providers_grid_shimmer.dart';
import 'providers_tabbar.dart';

class ProvidersGrid extends ConsumerWidget {
  const ProvidersGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    final dark = HelperFunction.isDarkMode(context);

    return categoriesAsync.when(
      data: (categories) {
        return GridLayout(
          crossAxisCount: 4,
          mainAxisExtent: screenWidth * 0.20,
          itemCount: categories.length > 8 ? 8 : categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isViewMore = index == 7 && categories.length > 8;
            return isViewMore
                ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllProviderCategories(),
                      ),
                    );
                  },
                  child: _buildCategoryBox(
                    context,
                    dark,
                    screenWidth,
                    'View More',
                    isViewMore: true,
                  ),
                )
                : GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ProvidersTabBarScreen(category: category),
                      ),
                    );
                  },
                  child: _buildCategoryBox(
                    context,
                    dark,
                    screenWidth,
                    category,
                    isViewMore: false,
                  ),
                );
          },
        );
      },
      loading: () => const ProvidersGridShimmer(),
      error:
          (err, _) => ErrorRetry(
            err: err,
            onPressed: () {
              ref.refresh(categoriesProvider);
            },
          ),
    );
  }

  Widget _buildCategoryBox(
    BuildContext context,
    bool dark,
    double screenWidth,
    String title, {
    bool isViewMore = false,
  }) {
    return RoundedContainer(
      height: screenWidth * 0.20,
      width: screenWidth * 0.20,
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
