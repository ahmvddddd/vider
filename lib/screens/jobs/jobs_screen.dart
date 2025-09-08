import 'package:iconsax/iconsax.dart';
import '../../common/styles/shadows.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../controllers/jobs/jobs_controller.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'components/jobs_screen_shimmer.dart';
import 'components/rating_dialog.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsPageState();
}

class _JobsPageState extends ConsumerState<JobsScreen> {
  Timer? _timer;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() => ref.watch(jobsFutureProvider));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String getJobStatus(Map<String, dynamic> job) {
    DateTime startTime = DateTime.parse(job['startTime']);
    double durationHours = job['duration'].toDouble();
    DateTime endTime = startTime.add(Duration(hours: durationHours.toInt()));

    Duration timeLeft = endTime.difference(DateTime.now());

    if (timeLeft.isNegative) {
      return "Executed";
    } else {
      int hours = timeLeft.inHours;
      int minutes = timeLeft.inMinutes.remainder(60);
      int seconds = timeLeft.inSeconds.remainder(60);

      return "Time left: ${hours}h ${minutes}m ${seconds}s";
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsyncValue = ref.watch(jobsFutureProvider);
    final dark = HelperFunction.isDarkMode(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double xSAvatarHeight = screenHeight * 0.055;
    return Scaffold(
      appBar: TAppBar(
        title: Text('Jobs', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => isRefreshing = true);
          await Future.wait([Future(() => ref.refresh(jobsFutureProvider))]);
          setState(() => isRefreshing = false);
        },
        child: jobsAsyncValue.when(
          data: (jobs) {
            if (jobs.isEmpty) {
              return Center(
                child: Text(
                  'No jobs yet',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Sizes.spaceBtwItems),
                child: Column(
                  children: [
                    if (isRefreshing) Column(children: [JobsScreenShimmer()]),

                    const SizedBox(height: Sizes.spaceBtwItems),
                    HomeListView(
                      scrollDirection: Axis.vertical,
                      itemCount: jobs.length,
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                      seperatorBuilder:
                          (context, index) =>
                              const SizedBox(height: Sizes.spaceBtwItems),
                      itemBuilder: (context, index) {
                        var job = jobs[index];
                        String date = DateFormat(
                          'dd/MM/yy HH:mm:ss',
                        ).format(DateTime.parse(job['startTime']));

                        return RoundedContainer(
                          padding: const EdgeInsets.all(Sizes.sm),
                          backgroundColor:
                              dark
                                  ? CustomColors.white.withValues(alpha: 0.1)
                                  : CustomColors.black.withValues(alpha: 0.1),
                          boxShadow: [ShadowStyle.horizontalProductShadow],
                          width: screenWidth * 0.90,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: xSAvatarHeight * 0.80,
                                    width:
                                        xSAvatarHeight *
                                        0.80, // Ensure it's a square
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color:
                                          dark
                                              ? CustomColors.black
                                              : CustomColors.white,
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        job['providerImage'] ?? Images.avatarM1,
                                        height: xSAvatarHeight * 0.80,
                                        width: xSAvatarHeight * 0.80,
                                        fit:
                                            BoxFit
                                                .cover, // fill the circle properly
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: Sizes.sm),
                                  Row(
                                    children: [
                                      const SizedBox(width: Sizes.sm),
                                      Text(
                                        job['providerName'] ?? 'no name',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                        softWrap: true,
                                      ),
                                      const SizedBox(width: Sizes.xs),
                                      const Icon(
                                        Iconsax.verify,
                                        size: Sizes.iconSm,
                                        color: Colors.amber,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              //description
                              const Padding(
                                padding: EdgeInsets.all(Sizes.xs),
                                child: Divider(color: CustomColors.primary),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Duration',
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Text(
                                    '${job['duration']} hrs',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(color: CustomColors.success),
                                  ),
                                ],
                              ),

                              const SizedBox(height: Sizes.xs),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Status',
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        getJobStatus(job),
                                        style: TextStyle(
                                          color:
                                              getJobStatus(job) == "Executed"
                                                  ? CustomColors.success
                                                  : CustomColors.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (getJobStatus(job) == "Executed")
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                CustomColors.primary,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (_) => RatingDialog(
                                                    profileId:
                                                        job['providerId'],
                                                  ),
                                            );
                                          },
                                          child: const Text("Rate"),
                                        ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: Sizes.xs),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    job['jobTitle'],
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Text(
                                    '\$${NumberFormat('#,##0.00').format(job['pay'])}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(fontFamily: 'JosefinSans'),
                                  ),
                                ],
                              ),

                              const SizedBox(height: Sizes.sm),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    date,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const JobsScreenShimmer(),
          error:
              (e, _) => Padding(
                padding: const EdgeInsets.all(Sizes.spaceBtwItems),
                child: Column(
                  children: [
                    SizedBox(height: 200),
                    Text(
                      e.toString().replaceAll('Exception:', '').trim(),
                      style: Theme.of(context).textTheme.bodySmall,
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: CustomColors.primary,
                        padding: const EdgeInsets.all(Sizes.sm),
                      ),
                      icon: Icon(Icons.refresh, color: Colors.white),
                      onPressed: () async {
                        setState(() {
                          isRefreshing = true;
                        });
                        ref.refresh(jobsFutureProvider.future);
                        setState(() {
                          isRefreshing = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
