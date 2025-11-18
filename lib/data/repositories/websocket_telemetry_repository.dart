import 'dart:async';
import '../../models/flight_data.dart';
import '../../services/websocket/websocket_service.dart';
import '../../services/validation/sensor_validator_service.dart';
import '../../core/utils/logger.dart';
import 'telemetry_repository.dart';

/// 🌐 REPOSITORY: Implementação WebSocket
/// 
/// Obtém telemetria do ESP32 via WebSocket com validação completa de sensores
class WebSocketTelemetryRepository implements TelemetryRepository {
  final WebSocketService _wsService;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  final _controller = StreamController<FlightData>.broadcast();

  // 🛡️ Últimos valores válidos para fallback individual por sensor
  double _lastValidLat = 0.0;
  double _lastValidLng = 0.0;
  double _lastValidVelocidade = 0.0;
  double _lastValidAltitude = 0.0;
  double _lastValidHeading = 0.0;
  double _lastValidPitch = 0.0;
  double _lastValidRoll = 0.0;
  double _lastValidVario = 0.0;
  double _lastValidTemperatura = 0.0;
  double _lastValidPressao = 101325.0; // 1013.25 hPa padrão
  double _lastValidGyroZ = 0.0;
  double _lastValidAccelX = 0.0;
  double _lastValidAccelY = 0.0;
  
  bool _hasValidGpsHistory = false;
  bool _hasValidHistory = false;

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
    // Reset history on disconnect
    _hasValidGpsHistory = false;
    _hasValidHistory = false;
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
  /// 🛡️ Com validação COMPLETA de sensores e fallback individual
  FlightData _convertToFlightData(Map<String, dynamic> data) {
    try {
      // 📥 RECEBER dados brutos
      final rawLat = _toDouble(data['lat']);
      final rawLng = _toDouble(data['lng']);
      final rawVelocidade = _toDouble(data['velocidade']);
      final rawAltitude = _toDouble(data['altitude']);
      final rawHeading = _toDouble(data['heading']);
      final rawPitch = _toDouble(data['pitch']);
      final rawRoll = _toDouble(data['roll']);
      final rawVario = 0.0; // Calculado no provider
      final rawTemperatura = _toDouble(data['temperatura']);
      final rawPressao = _toDouble(data['pressao']);
      final rawGyroZ = _toDouble(data['lsm_gz']);
      final rawAccelX = _toDouble(data['lsm_ax']);
      final rawAccelY = _toDouble(data['lsm_ay']);

      // 🔍 VALIDAR cada sensor individualmente
      final isGpsValid = SensorValidatorService.isValidGPS(rawLat, rawLng);
      final isVelocidadeValid = SensorValidatorService.isValidVelocidade(rawVelocidade);
      final isAltitudeValid = SensorValidatorService.isValidAltitude(rawAltitude);
      final isHeadingValid = SensorValidatorService.isValidHeading(rawHeading);
      final isPitchValid = SensorValidatorService.isValidPitch(rawPitch);
      final isRollValid = SensorValidatorService.isValidRoll(rawRoll);
      final isVarioValid = SensorValidatorService.isValidVario(rawVario);
      final isTemperaturaValid = SensorValidatorService.isValidTemperatura(rawTemperatura);
      final isPressaoValid = SensorValidatorService.isValidPressao(rawPressao);
      final isGyroZValid = SensorValidatorService.isValidGyroZ(rawGyroZ);
      final isAccelXValid = SensorValidatorService.isValidAccelX(rawAccelX);
      final isAccelYValid = SensorValidatorService.isValidAccelY(rawAccelY);

      // 🛡️ APLICAR FALLBACK individual para cada sensor inválido
      
      // GPS
      double finalLat = rawLat;
      double finalLng = rawLng;
      if (!isGpsValid && _hasValidGpsHistory) {
        finalLat = _lastValidLat;
        finalLng = _lastValidLng;
      } else if (isGpsValid) {
        _lastValidLat = rawLat;
        _lastValidLng = rawLng;
        _hasValidGpsHistory = true;
      }

      // Velocidade
      double finalVelocidade = rawVelocidade;
      if (!isVelocidadeValid && _hasValidHistory) {
        finalVelocidade = _lastValidVelocidade;
      } else if (isVelocidadeValid) {
        _lastValidVelocidade = rawVelocidade;
      }

      // Altitude
      double finalAltitude = rawAltitude;
      if (!isAltitudeValid && _hasValidHistory) {
        finalAltitude = _lastValidAltitude;
      } else if (isAltitudeValid) {
        _lastValidAltitude = rawAltitude;
      }

      // Heading
      double finalHeading = rawHeading;
      if (!isHeadingValid && _hasValidHistory) {
        finalHeading = _lastValidHeading;
      } else if (isHeadingValid) {
        _lastValidHeading = rawHeading;
      }

      // Pitch
      double finalPitch = rawPitch;
      if (!isPitchValid && _hasValidHistory) {
        finalPitch = _lastValidPitch;
      } else if (isPitchValid) {
        _lastValidPitch = rawPitch;
      }

      // Roll
      double finalRoll = rawRoll;
      if (!isRollValid && _hasValidHistory) {
        finalRoll = _lastValidRoll;
      } else if (isRollValid) {
        _lastValidRoll = rawRoll;
      }

      // Vario
      double finalVario = rawVario;
      if (!isVarioValid && _hasValidHistory) {
        finalVario = _lastValidVario;
      } else if (isVarioValid) {
        _lastValidVario = rawVario;
      }

      // Temperatura
      double finalTemperatura = rawTemperatura;
      if (!isTemperaturaValid && _hasValidHistory) {
        finalTemperatura = _lastValidTemperatura;
      } else if (isTemperaturaValid) {
        _lastValidTemperatura = rawTemperatura;
      }

      // Pressão
      double finalPressao = rawPressao;
      if (!isPressaoValid && _hasValidHistory) {
        finalPressao = _lastValidPressao;
      } else if (isPressaoValid) {
        _lastValidPressao = rawPressao;
      }

      // GyroZ
      double finalGyroZ = rawGyroZ;
      if (!isGyroZValid && _hasValidHistory) {
        finalGyroZ = _lastValidGyroZ;
      } else if (isGyroZValid) {
        _lastValidGyroZ = rawGyroZ;
      }

      // AccelX
      double finalAccelX = rawAccelX;
      if (!isAccelXValid && _hasValidHistory) {
        finalAccelX = _lastValidAccelX;
      } else if (isAccelXValid) {
        _lastValidAccelX = rawAccelX;
      }

      // AccelY
      double finalAccelY = rawAccelY;
      if (!isAccelYValid && _hasValidHistory) {
        finalAccelY = _lastValidAccelY;
      } else if (isAccelYValid) {
        _lastValidAccelY = rawAccelY;
      }

      // ✅ Marcar que temos histórico válido após primeiro pacote válido
      if (!_hasValidHistory && (isVelocidadeValid || isAltitudeValid)) {
        _hasValidHistory = true;
      }

      // 📦 CRIAR FlightData com valores validados/fallback
      return FlightData(
        velocidade: finalVelocidade,
        altitude: finalAltitude,
        heading: finalHeading,
        pitch: finalPitch,
        roll: finalRoll,
        vario: finalVario,
        temperatura: finalTemperatura,
        pressao: finalPressao,
        lat: finalLat,
        lng: finalLng,
        gyroZ: finalGyroZ,
        accelX: finalAccelX,
        accelY: finalAccelY,
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