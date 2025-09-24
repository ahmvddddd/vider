import 'package:flutter/material.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../common/widgets/layouts/listview.dart';
import '../../../common/widgets/shimmer/shimmer_widget.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/helpers/responsive_size.dart';

class ChatShimmer extends StatelessWidget {
  const ChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double xSAvatarHeight = screenHeight * 0.055;
    final dark = HelperFunction.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(responsiveSize(context, Sizes.spaceBtwItems)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: responsiveSize(context, Sizes.spaceBtwSections)),
              HomeListView(
                scrollDirection: Axis.vertical,
                seperatorBuilder:
                    (context, index) =>
                        SizedBox(height: responsiveSize(context, Sizes.sm)),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return RoundedContainer(
                    padding: EdgeInsets.all(responsiveSize(context, Sizes.sm)),
                    radius: Sizes.borderRadiusMd,
                    backgroundColor:
                        dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                    width: screenWidth * 0.90,
                    child: Row(
                      children: [
                        //image
                        ShimmerWidget(
                          height: responsiveSize(context, xSAvatarHeight),
                          width: responsiveSize(context, xSAvatarHeight),
                          radius: 100,
                        ),
                        //name and service
                        SizedBox(width: responsiveSize(context, Sizes.sm)),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerWidget(
                              width: screenWidth * 0.40,
                              height: screenHeight * 0.02,
                              radius: 50,
                            ),
                            SizedBox(height: responsiveSize(context, Sizes.xs)),
                            ShimmerWidget(
                              width: screenWidth * 0.60,
                              height: screenHeight * 0.02,
                              radius: 50,
                            ),
                          ],
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
    );
  }
}
