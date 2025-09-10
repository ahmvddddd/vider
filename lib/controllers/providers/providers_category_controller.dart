import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import '../../models/providers/providers_category_model.dart';
import '../../utils/helpers/connectivity_helper.dart';

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
  final logger = Logger();
  final Ref ref;

  ServiceProfilesNotifier({
    required this.category,
    required this.service,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
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
          final body = jsonDecode(res.body);

          try {
            final connectivity = ref.read(connectivityProvider);
            if (!connectivity.isOnline) {
              throw Exception(
                'No Internet. Please check your internet connection',
              );
            }
            await FirebaseCrashlytics.instance.recordError(
              '${body['message']}',
              null,
              reason: 'Profile category API returned error ${res.statusCode}',
            );
          } catch (e) {
            logger.i("Crashlytics logging failed: $e");
          }
          state = AsyncValue.error(
            "An error occured, failed to load profiles",
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
      } catch (error, stackTrace) {
        state = AsyncValue.error(
          'An error occured, failed to load profiles',
          stackTrace,
        );
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'An error occured, failed to load profiles',
        );
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
  return ServiceProfilesNotifier(
    category: key.category,
    service: key.service,
    ref: ref,
  );
});
