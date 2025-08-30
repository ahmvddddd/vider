import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../models/providers/providers_category_model.dart';

final searchQueryProvider = StateProvider<String>((ref) => "");

final searchProfilesProvider =
    FutureProvider.autoDispose<List<ProvidersCategoryModel>>((ref) async {
      final query = ref.watch(searchQueryProvider).trim();
      if (query.isEmpty) return const [];

      final searchProvidersURL =
          dotenv.env["SEARCH_PROVIDERS_URL"] ?? 'https://defaulturl.com/api';

      try {
        final uri = Uri.parse(
          searchProvidersURL,
        ).replace(queryParameters: {'q': query});

        final resp = await http.get(
          uri,
          headers: {'Content-Type': 'application/json'},
        );
        if (resp.statusCode != 200) {
          throw Exception(resp.body);
        }

        final data = json.decode(resp.body);

        final List providersJson = data['data'];

        // Convert list of JSON into list of ProvidersCategoryModel
        return providersJson
            .map((json) => ProvidersCategoryModel.fromJson(json))
            .toList();
      } catch (e) {
        throw Exception(e.toString());
      }
    });
