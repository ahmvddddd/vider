// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/custom_shapes/containers/button_container.dart';
import '../../../common/widgets/pop_up/custom_snackbar.dart';
import '../../../controllers/auth/dob_controller.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/helpers/responsive_size.dart';
import '../../../utils/helpers/token_secure_storage.dart';
import '../../uploads/upload_profile_image.dart';

class UserDOBScreen extends ConsumerStatefulWidget {
  const UserDOBScreen({super.key});

  @override
  ConsumerState<UserDOBScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDOBScreen> {
  bool isLoading = false;
  DateTime? selectedDate;
  bool _dobSelected = false;
  String? validationMessage;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final age = now.year - picked.year -
          ((now.month < picked.month ||
                  (now.month == picked.month && now.day < picked.day))
              ? 1
              : 0);
      setState(() {
        selectedDate = picked;
        _dobSelected = true;
        validationMessage =
            age < 18 ? "You must be at least 18 years old" : null;
      });
    }
  }

  Future<void> _submitProfile() async {
    setState(() => isLoading = true);
    await TokenSecureStorage.checkToken(context: context, ref: ref);

    if (!_dobSelected || validationMessage != null) {
      CustomSnackbar.show(
        context: context,
        title: 'Error',
        message: validationMessage ?? 'Please select your date of birth',
        icon: Icons.error_outline,
        backgroundColor: CustomColors.error,
      );
      setState(() => isLoading = false);
      return;
    }

    final result = await ref.read(
      updateUserBioProvider({
        'dateOfBirth': selectedDate?.toIso8601String(),
      }).future,
    );

    if (result == true && mounted) {
      CustomSnackbar.show(
        context: context,
        title: 'Success',
        message: 'Your date of birth was uploaded successfully',
        icon: Icons.check_circle,
        backgroundColor: CustomColors.success,
      );
      setState(() => isLoading = false);
      HelperFunction.navigateScreen(context, UploadProfileImageScreen());
    } else {
      setState(() => isLoading = false);
      CustomSnackbar.show(
        context: context,
        title: 'An error occurred',
        message: 'Could not upload your details. Please try again later',
        icon: Icons.error_outline,
        backgroundColor: CustomColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'User Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      bottomNavigationBar: ButtonContainer(
        text: 'Submit',
        onPressed: _submitProfile,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 4.0,
                backgroundColor: dark ? Colors.white : Colors.black,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(responsiveSize(context, Sizes.spaceBtwItems)),
              child: _buildDOBSection(MediaQuery.of(context).size.width),
            ),
    );
  }

  Widget _buildDOBSection(double width) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            'Date of Birth',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: responsiveSize(context, Sizes.spaceBtwItems)),
          Text(
            selectedDate != null
                ? 'Selected: ${selectedDate!.toLocal().toString().split(' ')[0]}'
                : 'No Date Selected',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (validationMessage != null)
            Text(
              validationMessage!,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: Colors.red),
            ),
          SizedBox(height: responsiveSize(context, Sizes.spaceBtwSections)),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.all(responsiveSize(context, Sizes.spaceBtwItems)),
              backgroundColor: CustomColors.primary,
            ),
            onPressed: () => _pickDate(context),
            child: Text(
              'Select DOB',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
