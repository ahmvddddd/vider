import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/custom_shapes/containers/button_container.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../common/widgets/pop_up/location_picker_dialog.dart';
import '../../common/widgets/texts/title_and_description.dart';
import '../../controllers/jobs/job_request_controller.dart';
import '../../controllers/notifications/add_notification_controller.dart';
import '../../controllers/services/user_id_controller.dart';
import '../../controllers/user/user_controller.dart';
import '../../models/notification/add_notification_model.dart';
import '../../models/providers/providers_category_model.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';

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
  LatLng? _selectedLocation; // <-- Store picked location

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final dark = HelperFunction.isDarkMode(context);
    final userState = ref.watch(userProvider);

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
                  if (_selectedLocation == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a location")),
                    );
                    return;
                  }

                  userState.when(
                    data: (user) async {
                      setState(() => _isSubmitting = true);
                      final vvid = await ref.read(jobRequestProvider.future);

                      final jobDetails = JobDetails(
                        employerId: user.userId,
                        providerId: widget.profile.userId,
                        employerImage: user.profileImage,
                        providerImage: widget.profile.profileImage,
                        employerName: user.firstname,
                        providerName: widget.profile.firstname,
                        jobTitle: _selectedService!,
                        pay: totalPay,
                        duration: _count,
                        startTime: DateTime.now(),
                        latitude: _selectedLocation!.latitude,
                        longitude: _selectedLocation!.longitude,
                        vvid: vvid!
                      );

                      final notification = AddNotificationModel(
                        type: "job_request",
                        title: "New Job Request",
                        message:
                            "${user.firstname} ${user.lastname} wants to hire you for $_selectedService for a duration of $_count hours.",
                        recipientId: widget.profile.userId,
                        jobDetails: jobDetails,
                      );

                      try {
                        await ref.read(
                          addNotificationProvider(notification).future,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Job created successfully"),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text("Error: $e")));
                        }
                      } finally {
                        if (mounted) setState(() => _isSubmitting = false);
                      }
                    },
                    loading: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Loading employer details"),
                        ),
                      );
                    },
                    error: (err, _) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $err")));
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
                          width: screenWidth * 0.25,
                          height: screenHeight * 0.06,
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
