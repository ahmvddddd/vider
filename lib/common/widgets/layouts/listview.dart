import 'package:flutter/material.dart';

class HomeListView extends StatelessWidget {
  final double? sizedBoxHeight;
  final Axis scrollDirection;
  final ScrollPhysics? scrollPhysics;
  final int itemCount;
  final Widget Function(BuildContext, int) seperatorBuilder;
  final Widget? Function(BuildContext, int) itemBuilder;
  
  const HomeListView({
    super.key,
    this.sizedBoxHeight,
    required this.scrollDirection,
    this.scrollPhysics,
    required this.itemCount,
    required this.seperatorBuilder,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: sizedBoxHeight,
        child: ListView.separated(
            separatorBuilder: seperatorBuilder,
            shrinkWrap: true,
            physics: scrollPhysics,
            scrollDirection: scrollDirection,
            itemCount: itemCount,
            itemBuilder: itemBuilder));
  }
}
