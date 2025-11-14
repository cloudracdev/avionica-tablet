import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/telemetry_data.dart';
import '../models/flight_data.dart';
import '../services/calibration/calibration_service.dart';
import '../data/repositories/telemetry_repository.dart';
import 'mock_mode_provider.dart';

/// 🎯 PROVIDER: Serviço de calibração (singleton)
final calibrationServiceProvider = Provider<CalibrationService>((ref) {
  return CalibrationService();
});

/// 🎯 PROVIDER: Telemetria processada (StateNotifier)
final telemetryProvider = StateNotifierProvider<TelemetryNotifier, TelemetryData>((ref) {
  final repository = ref.watch(telemetryRepositoryProvider);
  return TelemetryNotifier(
    repository,
    ref.watch(calibrationServiceProvider),
  );
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
  StreamSubscription<FlightData>? _subscription;

  int _frameCount = 0;
  int _lastSecond = 0;
  int _currentHz = 0;

  TelemetryNotifier(this._repository, this._calibration)
      : super(TelemetryData.initial()) {
    _listenToRepository();
  }

  int get currentHz => _currentHz;

  void _listenToRepository() {
    _subscription = _repository.getFlightDataStream().listen((flightData) {
      _processFlightData(flightData);
    });
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

    // APLICAR CALIBRAÇÃO
    final velocidade = flightData.velocidade;
    final altitude = _calibration.applyCalibratedAltitude(flightData.altitude);
    final heading = _calibration.applyCalibratedHeading(flightData.heading);
    final pitch = _calibration.applyCalibratedPitch(flightData.pitch);
    final roll = _calibration.applyCalibratedRoll(flightData.roll);
    final vario = 0.0;
    final gyroZ = flightData.gyroZ;

    state = TelemetryData(
      velocidade: velocidade,
      altitude: altitude,
      heading: heading,
      pitch: pitch,
      roll: roll,
      vario: vario,
      temperatura: flightData.temperatura,
      pressao: flightData.pressao,
      lat: flightData.lat,
      lng: flightData.lng,
      gyroZ: gyroZ,
      accelX: flightData.accelX,
      accelY: flightData.accelY,
      timestamp: flightData.timestamp,
    );
  }
}