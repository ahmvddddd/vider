import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../models/transaction/transaction_model.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../utils/helpers/connectivity_helper.dart';

final FlutterSecureStorage storage = FlutterSecureStorage();
String transactionsURL =
    dotenv.env['TRANSACTIONS_URL'] ?? 'https://defaulturl.com/api';
final logger = Logger();

final transactionProvider = FutureProvider.family.autoDispose<
  List<TransactionModel>,
  int?
>((ref, limit) async {

  final connectivity = ref.read(connectivityProvider);

    if (!connectivity.isOnline) {
      throw Exception('No Internet. Please check your internet connection');
    }

  try {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse(transactionsURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final transactions =
          data.map((e) => TransactionModel.fromJson(e)).toList();

      // Apply the limit if it's provided
      if (limit != null) {
        return transactions.take(limit).toList();
      }
      return transactions;
    } else {
      final exception = 'Failed to load transactions';
      try {
        await FirebaseCrashlytics.instance.recordError(
          Exception("Failed to fetch transactions: ${response.body}"),
          null,
          reason:
              'Fetch transactions API returned error ${response.statusCode}',
        );
      } catch (e) {
        logger.i('Crashlytics fetch transactions API response failed');
      }
      throw exception;
    }
  } catch (error, stackTrace) {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Fetch transactions controller failed',
      );
    } catch (e) {
      logger.i('Crashlytics fetch transactions controller failed $e');
    }
    throw Exception('Failed to load transactions');
  }
});
