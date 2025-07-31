import 'package:flutter/material.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/helpers/helper_function.dart';

class TTabBar extends StatelessWidget implements PreferredSizeWidget{
  //If you want to add background color to tabs you have to wrap them in material widget
  // To do that we need [PreferredSized] widget and that's why we are creating a custom class.
  // [PreferredSizeWidget]
  const TTabBar({super.key, required this.tabs});

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return Material(
      color: dark ? CustomColors.black : CustomColors.white,
      child: TabBar(
        tabs: tabs,
        isScrollable: true,
        indicatorColor: CustomColors.primary,
        labelColor: dark ? CustomColors.white : CustomColors.primary,
        unselectedLabelColor: CustomColors.darkGrey,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}