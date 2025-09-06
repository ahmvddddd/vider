import 'package:flutter/widgets.dart';
import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../common/widgets/shimmer/shimmer_widget.dart';
import '../../../utils/constants/sizes.dart';

class ProvidersGridShimmer extends StatelessWidget {
  const ProvidersGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: Sizes.spaceBtwItems),
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
      ],
    );
  }
}
