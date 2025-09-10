import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../models/providers/providers_category_model.dart';
import '../../utils/helpers/connectivity_helper.dart';

final searchQueryProvider = StateProvider<String>((ref) => "");

final searchProfilesProvider =
    FutureProvider.autoDispose<List<ProvidersCategoryModel>>((ref) async {
      final query = ref.watch(searchQueryProvider).trim();
      if (query.isEmpty) return const [];

      final searchProvidersURL =
          dotenv.env["SEARCH_PROVIDERS_URL"] ?? 'https://defaulturl.com/api';
      final logger = Logger();

      try {
        final connectivity = ref.read(connectivityProvider);
        if (!connectivity.isOnline) {
          throw Exception('No Internet. Please check your internet connection');
        }

        final uri = Uri.parse(
          searchProvidersURL,
        ).replace(queryParameters: {'q': query});

        final res = await http.get(
          uri,
          headers: {'Content-Type': 'application/json'},
        );
        if (res.statusCode != 200) {
          final body = jsonDecode(res.body);
          final exception = 'No results found';

          try {
            await FirebaseCrashlytics.instance.recordError(
              '${body['message']}',
              null,
              reason: 'Search Providers API returned error ${res.statusCode}',
            );
          } catch (e) {
            logger.i("Crashlytics logging failed: $e");
          }
          throw exception;
        }

        final data = json.decode(res.body);

        final List providersJson = data['data'];

        // Convert list of JSON into list of ProvidersCategoryModel
        return providersJson
            .map((json) => ProvidersCategoryModel.fromJson(json))
            .toList();
      } catch (error, stackTrace) {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Search provider controller failed',
        );
        throw Exception('No results found');
      }
    });
