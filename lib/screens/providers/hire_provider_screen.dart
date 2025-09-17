import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../utils/helpers/capitalize_text.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/custom_shapes/containers/button_container.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../common/widgets/pop_up/location_picker_dialog.dart';
import '../../common/widgets/texts/title_and_description.dart';
import '../../controllers/services/user_id_controller.dart';
import '../../controllers/transactions/wallet_controller.dart';
import '../../controllers/user/user_controller.dart';
import '../../models/providers/providers_category_model.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import '../transactions/validate_pin_screen.dart';
import 'components/hire_validator.dart';

class HireProvider extends ConsumerStatefulWidget {
  final ProvidersCategoryModel profile;
  const HireProvider({super.key, required this.profile});

  @override
  ConsumerState<HireProvider> createState() => _HireProviderState();
}

class _HireProviderState extends ConsumerState<HireProvider> {
  UserIdService userIdService = UserIdService();
  bool _isSubmitting = false;
  int _count = 0;
  String? _selectedService;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(walletProvider.notifier).fetchBalance());
    Future.microtask(() {
      ref.read(userProvider.notifier).fetchUserDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final dark = HelperFunction.isDarkMode(context);
    double totalPay = widget.profile.hourlyRate * _count;

    return Scaffold(
      appBar: TAppBar(
        title: Text('Hire', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      bottomNavigationBar: ButtonContainer(
        text: 'Proceed',
        onPressed:
            _isSubmitting
                ? null
                : () async {
                  setState(() => _isSubmitting = true);

                  final isPinValid = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const ValidatePinDialog(),
                  );

                  if (isPinValid == true) {
                    await HireValidator.hireProvider(
                      context: context,
                      ref: ref,
                      selectedService: _selectedService,
                      count: _count,
                      selectedLocation: _selectedLocation,
                      totalPay: totalPay,
                      providerId: widget.profile.userId,
                      providerName:
                          '${widget.profile.firstname.capitalizeEachWord()} ${widget.profile.lastname.capitalizeEachWord()}',
                      providerImage: widget.profile.profileImage,
                      onSuccess: () {
                        CustomSnackbar.show(
                          title: 'Success',
                          message:
                              'Job request has been sent to ${widget.profile.firstname} ${widget.profile.lastname}',
                          icon: Icons.check_circle,
                          backgroundColor: CustomColors.success,
                          context: context,
                        );
                        Navigator.pop(context);
                      },
                    );

                    if (mounted) setState(() => _isSubmitting = false);
                  } else {
                    CustomSnackbar.show(
                      context: context,
                      title: 'Invalid PIN',
                      message: 'Transaction failed',
                      icon: Icons.error_outline,
                      backgroundColor: CustomColors.error,
                    );
                  }
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
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.copyWith(
                        color: CustomColors.success,
                        fontFamily: 'JosefinSans',
                      ),
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

                  // Services
                  HomeListView(
                    sizedBoxHeight: screenHeight * 0.06,
                    scrollDirection: Axis.horizontal,
                    seperatorBuilder:
                        (context, index) => const Padding(
                          padding: EdgeInsets.all(Sizes.xs),
                          child: VerticalDivider(color: CustomColors.primary),
                        ),
                    itemCount: widget.profile.skills.length,
                    itemBuilder: (context, index) {
                      final skill = widget.profile.skills[index];
                      final isSelected = _selectedService == skill;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedService = skill);
                        },
                        child: RoundedContainer(
                          height: screenHeight * 0.08,
                          padding: const EdgeInsets.all(Sizes.sm),
                          radius: Sizes.cardRadiusMd,
                          backgroundColor:
                              isSelected
                                  ? CustomColors.primary
                                  : (dark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1)),
                          child: Center(
                            child: Text(
                              skill,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall!.copyWith(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : (dark ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: Sizes.spaceBtwSections),

                  const TitleAndDescription(
                    textAlign: TextAlign.left,
                    title: 'Enter Hours',
                    description:
                        'Please tap the counter to adjust the number of hours you would like to hire',
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections),

                  // Hours Counter
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
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$_count',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
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
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Select Location Section
                  const SizedBox(height: Sizes.spaceBtwSections),
                  const TitleAndDescription(
                    textAlign: TextAlign.left,
                    title: 'Service Location',
                    description:
                        'Please select where you want the service to be provided',
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.location_on, color: Colors.white),
                      label: Text(
                        _selectedLocation == null
                            ? "Select Location"
                            // : "Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}"
                            : "Change Location",
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall!.copyWith(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedLocation == null
                                ? CustomColors.primary
                                : CustomColors.success,
                        padding: const EdgeInsets.all(Sizes.sm),
                      ),
                      onPressed: () async {
                        final result = await showDialog<LatLng>(
                          context: context,
                          builder: (_) => const LocationPickerDialog(),
                        );
                        if (result != null) {
                          setState(() {
                            _selectedLocation = result;
                          });
                        }
                      },
                    ),
                  ),

                  // Total Pay
                  const SizedBox(height: Sizes.spaceBtwSections),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total: ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '\$${totalPay.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: CustomColors.success,
                          fontFamily: 'JosefinSans',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),
                ],
              ),
            ),
          ),

          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 4.0,
                  backgroundColor: dark ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
