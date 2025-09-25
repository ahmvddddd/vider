import 'package:flutter/material.dart';
import '../../../utils/helpers/responsive_size.dart';
import '../components/verify_id_screen.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';

class VerificationPopUpContainer extends StatelessWidget {
  const VerificationPopUpContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return RoundedContainer(
      radius: Sizes.cardRadiusMd,
      width: screenWidth * 0.90,
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.xs, vertical: 1
      ),
      backgroundColor: CustomColors.warning,
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              RoundedContainer(
                radius: 100,
                padding:
                    EdgeInsets.all(
                      responsiveSize(context, Sizes.sm),
                    ),
                backgroundColor: Colors
                    .white
                    .withValues(alpha: 0.3),
                child: Center(
                  child: Icon(
                    Icons.warning,
                    size: responsiveSize(context, Sizes.iconSm),
                    color: Colors.white,
                  ),
                ),
              ),
    
              SizedBox(
                width: responsiveSize(context, Sizes.sm),
              ),
              Text(
                "You are not verified",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(
                      color: Colors.black,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              HelperFunction.navigateScreen(context, VerifyIdScreen());
            },
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(
                    vertical: Sizes.xs,
                    horizontal: Sizes.md,
                  ),
              backgroundColor: Colors.white
                  .withValues(alpha: 0.2),
            ),
            child: Text(
              'Verify Profile',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .copyWith(
                    color: Colors.black,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
