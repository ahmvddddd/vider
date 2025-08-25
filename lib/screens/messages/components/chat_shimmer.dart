import 'package:flutter/material.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../common/widgets/layouts/listview.dart';
import '../../../common/widgets/shimmer/shimmer_widget.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';

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
          padding: const EdgeInsets.all(Sizes.spaceBtwItems),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: Sizes.spaceBtwSections),
              ShimmerWidget(
                width: screenWidth * 0.80,
                height: screenHeight * 0.01,
                radius: 50,
              ),
    
              const SizedBox(height: Sizes.spaceBtwItems),
              HomeListView(
                scrollDirection: Axis.vertical,
                seperatorBuilder:
                    (context, index) => const SizedBox(height: Sizes.sm),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return RoundedContainer(
                    padding: const EdgeInsets.all(Sizes.sm),
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
                          height: xSAvatarHeight,
                          width: xSAvatarHeight,
                          radius: 100,
                        ),
                        //name and service
                        const SizedBox(width: Sizes.sm),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerWidget(
                              width: screenWidth * 0.40,
                              height: screenHeight * 0.02,
                              radius: 50,
                            ),
                            const SizedBox(height: Sizes.xs),
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
