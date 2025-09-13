import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vider/utils/helpers/helper_function.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../common/widgets/layouts/listview.dart';
import '../../../common/widgets/shimmer/shimmer_widget.dart';
import '../../../utils/constants/sizes.dart';

class ProviderProfilesShimmer extends StatelessWidget {
  const ProviderProfilesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final dark = HelperFunction.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Sizes.sm),
        HomeListView(
          sizedBoxHeight: screenHeight * 0.28,
          scrollDirection: Axis.horizontal,
          seperatorBuilder: (context, index) => const SizedBox(width: Sizes.sm),
          itemCount: 4,
          itemBuilder: (context, index) {
            return RoundedContainer(
              backgroundColor:
                  dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                      radius: Sizes.cardRadiusLg,
                      padding: const EdgeInsets.all(Sizes.xs),
              child: Column(
                children: [
                  ShimmerWidget(
                    height: screenHeight * 0.18,
                    width: screenWidth * 0.35,
                    radius: Sizes.cardRadiusMd,
                  ),

                  const SizedBox(height: Sizes.xs),
                  Row(
                    children: [
                      ShimmerWidget(
                    height: screenHeight * 0.05,
                    width: screenHeight * 0.05,
                    radius: 100
                  ),

                  const SizedBox(width: Sizes.sm),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget(
                    height: screenHeight * 0.02,
                    width: screenWidth * 0.15,
                    radius: 100
                  ),

                  const SizedBox(height: 2,),
                  ShimmerWidget(
                    height: screenHeight * 0.02,
                    width: screenWidth * 0.10,
                    radius: 100
                  ),
                    ],
                  )
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
