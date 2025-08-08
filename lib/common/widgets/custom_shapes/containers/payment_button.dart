import 'package:flutter/material.dart';
import '../../../../utils/constants/custom_colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_function.dart';

class PaymentButton extends StatelessWidget {
  final String text;
  const PaymentButton({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(Sizes.spaceBtwItems),
        color: dark ? CustomColors.dark : CustomColors.light,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: CustomColors.primary),
              child: Text(text,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: Colors.white))),
        ),
      ),
    );
  }
}
