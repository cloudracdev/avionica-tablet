import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/telemetry_data.dart';
import '../services/calibration/calibration_service.dart';
import '../services/data_processing/smoothing_service.dart';
import '../services/websocket/websocket_service.dart';
import 'websocket_provider.dart';

/// 🎯 PROVIDER: Serviço de calibração (singleton)
final calibrationServiceProvider = Provider<CalibrationService>((ref) {
  return CalibrationService();
});

/// 🎯 PROVIDER: Serviço de suavização (singleton)
final smoothingServiceProvider = Provider<SmoothingService>((ref) {
  return SmoothingService();
});

/// 🎯 PROVIDER: Telemetria processada (StateNotifier)
final telemetryProvider = StateNotifierProvider<TelemetryNotifier, TelemetryData>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  
  return TelemetryNotifier(
    wsService,
    ref.watch(calibrationServiceProvider),
    ref.watch(smoothingServiceProvider),
  );
});

/// 🎯 PROVIDER: Frequência de atualização (Hz)
final telemetryHzProvider = Provider<int>((ref) {
  // Força rebuild quando telemetry muda
  ref.watch(telemetryProvider);
  return ref.read(telemetryProvider.notifier).currentHz;
});

/// 📡 NOTIFIER: Processa dados do WebSocket
class TelemetryNotifier extends StateNotifier<TelemetryData> {
  final WebSocketService _wsService;
  final CalibrationService _calibration;
  final SmoothingService _smoothing;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  // 📊 Controle do variômetro
  double _altitudePrevious = 0;
  int _timePrevious = 0;
  bool _firstVarioCalc = true;
  double _varioSmooth = 0;
  final double _varioAlpha = 0.15;
  final int _varioCalcInterval = 500; // ms

  // 📊 Medidor de frequência (Hz)
  int _frameCount = 0;
  int _lastSecond = 0;
  int _currentHz = 0;

  TelemetryNotifier(this._wsService, this._calibration, this._smoothing)
      : super(TelemetryData.initial()) {
    _listenToWebSocket();
  }

  /// 📊 Getter para frequência atual
  int get currentHz => _currentHz;

  /// 🎧 Escuta stream do WebSocket (DIRETO - sem ref.listen!)
  void _listenToWebSocket() {
    _subscription = _wsService.dataStream.listen((rawData) {
      _processRawData(rawData);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// ⚙️ Processa dados brutos do ESP32
  void _processRawData(Map<String, dynamic> data) {
    // 📊 CALCULAR Hz (frames por segundo)
    final currentSecond = DateTime.now().second;
    if (currentSecond != _lastSecond) {
      _currentHz = _frameCount;
      _frameCount = 0;
      _lastSecond = currentSecond;
    }
    _frameCount++;

    // 1️⃣ CONVERTER para Map<String, double>
    Map<String, double> rawData = {
      'velocidade': _toDouble(data['velocidade']),
      'altitude': _toDouble(data['altitude']),
      'heading': _toDouble(data['heading']),
      'pitch': _toDouble(data['pitch']),
      'roll': _toDouble(data['roll']),
      'temperatura': _toDouble(data['temperatura']),
      'pressao': _toDouble(data['pressao']),
      'lat': _toDouble(data['lat']),
      'lng': _toDouble(data['lng']),
    };

    // 2️⃣ 🔥 TESTE: SMOOTHING DESABILITADO (usar dados diretos)
    Map<String, double> smoothData = rawData;
    // Map<String, double> smoothData = _smoothing.smoothData(rawData); // ← ORIGINAL

    // 3️⃣ 🔥 TESTE: CALIBRAÇÃO DESABILITADA (usar dados diretos)
    final velocidade = smoothData['velocidade']!;
    final altitude = smoothData['altitude']!;
    final heading = smoothData['heading']!;
    final pitch = smoothData['pitch']!;
    final roll = smoothData['roll']!;
    
    // ORIGINAL (comentado para teste):
    // final velocidade = smoothData['velocidade']!;
    // final altitude = _calibration.applyCalibratedAltitude(smoothData['altitude']!);
    // final heading = _calibration.applyCalibratedHeading(smoothData['heading']!);
    // final pitch = _calibration.applyCalibratedPitch(smoothData['pitch']!);
    // final roll = _calibration.applyCalibratedRoll(smoothData['roll']!);

    // 4️⃣ 🔥 TESTE: VARIÔMETRO DESABILITADO (sempre 0)
    final vario = 0.0;
    
    // ORIGINAL (comentado para teste):
    // final vario = _calculateVario(altitude);

    // 5️⃣ PROCESSAR COORDENADOR DE CURVA
    final gyroZ = _toDouble(data['lsm_gz']);
    final accelX = _toDouble(data['lsm_ax']);
    final accelY = _toDouble(data['lsm_ay']);

    // 6️⃣ ATUALIZAR ESTADO
    state = TelemetryData(
      velocidade: velocidade,
      altitude: altitude,
      heading: heading,
      pitch: pitch,
      roll: roll,
      vario: vario,
      temperatura: smoothData['temperatura']!,
      pressao: smoothData['pressao']!,
      lat: smoothData['lat']!,
      lng: smoothData['lng']!,
      gyroZ: gyroZ,
      accelX: accelX,
      accelY: accelY,
      timestamp: DateTime.now(),
    );
  }

  /// 📊 Calcula variômetro (apenas a cada 500ms)
  double _calculateVario(double altitude) {
    final timeNow = DateTime.now().millisecondsSinceEpoch;

    if (_firstVarioCalc) {
      _altitudePrevious = altitude;
      _timePrevious = timeNow;
      _varioSmooth = 0;
      _firstVarioCalc = false;
      return 0;
    }

    final deltaTime = timeNow - _timePrevious;

    // ✅ SÓ CALCULAR se passou intervalo mínimo
    if (deltaTime >= _varioCalcInterval) {
      final deltaAltitude = altitude - _altitudePrevious;
      final varioInstant = (deltaAltitude * 1000.0) / deltaTime; // m/s
      _varioSmooth = _varioAlpha * varioInstant + (1 - _varioAlpha) * _varioSmooth;

      _altitudePrevious = altitude;
      _timePrevious = timeNow;

      return _varioSmooth;
    }

    // Mantém valor anterior
    return state.vario;
  }

  /// 🔧 Helper: Converte para double seguro
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// 🔄 Reset do variômetro (para recalibração)
  void resetVario() {
    _firstVarioCalc = true;
    _varioSmooth = 0;
  }
}