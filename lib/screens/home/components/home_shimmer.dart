import 'package:flutter/widgets.dart';
import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../common/widgets/layouts/listview.dart';
import '../../../common/widgets/shimmer/shimmer_widget.dart';
import '../../../utils/constants/sizes.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Sizes.spaceBtwSections),
        // ShimmerWidget(
        //   height: screenHeight * 0.02,
        //   width: screenHeight * 0.30,
        //   radius: Sizes.cardRadiusLg,
        // ),

        // const SizedBox(height: Sizes.spaceBtwItems),
        // ShimmerWidget(
        //   height: screenHeight * 0.055,
        //   width: screenHeight * 0.90,
        //   radius: Sizes.cardRadiusLg,),

        // const SizedBox(height: Sizes.spaceBtwItems),
        GridLayout(
          mainAxisExtent: screenHeight * 0.11,
          crossAxisCount: 4,
          itemCount: 8,
          itemBuilder: (_, _) {
            return ShimmerWidget(
              height: screenHeight * 0.11,
              width: screenHeight * 0.13,
              radius: Sizes.cardRadiusLg,
            );
          },
        ),

        const SizedBox(height: Sizes.spaceBtwSections),
        ShimmerWidget(
          height: screenHeight * 0.02,
          width: screenHeight * 0.20,
          radius: Sizes.cardRadiusLg,
        ),
        const SizedBox(height: Sizes.sm),
        HomeListView(
          sizedBoxHeight: screenHeight * 0.28,
          scrollDirection: Axis.horizontal,
          seperatorBuilder: (context, index) => const SizedBox(width: Sizes.sm),
          itemCount: 4,
          itemBuilder: (context, index) {
            return ShimmerWidget(
              height: screenHeight * 0.28,
              width: screenWidth * 0.60,
              radius: Sizes.cardRadiusLg,
            );
          },
        ),
      ],
    );
  }
}
