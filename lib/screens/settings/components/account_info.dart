import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/helpers/responsive_size.dart';
import '../../transactions/deposit_screen.dart';

class AccountInfo extends ConsumerStatefulWidget {
  final AsyncValue walletController;
  const AccountInfo({super.key, required this.walletController});

  @override
  ConsumerState<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends ConsumerState<AccountInfo> {
  @override
  Widget build(BuildContext context) {
    return widget.walletController.when(
      data: (wallet) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${NumberFormat('#,##0.00').format(wallet.usdcBalance)}',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium!.copyWith(color: Colors.white),
                ),
                Text(
                  'Balance',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium!.copyWith(color: Colors.white),
                ),
              ],
            ),

            SizedBox(height: responsiveSize(context, Sizes.sm)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: responsiveSize(context, Sizes.sm)),

                GestureDetector(
                  onTap: () {
                    HelperFunction.navigateScreen(
                      context,
                      DepositScreen(cryptoAddress: wallet.cryptoAddress),
                    );
                  },
                  child: RoundedContainer(
                    width: MediaQuery.of(context).size.width * 0.43,
                    height: MediaQuery.of(context).size.height * 0.06,
                    radius: Sizes.cardRadiusLg,
                    padding: EdgeInsets.all(responsiveSize(context, Sizes.sm)),
                    backgroundColor: Colors.green,
                    child: Center(
                      child: Text(
                        'Deposit',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: responsiveSize(context, Sizes.sm)),
          ],
        );
      },
      loading:
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    '\$0.00',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium!.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Balance',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium!.copyWith(color: Colors.white),
                  ),
                ],
              ),

              SizedBox(height: responsiveSize(context, Sizes.sm)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: responsiveSize(context, Sizes.sm)),

                  GestureDetector(
                    onTap: () {},
                    child: RoundedContainer(
                      width: MediaQuery.of(context).size.width * 0.43,
                      height: MediaQuery.of(context).size.height * 0.06,
                      radius: Sizes.cardRadiusLg,
                      padding: EdgeInsets.all(responsiveSize(context, Sizes.sm)),
                      backgroundColor: Colors.grey,
                      child: Center(
                        child: Text(
                          'Deposit',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: responsiveSize(context, Sizes.sm)),
            ],
          ),
      error: (err, st) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    '\$0.00',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium!.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Balance',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium!.copyWith(color: Colors.white),
                  ),
                ],
              ),

              SizedBox(height: responsiveSize(context, Sizes.sm)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(width: responsiveSize(context, Sizes.sm)),

                  GestureDetector(
                    onTap: () {},
                    child: RoundedContainer(
                      width: MediaQuery.of(context).size.width * 0.43,
                      height: MediaQuery.of(context).size.height * 0.06,
                      radius: Sizes.cardRadiusLg,
                      padding: EdgeInsets.all(responsiveSize(context, Sizes.sm)),
                      backgroundColor: Colors.grey,
                      child: Center(
                        child: Text(
                          'Deposit',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: responsiveSize(context, Sizes.sm)),
            ],
          ),
    );
  }
}
