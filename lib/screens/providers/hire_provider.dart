import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/custom_shapes/containers/button_container.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../common/widgets/texts/title_and_description.dart';
import '../../controllers/jobs/hire_provider_controller.dart';
import '../../controllers/user/user_controller.dart';
import '../../models/providers/providers_category_model.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';

class HireProvider extends ConsumerStatefulWidget {
  final ProvidersCategoryModel profile;
  const HireProvider({
    super.key,
    required this.profile,
  });

  @override
  ConsumerState<HireProvider> createState() => _HireProviderState();
}

class _HireProviderState extends ConsumerState<HireProvider> {
  int _count = 0;
  String? _selectedService; // Track selected service

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final dark = HelperFunction.isDarkMode(context);
    final userState = ref.watch(userProvider);
    // totalPay = hourlyRate * count
    double totalPay = widget.profile.hourlyRate * _count;

    final jobState = ref.watch(jobControllerProvider);

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Hire',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      bottomNavigationBar: ButtonContainer(
        text: 'Proceed',
        onPressed: jobState.isLoading
            ? null
            : () async {
                if (_selectedService == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a service")),
                  );
                  return;
                }
                if (_count <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter hours")),
                  );
                  return;
                }

                // Make sure user details are loaded
                userState.when(
                  data: (user) async {
                    await ref.read(jobControllerProvider.notifier).addEmployee(
                          employerImage: user.profileImage,
                          providerImage: widget.profile.profileImage,
                          employerId: user.userId,
                          providerId: widget.profile.userId,
                          employerName: user.firstname,
                          providerName: widget.profile.firstname,
                          jobTitle: _selectedService!,
                          pay: totalPay.toInt(),
                          duration: _count,
                        );

                    final state = ref.read(jobControllerProvider);
                    if (mounted && state.hasError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error.toString())),
                      );
                    } else if (mounted && !state.isLoading) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Job created successfully")),
                      );
                      Navigator.pop(context);
                    }
                  },
                  loading: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Loading employer details")),
                    );
                  },
                  error: (err, _) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $err")),
                    );
                  },
                );
              },
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.spaceBtwItems),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '\$${widget.profile.hourlyRate}/hr',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(
                              color: CustomColors.success,
                              fontFamily: 'JosefinSans'),
                    ),
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  const TitleAndDescription(
                    textAlign: TextAlign.left,
                    title: 'Select service',
                    description:
                        'Please select the service you need from the list below',
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  HomeListView(
                    sizedBoxHeight:
                        MediaQuery.of(context).size.height * 0.06,
                    scrollDirection: Axis.horizontal,
                    seperatorBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.all(Sizes.xs),
                      child: VerticalDivider(color: CustomColors.primary),
                    ),
                    itemCount: widget.profile.skills.length,
                    itemBuilder: (context, index) {
                      final skill = widget.profile.skills[index];
                      final isSelected = _selectedService == skill;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedService = skill;
                          });
                        },
                        child: RoundedContainer(
                          width: screenWidth * 0.25,
                          height: screenHeight * 0.06,
                          padding: const EdgeInsets.all(Sizes.sm),
                          radius: Sizes.cardRadiusMd,
                          backgroundColor: isSelected
                              ? CustomColors.primary
                              : (dark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1)),
                          child: Center(
                            child: Text(
                              skill,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : (dark
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  /// --- Cart Counter Section ---
                  const SizedBox(height: Sizes.spaceBtwSections),
                  const TitleAndDescription(
                    textAlign: TextAlign.left,
                    title: 'Enter Hours',
                    description:
                        'Please tap the counter to adjust the number of hours you would like to hire',
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_count > 0) {
                            setState(() {
                              _count--;
                            });
                          }
                        },
                        child: RoundedContainer(
                          height: screenHeight * 0.06,
                          width: screenHeight * 0.06,
                          backgroundColor: CustomColors.primary,
                          radius: 100,
                          padding: const EdgeInsets.all(Sizes.sm),
                          child: Center(
                              child: Icon(
                            Icons.remove,
                            size: Sizes.iconMd,
                            color: Colors.white,
                          )),
                        ),
                      ),

                      // Counter Display
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$_count',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),

                      // Plus Button
                      GestureDetector(
                        onTap: () {
                          if (_count < 5) {
                            setState(() {
                              _count++;
                            });
                          }
                        },
                        child: RoundedContainer(
                          height: screenHeight * 0.06,
                          width: screenHeight * 0.06,
                          backgroundColor: CustomColors.primary,
                          radius: 100,
                          padding: const EdgeInsets.all(Sizes.sm),
                          child: Center(
                              child: Icon(
                            Icons.add,
                            size: Sizes.iconMd,
                            color: Colors.white,
                          )),
                        ),
                      ),
                    ],
                  ),

                  // Total Pay Display
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.spaceBtwItems,
                      vertical: Sizes.spaceBtwSections,
                    ),
                    child: Divider(
                      color: CustomColors.primary,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Total Pay: ',
                      style: Theme.of(context).textTheme.titleLarge,),
                      Text(
                        '\$${totalPay.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(
                                color: CustomColors.success,
                                fontFamily: 'JosefinSans'),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: screenWidth * 0.75,
                      child: Text(
                        'By clicking on proceed you agree to Vider contract rules and regulations. Violating these rules could lead to permanent suspension of your account',
                        style: Theme.of(context).textTheme.labelMedium,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // Show loading overlay
          if (jobState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  color: CustomColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
