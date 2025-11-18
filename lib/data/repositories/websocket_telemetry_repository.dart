import 'dart:async';
import '../../models/flight_data.dart';
import '../../services/websocket/websocket_service.dart';
import '../../services/validation/gps_validator_service.dart';
import '../../core/utils/logger.dart';
import 'telemetry_repository.dart';

/// 🌐 REPOSITORY: Implementação WebSocket
/// 
/// Obtém telemetria do ESP32 via WebSocket
class WebSocketTelemetryRepository implements TelemetryRepository {
  final WebSocketService _wsService;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  final _controller = StreamController<FlightData>.broadcast();

  // 🛡️ Última posição GPS válida para fallback
  double _lastValidLat = 0.0;
  double _lastValidLng = 0.0;
  bool _hasValidGpsHistory = false;

  WebSocketTelemetryRepository(this._wsService);

  @override
  Stream<FlightData> getFlightDataStream() {
    // Converte stream do WebSocket para FlightData
    _subscription ??= _wsService.dataStream.listen(
      (rawData) {
        try {
          // 🛡️ ERROR BOUNDARY: Conversão com try-catch
          final flightData = _convertToFlightData(rawData);
          _controller.add(flightData);
        } catch (e, stackTrace) {
          Logger.error(
            '❌ Erro ao converter FlightData',
            e,
            stackTrace,
            'Repository',
          );
          // Não propaga erro, apenas ignora pacote ruim
        }
      },
      onError: (error) {
        Logger.error('❌ Erro no stream WebSocket', error, null, 'Repository');
        // Stream continua mesmo com erro
      },
      cancelOnError: false, // 🛡️ Não cancela stream em erro
    );

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
    // Reset GPS history on disconnect
    _hasValidGpsHistory = false;
    _lastValidLat = 0.0;
    _lastValidLng = 0.0;
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
  /// 🛡️ Com validação GPS e fallback para última posição válida
  FlightData _convertToFlightData(Map<String, dynamic> data) {
    try {
      final lat = _toDouble(data['lat']);
      final lng = _toDouble(data['lng']);

      // 🌍 VALIDAÇÃO GPS: Verifica se coordenadas são válidas
      final isGpsValid = GpsValidatorService.isValidGPS(lat, lng);

      // 🛡️ FALLBACK: Se GPS inválido, usar última posição válida
      double finalLat = lat;
      double finalLng = lng;
      
      if (!isGpsValid && _hasValidGpsHistory) {
        finalLat = _lastValidLat;
        finalLng = _lastValidLng;
        Logger.warning(
          '⚠️ GPS inválido, usando última posição válida: '
          '($finalLat, $finalLng)',
          'Repository',
        );
      } else if (isGpsValid) {
        // Salvar coordenadas válidas para fallback futuro
        _lastValidLat = lat;
        _lastValidLng = lng;
        _hasValidGpsHistory = true;
      }

      return FlightData(
        velocidade: _toDouble(data['velocidade']),
        altitude: _toDouble(data['altitude']),
        heading: _toDouble(data['heading']),
        pitch: _toDouble(data['pitch']),
        roll: _toDouble(data['roll']),
        vario: 0.0, // Será calculado no provider
        temperatura: _toDouble(data['temperatura']),
        pressao: _toDouble(data['pressao']),
        lat: finalLat,
        lng: finalLng,
        gyroZ: _toDouble(data['lsm_gz']),
        accelX: _toDouble(data['lsm_ax']),
        accelY: _toDouble(data['lsm_ay']),
        timestamp: DateTime.now(),
        gpsValid: isGpsValid,
      );
    } catch (e) {
      Logger.warning('⚠️ Erro na conversão, usando FlightData.zero()', 'Repository');
      // 🛡️ Fallback: retorna dados zerados em vez de crashar
      return FlightData.zero();
    }
  }

  /// 🔧 Helper: Converte para double seguro
  /// 🛡️ Retorna 0.0 se conversão falhar
  double _toDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null && parsed.isFinite) {
          return parsed;
        }
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}