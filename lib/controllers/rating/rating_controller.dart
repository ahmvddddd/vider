import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final ratingControllerProvider =
    StateNotifierProvider<RatingController, AsyncValue<void>>((ref) {
      return RatingController();
    });

class RatingController extends StateNotifier<AsyncValue<void>> {
  RatingController() : super(const AsyncValue.data(null));

  final _storage = const FlutterSecureStorage();
  final logger = Logger();
  final String ratingURL =
      dotenv.env["RATING_URL"] ?? 'https://defaulturl.com/api';

  Future<void> rateUser(String profileId, int rating) async {
    state = const AsyncValue.loading();
    try {
      final token = await _storage.read(key: "token");
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      final response = await http.post(
        Uri.parse("$ratingURL/rate"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({"profileId": profileId, "rating": rating}),
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.data(null);
      } else {
        final body = jsonDecode(response.body);
        state = AsyncValue.error(
          'An error occured, could not rate this provider',
          StackTrace.current,
        );

        try {
          await FirebaseCrashlytics.instance.recordError(
            '${body['message']}',
            null,
            reason: 'Rate provider API returned error ${response.statusCode}',
          );
        } catch (e) {
          logger.i("Crashlytics logging failed: $e");
        }
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        'An error occured, could not rate this provider',
        stackTrace,
      );
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Rate Provider controller failed',
      );
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../controllers/rating_controller.dart';

// class RateUserWidget extends ConsumerWidget {
//   final String profileId;

//   const RateUserWidget({super.key, required this.profileId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final ratingState = ref.watch(ratingControllerProvider);

//     return Column(
//       children: [
//         RatingBar.builder(
//           initialRating: 0,
//           minRating: 0,
//           maxRating: 5,
//           itemCount: 5,
//           itemSize: 40,
//           direction: Axis.horizontal,
//           allowHalfRating: false,
//           itemBuilder: (context, _) => const Icon(
//             Icons.star,
//             color: Colors.amber,
//           ),
//           onRatingUpdate: (rating) {
//             ref.read(ratingControllerProvider.notifier).rateUser(profileId, rating.toInt());
//           },
//         ),
//         if (ratingState.isLoading) const CircularProgressIndicator(),
//         if (ratingState.hasError)
//           Text("Error: ${ratingState.error}", style: const TextStyle(color: Colors.red)),
//       ],
//     );
//   }
// }
