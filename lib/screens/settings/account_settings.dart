import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/utils/constants/image_strings.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/texts/section_heading.dart';
import '../../controllers/auth/sign_out_controller.dart';
import '../../controllers/transactions/wallet_controller.dart';
import '../../repository/user/user_local_storage.dart';
import '../../../controllers/user/user_controller.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import 'components/account_info.dart';
import 'components/general_account_settings.dart';
import 'widgets/profile_details.dart';

class AccountSettings extends ConsumerStatefulWidget {
  const AccountSettings({super.key});

  @override
  ConsumerState<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends ConsumerState<AccountSettings> {
  @override
  void initState() {
    super.initState();
    // Check local storage, and only fetch from API if not found
    Future.microtask(() async {
      Future.microtask(() => ref.read(walletProvider.notifier).fetchBalance());
      final localUser = await UserLocalStorage.getUserProfile();
      if (localUser == null) {
        ref.read(userProvider.notifier).fetchUserDetails();
      } else {
        ref.read(userProvider.notifier).state = AsyncData(localUser);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProvider);
    final walletController = ref.watch(walletProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    final signoutController = ref.read(signoutControllerProvider.notifier);
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Account',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.spaceBtwItems),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(Sizes.sm),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
                  image: DecorationImage(
                    image: AssetImage(Images.bg2),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ProfileDetails(userProfile: userProfile),

                        IconButton(
                          onPressed: () async {
                            await ref
                                .read(userProvider.notifier)
                                .fetchUserDetails();
                            await ref
                                .read(walletProvider.notifier)
                                .fetchBalance();
                          },
                          icon: Icon(Icons.refresh, size: Sizes.iconLg, color: Colors.white,),
                        ),
                      ],
                    ),

                    const SizedBox(height: Sizes.spaceBtwItems),
                    AccountInfo(walletController: walletController),
                  ],
                ),
              ),

              const SizedBox(height: Sizes.spaceBtwSections),
              SectionHeading(
                title: 'General Settings',
                showActionButton: false,
              ),
              const SizedBox(height: Sizes.sm),
              GeneralAccountSettings(),

              const SizedBox(height: Sizes.spaceBtwSections),
              SizedBox(
                width: screenWidth * 0.90,
                child: ElevatedButton(
                  onPressed: () {
                    signoutController.signOut(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.primary,
                  ),
                  child: Text(
                    'Signout',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall!.copyWith(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: Sizes.sm),
            ],
          ),
        ),
      ),
    );
  }
}
