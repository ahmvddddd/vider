import 'package:flutter/material.dart';
import '../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../common/widgets/custom_shapes/divider/custom_divider.dart';
import '../../../../common/widgets/shimmer/shimmer_widget.dart';
import '../../../../utils/constants/custom_colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_function.dart';
import '../../../common/widgets/layouts/listview.dart';
import '../../../utils/helpers/responsive_size.dart';

class JobsScreenShimmer extends StatelessWidget {
  const JobsScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(responsiveSize(context, Sizes.spaceBtwItems)),
            child: HomeListView(
              scrollDirection: Axis.vertical,
              itemCount: 5,
              scrollPhysics: const NeverScrollableScrollPhysics(),
              seperatorBuilder:
                  (context, index) =>
                      SizedBox(height: responsiveSize(context, Sizes.spaceBtwItems)),
              itemBuilder: (context, index) {
                return RoundedContainer(
                  padding: const EdgeInsets.all(Sizes.sm),
                  backgroundColor:
                      dark
                          ? CustomColors.white.withValues(alpha: 0.1)
                          : CustomColors.black.withValues(alpha: 0.1),
                  width: screenWidth * 0.90,
                  height: screenHeight * 0.25,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ShimmerWidget(
                            width: screenHeight * 0.055,
                            height: screenHeight * 0.055,
                            radius: 100,
                          ),

                          SizedBox(height: responsiveSize(context, Sizes.sm)),
                          ShimmerWidget(
                            width: screenWidth * 0.12,
                            height: screenHeight * 0.01,
                            radius: 100,
                          ),
                        ],
                      ),

                      CustomDivider(
                        padding: EdgeInsets.all(responsiveSize(context, Sizes.spaceBtwItems)),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerWidget(
                            width: screenWidth * 0.12,
                            height: screenHeight * 0.01,
                            radius: 100,
                          ),
                          ShimmerWidget(
                            width: screenWidth * 0.15,
                            height: screenHeight * 0.01,
                            radius: 100,
                          ),
                        ],
                      ),

                      SizedBox(height: responsiveSize(context, Sizes.xs)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerWidget(
                            width: screenWidth * 0.12,
                            height: screenHeight * 0.01,
                            radius: 100,
                          ),
                          ShimmerWidget(
                            width: screenWidth * 0.15,
                            height: screenHeight * 0.01,
                            radius: 100,
                          ),
                        ],
                      ),

                      SizedBox(height: responsiveSize(context, Sizes.xs)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerWidget(
                            width: screenWidth * 0.12,
                            height: screenHeight * 0.01,
                            radius: 100,
                          ),
                          ShimmerWidget(
                            width: screenWidth * 0.15,
                            height: screenHeight * 0.01,
                            radius: 100,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
