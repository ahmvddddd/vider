import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../models/providers/providers_category_model.dart';

final providersMapController = StateNotifierProvider<
  ProvidersMapNotifier,
  AsyncValue<List<ProvidersCategoryModel>>
>((ref) => ProvidersMapNotifier());

class ProvidersMapNotifier
    extends StateNotifier<AsyncValue<List<ProvidersCategoryModel>>> {
  ProvidersMapNotifier() : super(const AsyncValue.data([]));

  Future<void> fetchProviders({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
  }) async {
    state = const AsyncValue.loading();
    try {
      String providersMapURL =
          dotenv.env['PROVIDERS_MAP'] ?? 'https://defaulturl.com/api';
      final url = Uri.parse(
        "$providersMapURL?northEastLat=$northEastLat&northEastLng=$northEastLng&southWestLat=$southWestLat&southWestLng=$southWestLng",
      );

      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(res.body);
        final providers = jsonData.map((e) => ProvidersCategoryModel.fromJson(e)).toList();
        state = AsyncValue.data(providers);
      } else {
        state = AsyncValue.error("Error ${res.statusCode}", StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
