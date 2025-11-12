import 'dart:async';
import '../../models/flight_data.dart';
import '../../services/websocket/websocket_service.dart';
import 'telemetry_repository.dart';

/// 🌐 REPOSITORY: Implementação WebSocket
/// 
/// Obtém telemetria do ESP32 via WebSocket
class WebSocketTelemetryRepository implements TelemetryRepository {
  final WebSocketService _wsService;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  final _controller = StreamController<FlightData>.broadcast();

  WebSocketTelemetryRepository(this._wsService);

  @override
  Stream<FlightData> getFlightDataStream() {
    // Converte stream do WebSocket para FlightData
    _subscription ??= _wsService.dataStream.listen((rawData) {
      final flightData = _convertToFlightData(rawData);
      _controller.add(flightData);
    });

    return _controller.stream;
  }

  @override
  Future<void> connect(String address) async {
    _wsService.connect(address);
    // Aguarda conexão estabilizar
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  void disconnect() {
    _wsService.disconnect();
  }

  @override
  bool get isConnected => _wsService.isConnected;

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
    _wsService.dispose();
  }

  /// 🔄 Converte Map<String, dynamic> → FlightData
  FlightData _convertToFlightData(Map<String, dynamic> data) {
    return FlightData(
      velocidade: _toDouble(data['velocidade']),
      altitude: _toDouble(data['altitude']),
      heading: _toDouble(data['heading']),
      pitch: _toDouble(data['pitch']),
      roll: _toDouble(data['roll']),
      vario: 0.0, // Será calculado no provider
      temperatura: _toDouble(data['temperatura']),
      pressao: _toDouble(data['pressao']),
      lat: _toDouble(data['lat']),
      lng: _toDouble(data['lng']),
      gyroZ: _toDouble(data['lsm_gz']),
      accelX: _toDouble(data['lsm_ax']),
      accelY: _toDouble(data['lsm_ay']),
      timestamp: DateTime.now(),
    );
  }

  /// 🔧 Helper: Converte para double seguro
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}