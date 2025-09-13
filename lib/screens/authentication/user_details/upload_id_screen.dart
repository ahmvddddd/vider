import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/custom_shapes/containers/button_container.dart';
import '../../../common/widgets/pop_up/custom_snackbar.dart';
import '../../../common/widgets/texts/title_and_description.dart';
import '../../../controllers/uploads/upload_id_controller.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/helpers/helper_function.dart';
import '../../../utils/helpers/token_secure_storage.dart';
import '../verification/verify_email.dart';

class UploadIdScreen extends ConsumerStatefulWidget {
  const UploadIdScreen({super.key});

  @override
  ConsumerState<UploadIdScreen> createState() => _UploadIdScreenState();
}

class _UploadIdScreenState extends ConsumerState<UploadIdScreen> {
  final ImagePicker idPicker = ImagePicker();
  bool isLoading = false;
  XFile? idImage;

  String selectedOption = 'Drivers License';
  final List<String> idType = [
    'Drivers License',
    'National Id',
    'International Passport',
  ];

  Future<void> getImage() async {
    final XFile? image = await idPicker.pickImage(source: ImageSource.gallery);
    setState(() {
      idImage = image;
    });
  }

  Future<void> _uploadImage() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (idImage == null) {
        CustomSnackbar.show(
          context: context,
          title: 'No image selected',
          message: 'Select an image first',
          icon: Icons.error_outline,
          backgroundColor: CustomColors.error,
        );
        return;
      }

      await TokenSecureStorage.checkToken(context: context, ref: ref);

      await VerifyIdController.uploadIdentificationCard(
        context: context,
        idImage: File(idImage!.path),
        idType: selectedOption,
      );
      HelperFunction.navigateScreen(context, VerifyEmailScreen());
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        title: 'Upload Failed',
        message: e.toString(),
        icon: Icons.error,
        backgroundColor: CustomColors.error,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final dark = HelperFunction.isDarkMode(context);

    return SafeArea(
      child: Scaffold(
        appBar: TAppBar(
          title: Text(
            'Identification Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          showBackArrow: true,
        ),
        bottomNavigationBar: ButtonContainer(
          onPressed: (idImage == null) ? null : _uploadImage,
          text: 'Submit',
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.spaceBtwItems),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TitleAndDescription(
                  textAlign: TextAlign.left,
                  title: 'Id Type',
                  description:
                      'Select the type of Identification Document you would like to upload',
                ),
                const SizedBox(height: Sizes.spaceBtwItems),
                SizedBox(
                  width: screenWidth * 0.70,
                  child: Padding(
                    padding: const EdgeInsets.only(left: Sizes.sm),
                    child: DropdownButton(
                      value: selectedOption,
                      isExpanded: true,
                      hint: Text(
                        'Select Id type',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      items:
                          idType.map((String option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(
                                option,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOption = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: Sizes.spaceBtwSections),
                const TitleAndDescription(
                  textAlign: TextAlign.left,
                  title: 'Id Image',
                  description:
                      'Tap the button below to upload an image of your Identity card. Make sure your photo is clear and ensure your names match with no spelling error.',
                ),

                const SizedBox(height: Sizes.spaceBtwSections),
                idImage == null
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No Image Selected',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    )
                    : Container(
                      height: screenHeight * 0.20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Sizes.borderRadiusMd,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Sizes.borderRadiusMd,
                        ),
                        child: Image.file(
                          File(idImage!.path),
                          height: screenHeight * 0.20,
                        ),
                      ),
                    ),
                const SizedBox(height: Sizes.spaceBtwItems),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading
                        ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ), // color
                          strokeWidth: 4.0, // thickness of the line
                          backgroundColor:
                              dark ? Colors.white : Colors.black, //
                        )
                        : TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(Sizes.spaceBtwItems),
                            backgroundColor: CustomColors.primary,
                          ),
                          onPressed: getImage,
                          child: Text(
                            'Select Image',
                            style: Theme.of(context).textTheme.labelMedium!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                  ],
                ),

                const SizedBox(height: Sizes.spaceBtwSections),
                Text(
                  'ID verification is compulsory for all users. Unverified accounts can not hire providers and would end up being suspended',
                  style: Theme.of(context).textTheme.bodyMedium,
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
