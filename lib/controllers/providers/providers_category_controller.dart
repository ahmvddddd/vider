import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../models/providers/providers_category_model.dart';

String baseUrl = dotenv.env['BASE_URL'] ?? 'https://defaulturl.com/api';

// Categories
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final res = await http.get(Uri.parse("$baseUrl/grouped-categories"));
  if (res.statusCode != 200) throw Exception("Failed to load categories");
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  return List<String>.from(json['data'] ?? []);
});

// Services by category
final servicesProvider = FutureProvider.family<List<String>, String>((
  ref,
  category,
) async {
  final res = await http.get(Uri.parse("$baseUrl/services?category=$category"));
  if (res.statusCode != 200) throw Exception("Failed to load services");
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  return List<String>.from(json['data'] ?? []);
});

/// ONE provider instance per (category, service) key.
/// This prevents cross-talk between tabs.
class ServiceProfilesNotifier
    extends StateNotifier<AsyncValue<List<ProvidersCategoryModel>>> {
  final String category;
  final String service;
  Timer? _debounce;

  ServiceProfilesNotifier({required this.category, required this.service})
    : super(const AsyncValue.loading()) {
    _fetch(); // load for this (category,service)
  }

  Future<void> _fetch() async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      state = const AsyncValue.loading();
      try {
        final url =
            "$baseUrl/service-profiles?category=$category&service=$service";
        final res = await http.get(Uri.parse(url));
        if (res.statusCode != 200) {
          state = AsyncValue.error(
            "Failed to load profiles",
            StackTrace.current,
          );
          return;
        }
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final list =
            (json['data'] as List? ?? [])
                .map(
                  (e) => ProvidersCategoryModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList();
        state = AsyncValue.data(list);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final serviceProfilesProvider = StateNotifierProvider.family.autoDispose<
  ServiceProfilesNotifier,
  AsyncValue<List<ProvidersCategoryModel>>,
  ({String category, String service})
>((ref, key) {
  // autoDispose ensures tabs you leave stop holding memory/network.
  return ServiceProfilesNotifier(category: key.category, service: key.service);
});
