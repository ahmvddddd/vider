import 'package:flutter/widgets.dart';
import '../../../common/widgets/layouts/listview.dart';
import '../../../common/widgets/shimmer/shimmer_widget.dart';
import '../../../utils/constants/sizes.dart';

class ProviderProfilesShimmer extends StatelessWidget {
  const ProviderProfilesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
            return ShimmerWidget(
              height: screenHeight * 0.28,
              width: screenWidth * 0.48,
              radius: Sizes.cardRadiusLg,
            );
          },
        ),
      ],
    );
  }
}
