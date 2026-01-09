/// 🎬 FLIGHT RECORDING PROVIDER
/// 
/// Conecta FlightRecordingService ao TelemetryProvider
/// Escuta dados REAIS e grava automaticamente

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recording/flight_recording_service.dart';
import '../models/telemetry_data.dart';
import 'telemetry_provider.dart';
import '../services/sync/connectivity_service.dart';

/// Estado da gravação
class RecordingState {
  final bool isRecording;
  final String? flightId;
  final int pointsRecorded;
  final Duration duration;
  final String? error;

  const RecordingState({
    this.isRecording = false,
    this.flightId,
    this.pointsRecorded = 0,
    this.duration = Duration.zero,
    this.error,
  });

  RecordingState copyWith({
    bool? isRecording,
    String? flightId,
    int? pointsRecorded,
    Duration? duration,
    String? error,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      flightId: flightId ?? this.flightId,
      pointsRecorded: pointsRecorded ?? this.pointsRecorded,
      duration: duration ?? this.duration,
      error: error,
    );
  }
}

/// Provider do Service (singleton)
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

final flightRecordingServiceProvider = Provider<FlightRecordingService>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  final service = FlightRecordingService(connectivity: connectivity);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider do Estado
final flightRecordingProvider =
    StateNotifierProvider<FlightRecordingNotifier, RecordingState>((ref) {
  return FlightRecordingNotifier(ref);
});

/// Notifier que gerencia gravação
class FlightRecordingNotifier extends StateNotifier<RecordingState> {
  final Ref _ref;
  Timer? _durationTimer;
  
  FlightRecordingNotifier(this._ref) : super(const RecordingState()) {
    _checkActiveSession();
  }

  FlightRecordingService get _service =>
      _ref.read(flightRecordingServiceProvider);

  /// 🔍 Verificar se tem voo ativo (crash recovery)
  Future<void> _checkActiveSession() async {
    final activeSession = await _service.getActiveSession();
    if (activeSession != null) {
      state = RecordingState(
        isRecording: false,
        flightId: activeSession.id,
        pointsRecorded: activeSession.totalPoints,
        error: 'Voo interrompido encontrado',
      );
    }
  }

  /// 🟢 INICIAR GRAVAÇÃO
  Future<void> startRecording({
    required String instructorId,
    String? studentId,
    required String aircraftId,
    int? tabletBatteryStart,
  }) async {
    try {
      final flightId = await _service.startRecording(
        instructorId: instructorId,
        studentId: studentId,
        aircraftId: aircraftId,
        tabletBatteryStart: tabletBatteryStart,
      );

      state = RecordingState(
        isRecording: true,
        flightId: flightId,
        pointsRecorded: 0,
        duration: Duration.zero,
      );

      _startListening();
      _startDurationTimer();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 🔴 FINALIZAR GRAVAÇÃO
  Future<void> stopRecording({int? tabletBatteryEnd}) async {
    try {
      _stopListening();
      _durationTimer?.cancel();

      await _service.stopRecording(tabletBatteryEnd: tabletBatteryEnd);

      state = const RecordingState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 🔄 RETOMAR VOO (crash recovery)
  Future<void> resumeRecording() async {
    if (state.flightId == null) return;

    try {
      await _service.resumeRecording(state.flightId!);

      state = state.copyWith(
        isRecording: true,
        error: null,
      );

      _startListening();
      _startDurationTimer();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 🗑️ DESCARTAR VOO
  Future<void> discardRecording() async {
    if (state.flightId == null) return;

    try {
      _stopListening();
      _durationTimer?.cancel();

      await _service.discardRecording(state.flightId!);

      state = const RecordingState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 👂 ESCUTAR DADOS REAIS
  void _startListening() {
    _ref.listen<TelemetryData>(telemetryProvider, (previous, next) {
      if (state.isRecording) {
        _service.recordPoint(next);
        
        // Atualizar contador
        state = state.copyWith(
          pointsRecorded: _service.pointsRecorded,
        );
      }
    });
  }

  void _stopListening() {
    // Riverpod para de escutar automaticamente quando state muda
  }

  /// ⏱️ TIMER DURAÇÃO
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isRecording) {
        state = state.copyWith(
          duration: _service.recordingDuration,
        );
      }
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }
}
