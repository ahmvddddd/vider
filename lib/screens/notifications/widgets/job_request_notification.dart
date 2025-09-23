import 'package:flutter/material.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../common/widgets/custom_shapes/divider/custom_divider.dart';
import 'package:intl/intl.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/helpers/responsive_size.dart';

class JobRequestNotification extends StatelessWidget {
  final Color borderColor;
  final String title;
  final String employerImage;
  final String employerName;
  final String jobTitle;
  final double pay;
  final int duration;
  final VoidCallback onDecline;
  final VoidCallback onAccept;
  final DateTime date;

  const JobRequestNotification({
    super.key,
    required this.borderColor,
    required this.title,
    required this.employerImage,
    required this.employerName,
    required this.jobTitle,
    required this.pay,
    required this.duration,
    required this.onDecline,
    required this.onAccept,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return RoundedContainer(
      width: screenWidth * 0.90,
      backgroundColor:
          dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(Sizes.sm),
      showBorder: true,
      borderColor: borderColor,
      radius: Sizes.cardRadiusSm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(overflow: TextOverflow.ellipsis),
            softWrap: true,
            maxLines: 3,
          ),

          SizedBox(height: responsiveSize(context, Sizes.xs)),
          Text(
            DateFormat('dd/MM/yy HH:mm:ss').format(date),
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold),
          ),

          CustomDivider(
            padding: EdgeInsets.all(responsiveSize(context, Sizes.sm)),
          ),
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(employerImage)),

              SizedBox(width: responsiveSize(context, Sizes.sm)),
              Text(employerName, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          SizedBox(height: responsiveSize(context, Sizes.xs)),
          Text(
            jobTitle,
            style: Theme.of(
              context,
            ).textTheme.labelSmall!.copyWith(overflow: TextOverflow.ellipsis),
            softWrap: true,
            maxLines: 3,
          ),
          SizedBox(height: responsiveSize(context, Sizes.xs)),
          Row(
            children: [
              Text('PAY:', style: Theme.of(context).textTheme.labelSmall),
              SizedBox(width: responsiveSize(context, Sizes.md)),
              Text(
                '\$$pay',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: responsiveSize(context, Sizes.xs)),
          Row(
            children: [
              Text('Duration:', style: Theme.of(context).textTheme.labelSmall),
              SizedBox(width: responsiveSize(context, Sizes.md)),
              Text(
                '$duration',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          SizedBox(height: responsiveSize(context, Sizes.md)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, Sizes.spaceBtwItems),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(
                      responsiveSize(context, Sizes.spaceBtwItems),
                    ),
                  ),
                  onPressed: onDecline,
                  child: Text(
                    'Decline',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall!.copyWith(color: Colors.red),
                  ),
                ),

                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(
                      responsiveSize(context, Sizes.spaceBtwItems),
                    ),
                  ),
                  onPressed: onAccept,
                  child: Text(
                    'Accept',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall!.copyWith(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
