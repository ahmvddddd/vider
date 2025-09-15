import 'package:flutter/widgets.dart';
import '../../../common/widgets/layouts/grid_layout.dart';
import '../../../common/widgets/shimmer/shimmer_widget.dart';
import '../../../utils/constants/sizes.dart';

class ProvidersGridShimmer extends StatelessWidget {
  const ProvidersGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: Sizes.spaceBtwItems),
        GridLayout(
          mainAxisExtent: screenWidth * 0.20,
          crossAxisCount: 4,
          itemCount: 8,
          itemBuilder: (_, _) {
            return ShimmerWidget(
          height: screenWidth * 0.20,
          width: screenWidth * 0.20,
              radius: Sizes.cardRadiusLg,
            );
          },
        ),
      ],
    );
  }
}
