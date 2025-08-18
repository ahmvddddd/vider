import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../common/widgets/layouts/grid_layout.dart';
import '../../controllers/providers/providers_category_controller.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import 'widgets/providers_tabbar.dart';

class AllProviderCategories extends ConsumerStatefulWidget {
  const AllProviderCategories({super.key});

  @override
  ConsumerState<AllProviderCategories> createState() =>
      _AllProviderCategoriesState();
}

class _AllProviderCategoriesState extends ConsumerState<AllProviderCategories> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    double screenHeight = MediaQuery.of(context).size.height;
    final dark = HelperFunction.isDarkMode(context);
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'All Categories',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.spaceBtwItems),
          child: categoriesAsync.when(
            data: (categories) {
              return GridLayout(
                itemCount: categories.length,
                crossAxisCount: 4,
                mainAxisExtent: screenHeight * 0.11,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      HelperFunction.navigateScreen(
                        context,
                        ProvidersTabBarScreen(category: category),
                      );
                    },
                    child: _buildCategoryBox(
                      context,
                      dark,
                      screenHeight,
                      category,
                      isViewMore: true,
                    ),
                  );
                },
              );
            },
            loading:
                () => CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 4.0,
                  backgroundColor: dark ? Colors.white : Colors.black,
                ),
            error:
                (err, _) => Center(
                  child: Text(
                    err.toString(),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
          ),
        ),
      ),
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
