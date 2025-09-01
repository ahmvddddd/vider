import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/widgets/image/full_screen_image_view.dart';
import '../../../utils/constants/sizes.dart';

class ProfileDetails extends ConsumerStatefulWidget {
  final AsyncValue userProfile;
  const ProfileDetails({
    super.key,
    required this.userProfile,
  });

  @override
  ConsumerState<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends ConsumerState<ProfileDetails> {
  @override
  Widget build(BuildContext context) {
    return widget.userProfile.when(
      data: (user) {
        return Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImageView(
                      images: [user.profileImage], // uses model field
                      initialIndex: 0,
                    ),
                  ),
                );
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.10,
                width: MediaQuery.of(context).size.height * 0.10,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      user.profileImage, // <-- fixed property
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.10,
                      width: MediaQuery.of(context).size.height * 0.10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Sizes.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstname} ${user.lastname}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.white),
                ),
                Text(
                  user.username,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => Row(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.10,
            width: MediaQuery.of(context).size.height * 0.10,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Icon(
                  Iconsax.user,
                  size: MediaQuery.of(context).size.height * 0.10,
                ),
              ),
            ),
          ),
          const SizedBox(width: Sizes.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(''),
              Text(''),
            ],
          ),
        ],
      ),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
