// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';

class TAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TAppBar({
    super.key,
    this.title,
    this.showBackArrow = false,
    this.leadingIcon,
    this.actions,
    this.leadingOnPressed,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return SafeArea( // ✅ Ensure it respects the status bar
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.sm),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent, // Optional: customize
          leading: showBackArrow
              ? IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Iconsax.arrow_left,
                    color: dark ? CustomColors.white : CustomColors.dark,
                  ),
                )
              : leadingIcon != null
                  ? IconButton(
                      onPressed: leadingOnPressed,
                      icon: Icon(
                        leadingIcon,
                        color: dark ? CustomColors.white : CustomColors.dark,
                      ),
                    )
                  : null,
          title: title,
          actions: actions,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
