import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/custom_colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_function.dart';


class SearchContainer extends StatelessWidget {
  const SearchContainer({
    this.controller,
    required this.width,
    super.key,
    this.text,
    this.icon = Iconsax.search_normal,
    this.showBackground = true,
    this.showBorder = true,
    this.onTap,
    this.focusNode,
    this.onChanged,
    this.onSubmitted, // for Enter/Done
    this.onEditingComplete, // for focus loss or submit
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
    this.suffixIcon
  });

  final TextEditingController? controller;
  final double width;
  final String? text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry padding;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted; // returns the text
  final VoidCallback? onEditingComplete; // no text, just action
  final Widget? suffixIcon;

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
            color:
                showBackground
                    ? (dark ? CustomColors.dark : CustomColors.light)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: showBorder ? Border.all(color: CustomColors.grey) : null,
          ),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: TextFormField(
                controller: controller,
                onChanged: onChanged,
                focusNode: focusNode,
                onFieldSubmitted: onSubmitted, // ✅ handles Enter/Done
                onEditingComplete: onEditingComplete, // ✅ handles focus loss
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    icon,
                    color: CustomColors.darkerGrey,
                    size: Sizes.iconSm,
                  ),
                  suffixIcon: suffixIcon,
                  border: InputBorder.none,
                  hintText: text,
                  hintStyle: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
