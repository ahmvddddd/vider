import 'package:flutter_riverpod/flutter_riverpod.dart';

final pinStateProvider = StateNotifierProvider<PinStateNotifier, List<String>>(
  (ref) => PinStateNotifier(),
);

class PinStateNotifier extends StateNotifier<List<String>> {
  PinStateNotifier() : super(["", "", "", ""]);

  void enterDigit(String digit) {
    for (int i = 0; i < state.length; i++) {
      if (state[i].isEmpty) {
        state = [...state]..[i] = digit;
        break;
      }
    }
  }

  void removeDigit() {
    for (int i = state.length - 1; i >= 0; i--) {
      if (state[i].isNotEmpty) {
        state = [...state]..[i] = "";
        break;
      }
    }
  }

  void reset() {
    state = ["", "", "", ""];
  }

  String get pin => state.join();
}
