import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/constants/custom_colors.dart';

class ShimmerWidget extends StatelessWidget {
  final double? width; 
  final double? radius;
  final double? height;
  final Color? color;
  const ShimmerWidget({
      super.key,
      this.width,
      this.height,
      this.radius,
      this.color});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return Shimmer.fromColors(
      baseColor: dark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: dark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? (dark ? CustomColors.grey : CustomColors.darkGrey),
          borderRadius: BorderRadius.circular(radius!),
        ),
      )
    );
  }
}