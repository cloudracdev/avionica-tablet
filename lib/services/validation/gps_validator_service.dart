import '../../core/constants/sensor_constants.dart';
import '../../core/utils/logger.dart';

/// 🌍 SERVICE: Validação de coordenadas GPS
/// 
/// Valida se GPS tem precisão mínima de 7 casas decimais
class GpsValidatorService {
  /// Valida se coordenadas GPS são válidas (7+ casas decimais)
  /// 
  /// Retorna `true` se ambas lat/lng têm precisão suficiente
  /// Retorna `false` se alguma coordenada for inválida (< 7 casas decimais)
  /// 
  /// Exemplos:
  /// ```dart
  /// isValidGPS(-25.4284567, -49.2733891) → true ✅
  /// isValidGPS(0.0, 0.0) → false ❌
  /// isValidGPS(0.0000001, 0.0000001) → false ❌
  /// isValidGPS(-25.42, -49.27) → true ✅ (ainda tem precisão)
  /// ```
  static bool isValidGPS(double lat, double lng) {
    try {
      // Multiplicar por 10^7 e verificar se valor absoluto > threshold
      final latPrecision = (lat * SensorConstants.gpsPrecisionMultiplier)
          .round()
          .abs();
      final lngPrecision = (lng * SensorConstants.gpsPrecisionMultiplier)
          .round()
          .abs();

      final isValid = latPrecision >= SensorConstants.gpsMinPrecision &&
          lngPrecision >= SensorConstants.gpsMinPrecision;

      if (!isValid) {
        Logger.warning(
          '⚠️ GPS inválido: lat=$lat (precision=$latPrecision), '
          'lng=$lng (precision=$lngPrecision)',
          'GpsValidator',
        );
      }

      return isValid;
    } catch (e) {
      Logger.error('❌ Erro na validação GPS', e, null, 'GpsValidator');
      return false;
    }
  }

  /// Retorna mensagem de status do GPS para UI
  static String getGpsStatusMessage(bool isValid) {
    return isValid ? '✅ GPS OK' : '⚠️ GPS sem sinal';
  }
}