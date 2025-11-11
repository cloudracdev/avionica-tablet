import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flight_stats.dart';
import '../models/telemetry_data.dart';
import 'telemetry_provider.dart';

/// 🎯 PROVIDER: Estatísticas de voo (StateNotifier)
final flightStatsProvider = StateNotifierProvider<FlightStatsNotifier, FlightStats>((ref) {
  return FlightStatsNotifier(ref);
});

/// 📊 NOTIFIER: Calcula estatísticas baseado na telemetria
class FlightStatsNotifier extends StateNotifier<FlightStats> {
  final Ref _ref;

  FlightStatsNotifier(this._ref) : super(FlightStats.initial()) {
    _listenToTelemetry();
  }

  /// 🎧 Escuta telemetria e atualiza stats
  void _listenToTelemetry() {
    _ref.listen<TelemetryData>(
      telemetryProvider,
      (previous, next) {
        _updateStats(next);
      },
    );
  }

  /// 📊 Atualiza estatísticas com novos dados
  void _updateStats(TelemetryData telemetry) {
    // Calcular duração do voo
    final duration = DateTime.now().difference(state.startTime);

    // Atualizar valores máximos/mínimos
    state = state.copyWith(
      duration: duration,
      
      // Velocidade (só aumenta)
      velocidadeMax: telemetry.velocidade > state.velocidadeMax 
          ? telemetry.velocidade 
          : state.velocidadeMax,
      
      // Altitude (só aumenta)
      altitudeMax: telemetry.altitude > state.altitudeMax 
          ? telemetry.altitude 
          : state.altitudeMax,
      
      // Pitch (max/min)
      pitchMax: telemetry.pitch > state.pitchMax 
          ? telemetry.pitch 
          : state.pitchMax,
      pitchMin: telemetry.pitch < state.pitchMin 
          ? telemetry.pitch 
          : state.pitchMin,
      
      // Roll (max/min)
      rollMax: telemetry.roll > state.rollMax 
          ? telemetry.roll 
          : state.rollMax,
      rollMin: telemetry.roll < state.rollMin 
          ? telemetry.roll 
          : state.rollMin,
      
      // Variômetro (max/min)
      varioMax: telemetry.vario > state.varioMax 
          ? telemetry.vario 
          : state.varioMax,
      varioMin: telemetry.vario < state.varioMin 
          ? telemetry.vario 
          : state.varioMin,
      
      // Temperatura (max/min)
      temperaturaMax: telemetry.temperatura > state.temperaturaMax 
          ? telemetry.temperatura 
          : state.temperaturaMax,
      temperaturaMin: telemetry.temperatura < state.temperaturaMin 
          ? telemetry.temperatura 
          : state.temperaturaMin,
    );
  }

  /// 🔄 Reset estatísticas (novo voo)
  void reset() {
    state = FlightStats.initial();
  }
}