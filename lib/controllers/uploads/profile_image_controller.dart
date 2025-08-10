import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../../common/widgets/pop_up/custom_snackbar.dart';
import '../../screens/authentication/user_details/upload_id_screen.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/helpers/helper_function.dart';

/// Riverpod provider for profile image controller
final profileImageControllerProvider =
    AsyncNotifierProvider<ProfileImageController, void>(
      () => ProfileImageController(),
    );
String profileImageURL =
    dotenv.env['PROFILE_IMAGE_URL'] ?? 'https://defaulturl.com/api';

class ProfileImageController extends AsyncNotifier<void> {
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  bool isLoading = false;
  XFile? _imageFile;
  final logger = Logger();

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  /// Public getter for image
  XFile? get capturedImage => _imageFile;

  /// Public getter to check if camera is ready
  bool get isCameraInitialized =>
      cameraController?.value.isInitialized ?? false;

  /// Called automatically when provider is created
  @override
  Future<void> build() async {
    ref.onDispose(() {
      cameraController?.dispose();
    });

    await initializeCamera();
  }

  /// Initialize camera and update state
  Future<void> initializeCamera() async {
  // Dispose any existing controller before creating a new one
  await cameraController?.dispose();

  cameras = await availableCameras();
  if (cameras != null && cameras!.isNotEmpty) {
    // Find the front camera
    final frontCamera = cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras!.first, // fallback to first if front not found
    );

    cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await cameraController!.initialize();
    state = const AsyncData(null);
  }
}



  

  /// Take a picture
  Future<void> captureImage() async {
    if (cameraController != null && cameraController!.value.isInitialized) {
      _imageFile = await cameraController!.takePicture();
      state = const AsyncData(null); // Trigger UI update
    }
  }

  /// Upload picture to backend with auth
  Future<void> uploadImage(BuildContext context) async {
    isLoading = true;
    state = const AsyncValue.loading();
    try {
      final token = await secureStorage.read(key: 'token');
      if (_imageFile == null || token == null) {
        throw Exception('No image  available');
      }

      final request = http.MultipartRequest('POST', Uri.parse(profileImageURL));

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('profileImage', _imageFile!.path),
      );
      final response = await request.send();
      if (response.statusCode == 200) {
      await cameraController?.dispose(); 
        CustomSnackbar.show(
          context: context,
          title: 'Success',
          message: 'Image uploaded successfully',
          icon: Icons.check_circle,
          backgroundColor: CustomColors.success,
        );
        HelperFunction.navigateScreen(context, UploadIdScreen());
      } else {
        try {
          await FirebaseCrashlytics.instance.recordError(
            Exception("Failed to upload profile image: ${response.statusCode}"),
            null,
            reason:
                'User profile image API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i('Crashlytics profile image response failed $e');
        }
        CustomSnackbar.show(
          context: context,
          title: 'An error occurred',
          message: 'Failed to upload image. Try again later',
          icon: Icons.error_outline,
          backgroundColor: CustomColors.error,
        );
      }
    } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'User profile image controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics profile image controller failed $e');
      }
      CustomSnackbar.show(
        context: context,
        title: 'An error occurred',
        message: 'Failed to upload image. Try again later',
        icon: Icons.error_outline,
        backgroundColor: CustomColors.error,
      );
    } finally {
      isLoading = false;
      state = const AsyncValue.data(null);
    }
  }
}
