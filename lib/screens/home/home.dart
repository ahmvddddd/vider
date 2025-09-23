import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/helpers/responsive_size.dart';
import '../../controllers/notifications/unread_notifications_controller.dart';
import '../../controllers/providers/providers_category_controller.dart';
import '../../controllers/services/firebase_service.dart';
import '../../controllers/services/notification_badge_service.dart';
import '../../controllers/providers/provider_profiles_controller.dart';
import '../../repository/user/get_matching_location_storage.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import '../providers/widgets/providers_grid.dart';
import 'widgets/home_appbar.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/provider_profiles_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool isRefreshing = false;
  NotificationBadgeService? _badgeService;
  Future<void> refreshProvider() async {
    setState(() {
      isRefreshing = true;
    });
    setState(() {
      isRefreshing = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_badgeService == null) {
      final container = ProviderScope.containerOf(context);
      _badgeService = NotificationBadgeService(container: container);
      _badgeService!.init();

      FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        debugPrint('🟨 getInitialMessage: App was opened by a notification: ${message.messageId}');
        await _badgeService!.handleIncomingMessage(message);
      }
    });
    }

    saveFcmTokenToBackend();
  }

  

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final dark = HelperFunction.isDarkMode(context);
    final unreadCount = ref.watch(unreadNotificationsProvider);
    final isSearchFocused = ref.watch(searchFocusProvider); 

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                expandedHeight: screenHeight * 0.09,
                backgroundColor: dark ? Colors.black : Colors.white,
                flexibleSpace: Padding(
                  padding: EdgeInsets.all(responsiveSize(context, Sizes.sm)),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [HomeAppBar(unreadCount: unreadCount)],
                  ),
                ),
              ),
            ];
          },
          body: RefreshIndicator(onRefresh: () async {
            ref.refresh(categoriesProvider);
            await MatchingLocationStorage.clearLocation();
            ref.refresh(providerProfilesController);
          },
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(responsiveSize(context, Sizes.spaceBtwItems)),
                child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: responsiveSize(context, Sizes.spaceBtwSections)),
                          HomeSearchBar(),
                          
                          if (!isSearchFocused) ...[
                          SizedBox(height: responsiveSize(context, Sizes.spaceBtwItems)),
                          ProvidersGrid(),
                          SizedBox(height: responsiveSize(context, Sizes.spaceBtwSections)),
                          
                          ProviderProfilesWidget(),]
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
