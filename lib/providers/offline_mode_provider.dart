import 'package:flutter_riverpod/flutter_riverpod.dart';

final offlineModeProvider = StateNotifierProvider<OfflineModeNotifier, bool>((ref) {
  return OfflineModeNotifier();
});

class OfflineModeNotifier extends StateNotifier<bool> {
  OfflineModeNotifier() : super(false);

  void enableOfflineMode() => state = true;
  void disableOfflineMode() => state = false;
}
