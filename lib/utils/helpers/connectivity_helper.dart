import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityController extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  ConnectivityController() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _isOnline = results.any((result) => result != ConnectivityResult.none);
      notifyListeners();
    });
    _init();
  }

  Future<void> _init() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isNotEmpty) {
      _isOnline = results.any((result) => result != ConnectivityResult.none);
    } else {
      _isOnline = false;
    }
    notifyListeners();
  }
}


final connectivityProvider = ChangeNotifierProvider<ConnectivityController>((ref) {
  return ConnectivityController();
});
