import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../models/jobs/occupations_model.dart';

// Change this to your backend URL
String occupationsURL =
    dotenv.env['OCCUPATIONS_URL'] ?? 'https://defaulturl.com/api';

class OccupationsController extends AsyncNotifier<List<Occupation>> {
  @override
  Future<List<Occupation>> build() async {
    return fetchOccupations();
  }

  Future<List<Occupation>> fetchOccupations() async {
    final url = Uri.parse(occupationsURL);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Occupation.fromJson(e)).toList();
    } else {
      throw Exception('An error occurred while fetching occupations');
    }
  }

  /// Optional: manual refresh method
  Future<void> refreshOccupations() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchOccupations());
  }
}

final occupationControllerProvider =
    AsyncNotifierProvider<OccupationsController, List<Occupation>>(
      OccupationsController.new,
    );
