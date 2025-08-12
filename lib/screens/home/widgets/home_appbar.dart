import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../nav_menu.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeAppBar extends ConsumerStatefulWidget {
  final int unreadCount;
  const HomeAppBar({super.key, required this.unreadCount});

  @override
  ConsumerState<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends ConsumerState<HomeAppBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    double screenHeight = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //avatar and greetings
        Row(
          children: [
            GestureDetector(
              onTap: () {
                ref.read(selectedIndexProvider.notifier).state = 3;

                HelperFunction.navigateScreen(context, NavigationMenu());
              },
              child: Container(
                height: screenHeight * 0.05,
                width: screenHeight * 0.05,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: CustomColors.darkGrey,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      Images.avatarM1,
                      fit: BoxFit.contain,
                      height: screenHeight * 0.05,
                      width: screenHeight * 0.05,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: Sizes.sm),
            Text('Hi, Ahmad', style: Theme.of(context).textTheme.labelLarge),
          ],
        ),

        //notifications
        GestureDetector(
          onTap: () {},
          child: RoundedContainer(
            padding: const EdgeInsets.all(Sizes.sm),
            radius: 100,
            backgroundColor:
                dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
            child: SizedBox(
              height: 24,
              width: 24,
              child:
                  widget.unreadCount > 0
                      ? badges.Badge(
                        position: badges.BadgePosition.topEnd(top: -6, end: -4),
                        badgeContent: Text(
                          widget.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        child: Icon(
                          Icons.notifications,
                          size: Sizes.iconMd,
                          color: dark ? Colors.white : Colors.black,
                        ),
                      )
                      : Icon(
                        Icons.notifications,
                        size: Sizes.iconMd,
                        color: dark ? Colors.white : Colors.black,
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
