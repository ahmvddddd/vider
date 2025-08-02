// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/custom_colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_function.dart';
import '../../../../screens/map/map.dart';

class SearchContainer extends StatelessWidget {
  const SearchContainer({
    required this.width,
    super.key,
    this.text, 
    this.icon = Iconsax.search_normal, 
    this.showBackground = true, 
    this.showBorder = true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
  });

  final double width;
  final String? text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: showBackground ? dark ? CustomColors.dark : CustomColors.light : Colors.transparent,
            borderRadius: BorderRadius.circular(Sizes.cardRadiusLg),
            border: showBorder ? Border.all(color: CustomColors.grey): null,
          ),
          child: 
          Center(
            child: TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: CustomColors.darkerGrey, size:  Sizes.iconSm,),
                suffixIcon: IconButton(
                      onPressed: () => HelperFunction.navigateScreen(context, MapScreen()),
                      icon: Icon(Icons.location_on, size: Sizes.iconM, color: Colors.red,),
                    ),
                border: InputBorder.none,
                hintText: text,
                hintStyle:  Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ) 
        ),
      ),
    );
  }
}






