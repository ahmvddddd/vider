import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';

class MessagePreview extends StatelessWidget {
  final String avatar;
  final String sender;
  final String messageText;
  final Color backgroundColor;
  const MessagePreview(
      {super.key,
      required this.avatar,
      required this.sender,
      required this.messageText,
      this.backgroundColor = Colors.transparent
      });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double xSAvatarHeight = screenHeight * 0.055;
    final dark = HelperFunction.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.all(Sizes.spaceBtwItems),
      child: RoundedContainer(
        padding: const EdgeInsets.all(Sizes.sm),
        radius: Sizes.borderRadiusMd,
        backgroundColor: Colors.transparent,
        width: screenWidth * 0.90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            
            Row(
              children: [
                //image
                Container(
                  height: xSAvatarHeight,
                  width: xSAvatarHeight,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dark ? CustomColors.black : CustomColors.white),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        avatar,
                        height: xSAvatarHeight * 0.95,
                        width: xSAvatarHeight * 0.95,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                //name and service
                const SizedBox(
                  width: Sizes.sm,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          sender,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        const Icon(
                          Iconsax.verify,
                          color: Colors.amber,
                          size: Sizes.iconSm,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: Sizes.xs,
                    ),
                    SizedBox(
                      width: screenWidth * 0.55,
                      child: Text(
                        messageText,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
