import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/telemetry_data.dart';
import '../models/flight_data.dart';
import '../services/calibration/calibration_service.dart';
import '../data/repositories/telemetry_repository.dart';
import '../core/utils/logger.dart';
import 'kollsman_provider.dart';
import 'mock_mode_provider.dart';

/// 🎯 PROVIDER: Serviço de calibração (singleton)
final calibrationServiceProvider = Provider<CalibrationService>((ref) {
  return CalibrationService();
});

/// 🎯 PROVIDER: Telemetria processada (StateNotifier)
final telemetryProvider = StateNotifierProvider<TelemetryNotifier, TelemetryData>((ref) {
  final repository = ref.watch(telemetryRepositoryProvider);
  final calibration = ref.watch(calibrationServiceProvider);
  final kollsman = ref.watch(kollsmanProvider.notifier);
  return TelemetryNotifier(repository, calibration, kollsman);
});

/// 🎯 PROVIDER: Frequência de atualização (Hz)
final telemetryHzProvider = Provider<int>((ref) {
  ref.watch(telemetryProvider);
  return ref.read(telemetryProvider.notifier).currentHz;
});

/// 📡 NOTIFIER: Processa dados do Repository
class TelemetryNotifier extends StateNotifier<TelemetryData> {
  final TelemetryRepository _repository;
  final CalibrationService _calibration;
  final KollsmanNotifier _kollsman;
  StreamSubscription<FlightData>? _subscription;

  int _frameCount = 0;
  int _lastSecond = 0;
  int _currentHz = 0;
  
  // 🛡️ Último valor válido para fallback
  TelemetryData? _lastValidData;

  TelemetryNotifier(this._repository, this._calibration, this._kollsman)
      : super(TelemetryData.initial()) {
    _lastValidData = TelemetryData.initial();
    _listenToRepository();
  }

  int get currentHz => _currentHz;

  void _listenToRepository() {
    _subscription = _repository.getFlightDataStream().listen(
      (flightData) {
        try {
          _processFlightData(flightData);
        } catch (e, stackTrace) {
          Logger.error(
            '❌ Erro ao processar FlightData',
            e,
            stackTrace,
            'TelemetryNotifier',
          );
          if (_lastValidData != null) {
            state = _lastValidData!;
          }
        }
      },
      onError: (error) {
        Logger.error('❌ Erro no stream do repository', error, null, 'TelemetryNotifier');
      },
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _processFlightData(FlightData flightData) {
    final currentSecond = DateTime.now().second;
    if (currentSecond != _lastSecond) {
      _currentHz = _frameCount;
      _frameCount = 0;
      _lastSecond = currentSecond;
    }
    _frameCount++;

    try {
      // 1️⃣ CALIBRAÇÃO (offset do sensor)
      final altitudeCalibrada = _calibration.applyCalibratedAltitude(flightData.altitude);
      
      // 2️⃣ KOLLSMAN (correção barométrica)
      final altitudeFinal = _kollsman.applyKollsman(altitudeCalibrada);
      
      // 3️⃣ OUTROS INSTRUMENTOS (só calibração)
      final heading = _calibration.applyCalibratedHeading(flightData.heading);
      final pitch = _calibration.applyCalibratedPitch(flightData.pitch);
      final roll = _calibration.applyCalibratedRoll(flightData.roll);

      final newData = TelemetryData(
        velocidade: flightData.velocidade,
        altitude: altitudeFinal,
        heading: heading,
        pitch: pitch,
        roll: roll,
        vario: 0.0,
        temperatura: flightData.temperatura,
        pressao: flightData.pressao,
        lat: flightData.lat,
        lng: flightData.lng,
        gyroZ: flightData.gyroZ,
        accelX: flightData.accelX,
        accelY: flightData.accelY,
        timestamp: flightData.timestamp,
      );

      state = newData;
      _lastValidData = newData;
    } catch (e) {
      Logger.warning('⚠️ Erro na calibração, mantendo valor anterior', 'TelemetryNotifier');
    }
  }
}
