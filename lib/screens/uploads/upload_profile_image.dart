import 'dart:io' show File;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../common/widgets/appbar/appbar.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../controllers/uploads/profile_image_controller.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import '../../utils/helpers/responsive_size.dart';
import '../../utils/helpers/token_secure_storage.dart';

class UploadProfileImageScreen extends ConsumerWidget {
  const UploadProfileImageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = HelperFunction.isDarkMode(context);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final controller = ref.watch(profileImageControllerProvider.notifier);
    final image = controller.capturedImage;
    final isCameraReady = controller.isCameraInitialized;
    final camera = controller.cameraController;

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Upload Profile Image',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
      ),
      body: ref
          .watch(profileImageControllerProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'An error occured',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: responsiveSize(context,10)),
                      ElevatedButton(
                        onPressed: () {
                          // Force refresh the controller
                          ref.invalidate(profileImageControllerProvider);
                        },
                        child: Text(
                          'Retry',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

            data:
                (_) => SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        image == null
                            ? isCameraReady
                                ? Padding(
                                  padding: EdgeInsets.all(
                                    responsiveSize(context, Sizes.spaceBtwItems),
                                  ),
                                  child: RoundedContainer(
                                    height: screenHeight * 0.45,
                                    radius: Sizes.cardRadiusSm,
                                    backgroundColor: Colors.transparent,
                                    borderColor: CustomColors.primary,
                                    child: AspectRatio(
                                      aspectRatio: camera!.value.aspectRatio,
                                      child: CameraPreview(camera),
                                    ),
                                  ),
                                )
                                : const CircularProgressIndicator()
                            : CircleAvatar(
                              radius: 80,
                              backgroundImage: FileImage(File(image.path)),
                            ),
                        SizedBox(height: responsiveSize(context, Sizes.spaceBtwItems)),
                        SizedBox(
                          width: screenWidth * 0.40,
                          child: ElevatedButton(
                            onPressed: () => controller.captureImage(),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(Sizes.xs),
                              backgroundColor: CustomColors.primary,
                            ),
                            child: Icon(Icons.camera, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: responsiveSize(context, Sizes.spaceBtwItems)),
                        SizedBox(
                          width: screenWidth * 0.40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(Sizes.xs),
                              backgroundColor: CustomColors.primary,
                            ),
                            onPressed: () async {
                              await TokenSecureStorage.checkToken(
                                context: context,
                                ref: ref,
                              );
                              await controller.uploadImage(context);
                            },
                            child:
                                controller.isLoading
                                    ? Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.blue,
                                            ),
                                        strokeWidth: 4.0,
                                        backgroundColor:
                                            dark ? Colors.white : Colors.black,
                                      ),
                                    )
                                    : Text(
                                      'Upload Picture',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(color: Colors.white),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }
}
