import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';

class ProfileDetails extends ConsumerStatefulWidget {
  final Widget profileImage;
  final String fullname;
  final String username;
  const ProfileDetails({
    super.key,
    required this.profileImage,
    required this.fullname,
    required this.username,
  });

  @override
  ConsumerState<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends ConsumerState<ProfileDetails> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.10,
          width: MediaQuery.of(context).size.height * 0.10,
          decoration: BoxDecoration(shape: BoxShape.circle,
          border: Border.all(color: CustomColors.alternate, width: 4)),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: widget.profileImage,
            ),
          ),
        ),
        const SizedBox(width: Sizes.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: screenWidth * 0.50,
              child: Text(
                widget.fullname,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall!.copyWith(color: Colors.white,
                overflow: TextOverflow.ellipsis),
              ),
            ),
            Text(
              '@${widget.username}',
              style: Theme.of(
                context,
              ).textTheme.labelMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfileDetailsDummy extends StatelessWidget {
  const ProfileDetailsDummy({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.10,
          width: MediaQuery.of(context).size.height * 0.10,
          decoration: BoxDecoration(shape: BoxShape.circle,
          border: Border.all(color: CustomColors.alternate, width: 2)),
          child: Center(
            child: Icon(
              Iconsax.user,
              size: MediaQuery.of(context).size.height * 0.07,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: Sizes.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: Colors.white),
            ),
            Text(
              '',
              style: Theme.of(
                context,
              ).textTheme.labelMedium!.copyWith(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
