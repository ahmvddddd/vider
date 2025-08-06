// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../../../common/widgets/appbar/appbar.dart';
// import '../../../common/widgets/custom_shapes/containers/button_container.dart';
// import '../../../common/widgets/inputs/text_field_container.dart';
// import '../../../common/widgets/pop_up/custom_snackbar.dart';
// import '../../../common/widgets/texts/title_and_description.dart';
// import '../../../controllers/auth/user_bio_controller.dart';
// import '../../../utils/constants/custom_colors.dart';
// import '../../../utils/constants/sizes.dart';
// import '../../../utils/helpers/helper_function.dart';
// import '../../../utils/helpers/token_secure_storage.dart';
// import '../../uploads/upload_profile_image.dart';
// import 'components/profile_validator.dart';
// import 'components/skills_list.dart';

// class UserDetailsScreen extends ConsumerStatefulWidget {
//   const UserDetailsScreen({super.key});

//   @override
//   ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
// }

// class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
//   bool isLoading = false;
//   DateTime? selectedDate;
//   bool _dobSelected = false;
//   String? validationMessage;
//   String? selectedCategory;
//   String? selectedService;
//   List<String> service = [];
//   List<String> skills = [];

//   final TextEditingController bioController = TextEditingController();
//   final TextEditingController skillsController = TextEditingController();
//   final TextEditingController hourlyRateController = TextEditingController();
//   final FlutterSecureStorage storage = FlutterSecureStorage();

//   void _addSkill() {
//     final skill = skillsController.text.trim();
//     if (skill.isNotEmpty) {
//       setState(() {
//         skills.add(skill);
//         skillsController.clear();
//       });
//     }
//   }

//   Future<void> _pickDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2000),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       final now = DateTime.now();
//       final age =
//           now.year -
//           picked.year -
//           ((now.month < picked.month ||
//                   (now.month == picked.month && now.day < picked.day))
//               ? 1
//               : 0);
//       setState(() {
//         selectedDate = picked;
//         _dobSelected = true;
//         validationMessage =
//             age < 18 ? "You must be at least 18 years old" : null;
//       });
//     }
//   }

//   void _updateServices(List<dynamic> occupations, String? category) {
//     if (category != null) {
//       final selected = occupations.firstWhere((o) => o['category'] == category);
//       setState(() {
//         service = List<String>.from(selected['service']);
//         selectedService = null;
//       });
//     }
//   }

//   Future<void> _submitProfile() async {
//     setState(() => isLoading = true);
//     await TokenSecureStorage.checkToken(context: context, ref: ref);

//     final error = ProfileValidator.validate(
//       bio: bioController.text,
//       category: selectedCategory,
//       service: selectedService,
//       skills: skills,
//       ageValidationMessage: validationMessage,
//       dobSelected: _dobSelected,
//       hourlyRate: hourlyRateController.text,
//     );

//     if (error != null) {
//       CustomSnackbar.show(
//         context: context,
//         title: 'Error',
//         message: error,
//         icon: Icons.error_outline,
//         backgroundColor: CustomColors.error,
//       );
//       setState(() => isLoading = false);
//       return;
//     }

//     final result = await ref.read(
//       updateUserBioProvider({
//         'dateOfBirth': selectedDate?.toIso8601String(),
//         'category': selectedCategory,
//         'service': selectedService,
//         'bio': bioController.text.trim(),
//         'skills': skills,
//         'hourlyRate': double.parse(hourlyRateController.text.trim()),
//       }).future,
//     );

//     if (result == true && mounted) {
//       CustomSnackbar.show(
//         context: context,
//         title: 'Success',
//         message: 'Your details were uploaded successfully',
//         icon: Icons.check_circle,
//         backgroundColor: CustomColors.success,
//       );
//       setState(() => isLoading = false);
//       HelperFunction.navigateScreen(context, UploadProfileImageScreen());
//     } else {
//       setState(() => isLoading = false);
//       CustomSnackbar.show(
//         context: context,
//         title: 'An error occurred',
//         message: 'Could not upload your details. Please try again later',
//         icon: Icons.error_outline,
//         backgroundColor: CustomColors.error,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final occupationsAsync = ref.watch(occupationsProvider);
//     final dark = HelperFunction.isDarkMode(context);
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: TAppBar(
//         title: Text(
//           'User Details',
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//         showBackArrow: true,
//       ),
//       bottomNavigationBar: ButtonContainer(
//         text: 'Submit',
//         onPressed: _submitProfile,
//       ),
//       body:
//           isLoading
//               ? Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                   strokeWidth: 4.0,
//                   backgroundColor: dark ? Colors.white : Colors.black,
//                 ),
//               )
//               : occupationsAsync.when(
//                 data:
//                     (occupations) => SingleChildScrollView(
//                       padding: const EdgeInsets.all(Sizes.spaceBtwItems),
//                       child: _buildForm(
//                         context,
//                         occupations,
//                         dark,
//                         screenWidth,
//                       ),
//                     ),
//                 loading: () => const Center(child: CircularProgressIndicator()),
//                 error:
//                     (err, _) => Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'Failed to load categories. Please try again.',
//                           ),
//                           const SizedBox(height: 10),
//                           ElevatedButton(
//                             onPressed: () => ref.refresh(occupationsProvider),
//                             child: const Text('Retry'),
//                           ),
//                         ],
//                       ),
//                     ),
//               ),
//     );
//   }

//   Widget _buildForm(
//     BuildContext context,
//     List<dynamic> occupations,
//     bool dark,
//     double screenWidth,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const TitleAndDescription(
//           textAlign: TextAlign.left,
//           title: 'Date of Birth',
//           description: 'Tap the select button to enter your DOB',
//         ),
//         const SizedBox(height: Sizes.spaceBtwItems),
//         _buildDOBSection(screenWidth),
//         const SizedBox(height: Sizes.spaceBtwSections),
//         const TitleAndDescription(
//           textAlign: TextAlign.left,
//           title: 'Bio',
//           description: 'A brief description about the services you provide',
//         ),
//         const SizedBox(height: Sizes.sm),
//         TextFieldContainer(
//           controller: bioController,
//           maxLength: 200,
//           maxLines: 3,
//           keyboardType: TextInputType.text,
//           hintText: 'Brief description',
//         ),
//         const SizedBox(height: Sizes.spaceBtwSections),
//         const TitleAndDescription(
//           textAlign: TextAlign.left,
//           title: 'Service',
//           description: 'Select the category and service you would render',
//         ),
//         Padding(
//           padding: const EdgeInsets.all(Sizes.sm),
//           child: _buildServiceDropdowns(occupations),
//         ),
//         const SizedBox(height: Sizes.spaceBtwSections),
//         const TitleAndDescription(
//           textAlign: TextAlign.left,
//           title: 'Skills',
//           description:
//               'Enter your professional skills and hit enter. Tap to remove.',
//         ),
//         const SizedBox(height: Sizes.sm),
//         TextFieldContainer(
//           controller: skillsController,
//           hintText: 'Skills',
//           keyboardType: TextInputType.text,
//           onSubmitted: (_) => _addSkill(),
//         ),
//         SkillsList(
//           skills: skills,
//           isDark: dark,
//           onDelete: (index) => setState(() => skills.removeAt(index)),
//         ),
        
//         const SizedBox(height: Sizes.spaceBtwSections),
//         const TitleAndDescription(
//           textAlign: TextAlign.left,
//           title: 'Hourly Rate',
//           description: 'Enter how much you charge per hour (minimum \$5)',
//         ),
//         const SizedBox(height: Sizes.sm),
//         TextFieldContainer(
//           controller: hourlyRateController,
//           hintText: 'Hourly Rate (\$)',
//           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//         ),
//         const SizedBox(height: Sizes.spaceBtwSections),
//       ],
//     );
//   }

//   Widget _buildDOBSection(double width) {
//     return Column(
//       children: [
//         Text(
//           selectedDate != null
//               ? 'Selected: ${selectedDate!.toLocal().toString().split(' ')[0]}'
//               : 'No Date Selected',
//           style: Theme.of(context).textTheme.labelSmall,
//         ),
//         if (validationMessage != null)
//           Text(
//             validationMessage!,
//             style: Theme.of(
//               context,
//             ).textTheme.labelMedium!.copyWith(color: Colors.red),
//           ),
//         const SizedBox(height: Sizes.spaceBtwItems),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextButton(
//               style: TextButton.styleFrom(
//                 padding: const EdgeInsets.all(Sizes.spaceBtwItems),
//                 backgroundColor: CustomColors.primary,
//               ),
//               onPressed: () => _pickDate(context),
//               child: Text(
//                 'Select DOB',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.labelMedium!.copyWith(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildServiceDropdowns(List<dynamic> occupations) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: screenWidth * 0.90,
//           child: DropdownButton<String>(
//             value: selectedCategory,
//             hint: Text(
//               'Select Category',
//               style: Theme.of(context).textTheme.labelSmall,
//             ),
//             isExpanded: true,
//             items:
//                 occupations.map<DropdownMenuItem<String>>((occupation) {
//                   return DropdownMenuItem(
//                     value: occupation['category'],
//                     child: Text(
//                       occupation['category'],
//                       style: Theme.of(context).textTheme.labelSmall,
//                     ),
//                   );
//                 }).toList(),
//             onChanged: (value) {
//               setState(() => selectedCategory = value);
//               _updateServices(occupations, value);
//             },
//           ),
//         ),
//         const SizedBox(height: Sizes.spaceBtwItems),
//         SizedBox(
//           width: screenWidth * 0.90,
//           child: DropdownButton<String>(
//             value: selectedService,
//             hint: Text(
//               'Select Service',
//               style: Theme.of(context).textTheme.labelSmall,
//             ),
//             isExpanded: true,
//             items:
//                 service.map((skill) {
//                   return DropdownMenuItem(
//                     value: skill,
//                     child: Text(
//                       skill,
//                       style: Theme.of(context).textTheme.labelSmall,
//                     ),
//                   );
//                 }).toList(),
//             onChanged: (value) => setState(() => selectedService = value),
//           ),
//         ),
//       ],
//     );
//   }
// }
