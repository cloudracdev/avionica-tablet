import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/telemetry_data.dart';
import '../models/flight_data.dart';
import '../data/repositories/telemetry_repository.dart';
import '../data/repositories/websocket_telemetry_repository.dart';
import 'websocket_provider.dart';

/// 🎯 PROVIDER: Repository de telemetria (singleton)
final telemetryRepositoryProvider = Provider<TelemetryRepository>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  final repository = WebSocketTelemetryRepository(wsService);
  
  // 🧹 Cleanup automático
  ref.onDispose(() {
    repository.dispose();
  });
  
  return repository;
});

/// 🎯 PROVIDER: Telemetria processada (StateNotifier)
final telemetryProvider = StateNotifierProvider<TelemetryNotifier, TelemetryData>((ref) {
  final repository = ref.watch(telemetryRepositoryProvider);
  return TelemetryNotifier(repository);
});

/// 🎯 PROVIDER: Frequência de atualização (Hz)
final telemetryHzProvider = Provider<int>((ref) {
  // Força rebuild quando telemetry muda
  ref.watch(telemetryProvider);
  return ref.read(telemetryProvider.notifier).currentHz;
});

/// 📡 NOTIFIER: Processa dados do Repository
class TelemetryNotifier extends StateNotifier<TelemetryData> {
  final TelemetryRepository _repository;
  StreamSubscription<FlightData>? _subscription;

  // 📊 Medidor de frequência (Hz)
  int _frameCount = 0;
  int _lastSecond = 0;
  int _currentHz = 0;

  TelemetryNotifier(this._repository) : super(TelemetryData.initial()) {
    _listenToRepository();
  }

  /// 📊 Getter para frequência atual
  int get currentHz => _currentHz;

  /// 🎧 Escuta stream do Repository (FlightData type-safe!)
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

  /// ⚙️ Processa FlightData do Repository
  void _processFlightData(FlightData flightData) {
    // 📊 CALCULAR Hz (frames por segundo)
    final currentSecond = DateTime.now().second;
    if (currentSecond != _lastSecond) {
      _currentHz = _frameCount;
      _frameCount = 0;
      _lastSecond = currentSecond;
    }
    _frameCount++;

    // ✅ Usar dados diretos do FlightData (calibração desabilitada para teste)
    final velocidade = flightData.velocidade;
    final altitude = flightData.altitude;
    final heading = flightData.heading;
    final pitch = flightData.pitch;
    final roll = flightData.roll;
    
    // ✅ Variômetro desabilitado para teste (sempre 0)
    final vario = 0.0;

    // ✅ gyroZ vem do FlightData
    final gyroZ = flightData.gyroZ;

    // ✅ ATUALIZAR ESTADO (type-safe, via Repository)
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