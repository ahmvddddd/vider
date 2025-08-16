import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../models/providers/providers_category_model.dart';

String baseUrl = dotenv.env['BASE_URL'] ?? 'https://defaulturl.com/api';

/// Fetch all categories
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final res = await http.get(Uri.parse("$baseUrl/grouped-categories"));
  final json = jsonDecode(res.body);
  return List<String>.from(json['data']);
});

/// Fetch services for a given category
final servicesProvider = FutureProvider.family<List<String>, String>((
  ref,
  category,
) async {
  final res = await http.get(Uri.parse("$baseUrl/services?category=$category"));
  final json = jsonDecode(res.body);
  return List<String>.from(json['data']);
});

/// Debounced profile fetcher
class DebouncedProfilesNotifier
    extends StateNotifier<AsyncValue<List<ProvidersCategoryModel>>> {
  DebouncedProfilesNotifier() : super(const AsyncValue.data([]));

  Timer? _debounce;

  void fetchProfiles(String category, String service) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      state = const AsyncValue.loading();
      try {
        final res = await http.get(
          Uri.parse(
            "$baseUrl/service-profiles?category=$category&service=$service",
          ),
        );
        if (res.statusCode == 200) {
          final json = jsonDecode(res.body);
          final profiles =
              (json['data'] as List)
                  .map((p) => ProvidersCategoryModel.fromJson(p))
                  .toList();
          state = AsyncValue.data(profiles);
        } else {
          state = AsyncValue.error(
            "Failed to load profiles",
            StackTrace.current,
          );
        }
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }
}

final debouncedProfilesProvider = StateNotifierProvider<
  DebouncedProfilesNotifier,
  AsyncValue<List<ProvidersCategoryModel>>
>((ref) => DebouncedProfilesNotifier());
