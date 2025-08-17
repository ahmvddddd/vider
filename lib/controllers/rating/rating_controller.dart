import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final ratingControllerProvider =
    StateNotifierProvider<RatingController, AsyncValue<void>>((ref) {
  return RatingController();
});

class RatingController extends StateNotifier<AsyncValue<void>> {
  RatingController() : super(const AsyncValue.data(null));

  final _storage = const FlutterSecureStorage();
  final String ratingURL = dotenv.env["RATING_URL"] ?? 'https://defaulturl.com/api';

  Future<void> rateUser(String profileId, int rating) async {
    state = const AsyncValue.loading();
    try {
      final token = await _storage.read(key: "token"); // if you use auth
      final response = await http.post(
        Uri.parse("$ratingURL/rate"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "profileId": profileId,
          "rating": rating,
        }),
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(
          response.body,
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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
