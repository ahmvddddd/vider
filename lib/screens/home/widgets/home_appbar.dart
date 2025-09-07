import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:vider/utils/helpers/capitalize_text.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../controllers/user/user_controller.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../notifications/notifications.dart';
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
    final userProfile = ref.watch(userProvider);
    final dark = HelperFunction.isDarkMode(context);
    double screenHeight = MediaQuery.of(context).size.height;
    return userProfile.when(
      data: (user) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //avatar and greetings
            Row(
              children: [
                RoundedContainer(
                  width: screenHeight * 0.050,
                  height: screenHeight * 0.050,
                  radius: 100,
                  backgroundColor:
                      dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(Sizes.xs),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        user.profileImage,
                        fit: BoxFit.cover,
                        height: screenHeight * 0.045,
                        width: screenHeight * 0.045,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: Sizes.sm),
                Text(
                  'Hi, ${user.firstname.capitalizeEachWord()}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),

            //notifications
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
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
                            position: badges.BadgePosition.topEnd(
                              top: -6,
                              end: -4,
                            ),
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
      },
      loading:
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //avatar and greetings
              RoundedContainer(
                width: screenHeight * 0.045,
                height: screenHeight * 0.045,
                radius: 100,
                backgroundColor:
                    dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(2),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Icon(Icons.person),
                  ),
                ),
              ),

              //notifications
              RoundedContainer(
                padding: const EdgeInsets.all(Sizes.sm),
                radius: 100,
                backgroundColor:
                    dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.notifications,
                  size: Sizes.iconMd,
                  color: Colors.white,
                ),
              ),
            ],
          ),

      error:
          (err, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //avatar and greetings
              RoundedContainer(
                width: screenHeight * 0.045,
                height: screenHeight * 0.045,
                radius: 100,
                backgroundColor:
                    dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(2),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Icon(Icons.person),
                  ),
                ),
              ),

              //notifications
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const NotificationsScreen(),
                  //   ),
                  // );
                },
                child: RoundedContainer(
                  padding: const EdgeInsets.all(Sizes.sm),
                  radius: 100,
                  backgroundColor:
                      dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.notifications,
                    size: Sizes.iconMd,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
