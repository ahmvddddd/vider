import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/services/notification_badge_service.dart';
import '../../../nav_menu.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';

class MessageHeader extends ConsumerWidget implements PreferredSizeWidget {
  const MessageHeader({
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
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = HelperFunction.isDarkMode(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Sizes.sm),
      child: AppBar(
        automaticallyImplyLeading: false,
        leading:
            showBackArrow
                ? IconButton(
                  onPressed: () {
                    Future.microtask(() {
                      final container = ProviderScope.containerOf(context);
                      final badgeService = NotificationBadgeService(container: container);
                      badgeService.init();
                    });
                    ref.read(selectedIndexProvider.notifier).state = 2;

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NavigationMenu(),
                      ),
                    );
                  },
                  icon: Icon(
                    Iconsax.arrow_left,
                    color: dark ? CustomColors.white : CustomColors.dark,
                  ),
                )
                : leadingIcon != null
                ? IconButton(
                  onPressed: leadingOnPressed,
                  icon: Icon(leadingIcon),
                )
                : null,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  //Todo: implement preferred Size
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
