import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/user/wallet_model.dart';

final walletProvider = StateNotifierProvider<WalletController, AsyncValue<WalletModel>>((ref) {
  return WalletController();
});

class WalletController extends StateNotifier<AsyncValue<WalletModel>> {
  WalletController() : super(const AsyncLoading());
  

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final logger = Logger();
  String walletURL = dotenv.env['WALLET_URL'] ?? 'https://defaulturl.com/api';
  

  Future<void> fetchBalance() async {
    final token = await secureStorage.read(
        key: 'token'); 

    try  {
      final response = await http.get(
      Uri.parse(walletURL),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final wallet = WalletModel.fromJson(data);
        state = AsyncData(wallet);
      } else {
    await FirebaseCrashlytics.instance.recordError(
          Exception("Failed to fetch wallet balance: ${response.body}"),
          null,
          reason: 'Wallet balance API returned error ${response.statusCode}',
        );
      state = AsyncError('Failed to fetch balance', StackTrace.current);
    }
    } catch (error, stackTrace) {
    await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Wallet balance controller failed',
      );
      state = AsyncError('Failed to fetch balance', stackTrace);
    }
  }
  }




final walletControllerProvider = Provider((ref) => PinController());

class PinController {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final logger = Logger();
  String createPINURL = dotenv.env['CREATE_PIN_URL'] ?? 'https://defaulturl.com/api';

  Future<String?> createPin({
    required String pin,
  }) async {
    String formatBackendError(String message) {
    if (message.contains('Wallet not found')) {
      return 'Could not change your pin. Contact customer support';
    } else {
      return message;
    }
  }
    
    try {
      final token = await _secureStorage.read(key: 'token');

      final response = await http.post(
        Uri.parse(createPINURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'pin': pin}),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        final responseData = jsonDecode(response.body);
        final rawError = responseData['message'] ?? 'Failed to create PIN';

        final formattedError =
            response.statusCode == 500
                ? 'Something went wrong on our side. Please try again later.'
                : formatBackendError(rawError);

        final error = formattedError;
        
    try {
      await FirebaseCrashlytics.instance.recordError(
        Exception("Failed to create pin: ${response.body}"),
        null,
        reason: 'Create transaction PIN API returned error ${response
            .statusCode}',
      );
    } catch (e) {
      logger.i('Crashlytics Wallet API response failed $e');
    }
        throw Exception(error);
      }
    } on http.ClientException catch (e) {
    return 'Network error: ${e.message}';
  } catch (error, stackTrace) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Create transaction PIN controller failed',
        );
      } catch (e) {
        logger.i('Crashlytics transaction PIN controller failed $e');
      }
    return error.toString();
  }
  }
}
