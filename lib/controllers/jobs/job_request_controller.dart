import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final jobRequestProvider = FutureProvider.autoDispose<String?>((ref) async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  final jobRequestURL =
      dotenv.env['JOB_REQUEST_URL'] ?? "https://defaulturl.com/api";
      

  final response = await http.post(
    Uri.parse(jobRequestURL),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['vvid']; // return verification id
  } else {
    throw Exception(response.body);
  }
});
