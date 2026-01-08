/// 🎛️ KOLLSMAN PROVIDER
/// 
/// Estado global do QNH para correção de altitude barométrica
/// Afeta dados gravados (aplicado no telemetryProvider)

import 'package:flutter_riverpod/flutter_riverpod.dart';

class KollsmanState {
  final double qnhInHg;
  
  const KollsmanState({this.qnhInHg = 29.92});
  
  /// QNH padrão (1013.25 hPa)
  static const double qnhPadrao = 29.92;
  
  /// Correção em pés (1 inHg ≈ 1000 ft)
  double get correcaoFeet => (qnhInHg - qnhPadrao) * 1000;
  
  /// Correção em metros
  double get correcaoMetros => correcaoFeet / 3.28084;
  
  KollsmanState copyWith({double? qnhInHg}) {
    return KollsmanState(qnhInHg: qnhInHg ?? this.qnhInHg);
  }
}

class KollsmanNotifier extends StateNotifier<KollsmanState> {
  KollsmanNotifier() : super(const KollsmanState());
  
  void setQnh(double qnh) {
    state = state.copyWith(qnhInHg: qnh.clamp(28.00, 31.00));
  }
  
  void reset() {
    state = const KollsmanState();
  }
  
  /// Aplica correção Kollsman na altitude (metros)
  double applyKollsman(double altitudeMetros) {
    return altitudeMetros + state.correcaoMetros;
  }
}

final kollsmanProvider = StateNotifierProvider<KollsmanNotifier, KollsmanState>((ref) {
  return KollsmanNotifier();
});
