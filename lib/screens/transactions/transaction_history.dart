import 'package:flutter/material.dart';
import '../../common/styles/shadows.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/helpers/helper_function.dart';
import '../../controllers/transactions/fetch_transactions_controller.dart';
import '../../utils/helpers/responsive_size.dart';
import '../jobs/components/jobs_screen_shimmer.dart';

class TransactionHistory extends ConsumerStatefulWidget {
  const TransactionHistory({super.key});

  @override
  ConsumerState<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends ConsumerState<TransactionHistory> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.watch(transactionProvider(null));
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionProvider(null));
    final dark = HelperFunction.isDarkMode(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double xSAvatarHeight = screenHeight * 0.055;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Transaction History',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(responsiveSize(context,Sizes.spaceBtwItems)),
          child: transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return Center(
                  child: Text(
                    'No Transactions Found',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
              return Column(
                children: [
                  HomeListView(
                    seperatorBuilder:
                        (context, index) =>
                            SizedBox(height: responsiveSize(context, Sizes.spaceBtwItems)),
                    scrollDirection: Axis.vertical,
                    scrollPhysics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      String amount = NumberFormat(
                        '#,##0.00',
                      ).format(transaction.amount);
                      String date = DateFormat(
                        'dd/MM/yy HH:mm:ss',
                      ).format(transaction.date);
                      IconData transactionIcon;
      
                      switch (transaction.transactionType.toLowerCase()) {
                        case 'debit':
                          transactionIcon = Icons.arrow_upward;
                          break;
                        case 'credit':
                          transactionIcon = Icons.arrow_downward;
                          break;
                        default:
                          transactionIcon = Icons.receipt;
                      }
      
                      Color iconColor;
      
                      switch (transaction.transactionType.toLowerCase()) {
                        case 'debit':
                          iconColor = Colors.red;
                          break;
                        case 'credit':
                          iconColor = Colors.green;
                          break;
                        default:
                          iconColor = CustomColors.primary;
                      }
                      return RoundedContainer(
                        padding: EdgeInsets.all(responsiveSize(context, Sizes.sm)),
                        backgroundColor:
                            dark
                                ? CustomColors.white.withValues(alpha: 0.1)
                                : CustomColors.black.withValues(alpha: 0.1),
                        boxShadow: [ShadowStyle.horizontalProductShadow],
                        width: screenWidth * 0.90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //transaction icon
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: xSAvatarHeight * 0.80,
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            dark
                                                ? Colors.black
                                                : Colors.white,
                                      ),
                                      child: Icon(
                                        transactionIcon,
                                        size: Sizes.iconMd,
                                        color: iconColor,
                                      ),
                                    ),
                                    SizedBox(width: responsiveSize(context, Sizes.sm)),
                                    Text(
                                      transaction.transactionType,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                      softWrap: true,
                                    ),
                                  ],
                                ),
      
                                Text(
                                  '\$$amount',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium!.copyWith(
                                    fontFamily: 'JosefinSans',
                                    color: iconColor,
                                  ),
                                ),
                              ],
                            ),
      
                            //service and rating
                            SizedBox(height: responsiveSize(context, Sizes.xs)),
                            Text(
                              transaction.description,
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall!.copyWith(
                                color:
                                    dark
                                        ? CustomColors.white
                                        : CustomColors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                              softWrap: true,
                              maxLines: 3,
                            ),
      
                            //description
                            Padding(
                              padding: EdgeInsets.all(responsiveSize(context, Sizes.xs)),
                              child: Divider(color: CustomColors.primary),
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ref Name:',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                Text(
                                  transaction.refName,
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                            SizedBox(height: responsiveSize(context, Sizes.xs)),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Date:',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                Text(
                                  date,
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                            SizedBox(height: responsiveSize(context, Sizes.md)),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Transaction ID:',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                SizedBox(
                                  width: screenWidth * 0.60,
                                  child: SelectableText(
                                    transaction.transactionId,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall!.copyWith(
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
            loading:
                () => SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: const JobsScreenShimmer(),
                ),
            error: (error, stack) {
              return Center(
              child: Padding(
                padding: EdgeInsets.all(responsiveSize(context, Sizes.spaceBtwItems)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // 👈 center horizontally
                  children: [
                    Text(
                      error.toString().replaceAll('Exception:', '').trim(),
                      style: Theme.of(context).textTheme.bodySmall,
                      softWrap: true,
                      textAlign: TextAlign.center, // 👈 center text content
                    ),
                    SizedBox(height: responsiveSize(context, Sizes.spaceBtwItems)),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: CustomColors.primary,
                        padding: EdgeInsets.all(responsiveSize(context, Sizes.sm)),
                      ),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        ref.refresh(transactionProvider(null).future);
                      },
                    ),
                  ],
                ),
              ),
            );
            },
          ),
        ),
      ),
    );
  }
}
