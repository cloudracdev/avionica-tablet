import 'dart:async';
import 'dart:math';
import '../../models/flight_data.dart';
import 'telemetry_repository.dart';

/// 🎭 REPOSITORY: Mock para desenvolvimento sem hardware
/// 
/// Gera dados de voo simulados em tempo real
class MockTelemetryRepository implements TelemetryRepository {
  final _controller = StreamController<FlightData>.broadcast();
  Timer? _timer;
  bool _isConnected = false;
  
  // Valores base para simulação
  double _velocidade = 120.0;
  double _altitude = 1500.0;
  double _heading = 90.0;
  double _pitch = 0.0;
  double _roll = 0.0;
  
  final _random = Random();

  @override
  Stream<FlightData> getFlightDataStream() {
    return _controller.stream;
  }

  @override
  Future<void> connect(String address) async {
    _isConnected = true;
    
    // Gerar dados a cada 50ms (20Hz)
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _generateFlightData();
    });
  }

  @override
  void disconnect() {
    _isConnected = false;
    _timer?.cancel();
  }

  @override
  bool get isConnected => _isConnected;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }

  /// 🎲 Gera dados de voo simulados
  void _generateFlightData() {
    // Variação suave com noise
    _velocidade += (_random.nextDouble() - 0.5) * 2.0;
    _velocidade = _velocidade.clamp(100.0, 200.0);
    
    _altitude += (_random.nextDouble() - 0.5) * 5.0;
    _altitude = _altitude.clamp(1000.0, 2000.0);
    
    _heading += (_random.nextDouble() - 0.5) * 2.0;
    if (_heading < 0) _heading += 360;
    if (_heading >= 360) _heading -= 360;
    
    _pitch += (_random.nextDouble() - 0.5) * 1.0;
    _pitch = _pitch.clamp(-10.0, 10.0);
    
    _roll += (_random.nextDouble() - 0.5) * 2.0;
    _roll = _roll.clamp(-30.0, 30.0);
    
    final flightData = FlightData(
      velocidade: _velocidade,
      altitude: _altitude,
      heading: _heading,
      pitch: _pitch,
      roll: _roll,
      vario: (_random.nextDouble() - 0.5) * 3.0, // -1.5 a +1.5 m/s
      temperatura: 15.0 + (_random.nextDouble() * 2.0),
      pressao: 101325.0 + (_random.nextDouble() * 100.0),
      lat: -25.4284 + (_random.nextDouble() - 0.5) * 0.001,
      lng: -49.2733 + (_random.nextDouble() - 0.5) * 0.001,
      gyroZ: (_random.nextDouble() - 0.5) * 10.0,
      accelX: (_random.nextDouble() - 0.5) * 0.2,
      accelY: (_random.nextDouble() - 0.5) * 0.2,
      timestamp: DateTime.now(),
    );
    
    _controller.add(flightData);
  }
}