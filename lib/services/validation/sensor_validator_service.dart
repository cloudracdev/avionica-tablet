import '../../core/constants/sensor_constants.dart';
import '../../core/utils/logger.dart';

/// 🔍 SERVICE: Validação completa de sensores
/// 
/// Valida ranges de TODOS os sensores da aeronave
class SensorValidatorService {
  
  // 🌍 GPS: Validação de coordenadas (7+ casas decimais)
  static bool isValidGPS(double lat, double lng) {
    try {
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
          'SensorValidator',
        );
      }

      return isValid;
    } catch (e) {
      Logger.error('❌ Erro na validação GPS', e, null, 'SensorValidator');
      return false;
    }
  }

  // 🚀 Velocidade: 0 a 500 km/h
  static bool isValidVelocidade(double velocidade) {
    final isValid = velocidade >= SensorConstants.velocidadeMin &&
        velocidade <= SensorConstants.velocidadeMax;
    
    if (!isValid) {
      Logger.warning(
        '⚠️ Velocidade inválida: $velocidade km/h (range: ${SensorConstants.velocidadeMin}-${SensorConstants.velocidadeMax})',
        'SensorValidator',
      );
    }
    
    return isValid;
  }

  // 📏 Altitude: -500 a 10.000 m
  static bool isValidAltitude(double altitude) {
    final isValid = altitude >= SensorConstants.altitudeMin &&
        altitude <= SensorConstants.altitudeMax;
    
    if (!isValid) {
      Logger.warning(
        '⚠️ Altitude inválida: $altitude m (range: ${SensorConstants.altitudeMin}-${SensorConstants.altitudeMax})',
        'SensorValidator',
      );
    }
    
    return isValid;
  }

  // 🧭 Heading: 0 a 360°
  static bool isValidHeading(double heading) {
    final isValid = heading >= SensorConstants.headingMin &&
        heading <= SensorConstants.headingMax;
    
    if (!isValid) {
      Logger.warning(
        '⚠️ Heading inválido: $heading° (range: ${SensorConstants.headingMin}-${SensorConstants.headingMax})',
        'SensorValidator',
      );
    }
    
    return isValid;
  }

  // 📐 Pitch: -90 a +90°
  static bool isValidPitch(double pitch) {
    final isValid = pitch >= SensorConstants.pitchMin &&
        pitch <= SensorConstants.pitchMax;
    
    if (!isValid) {
      Logger.warning(
        '⚠️ Pitch inválido: $pitch° (range: ${SensorConstants.pitchMin}-${SensorConstants.pitchMax})',
        'SensorValidator',
      );
    }
    
    return isValid;
  }

  // 🔄 Roll: -180 a +180°
  static bool isValidRoll(double roll) {
    final isValid = roll >= SensorConstants.rollMin &&
        roll <= SensorConstants.rollMax;
    
    if (!isValid) {
      Logger.warning(
        '⚠️ Roll inválido: $roll° (range: ${SensorConstants.rollMin}-${SensorConstants.rollMax})',
        'SensorValidator',
      );
    }
    
    return isValid;
  }

  // 📊 Vario: -30 a +30 m/s
  static bool isValidVario(double vario) {
    final isValid = vario >= SensorConstants.varioMin &&
        vario <= SensorConstants.varioMax;
    
    if (!isValid) {
      Logger.warning(
        '⚠️ Vario inválido: $vario m/s (range: ${SensorConstants.varioMin}-${SensorConstants.varioMax})',
        'SensorValidator',
      );
    }
    
    return isValid;
  }

  // 🌡️ Temperatura: -50 a +60°C
  static bool isValidTemperatura(double temperatura) {
    final isValid = temperatura >= SensorConstants.temperaturaMin &&
        temperatura <= SensorConstants.temperaturaMax;
    
    if (!isValid) {
      Logger.warning(
        '⚠️ Temperatura inválida: $temperatura°C (range: ${SensorConstants.temperaturaMin}-${SensorConstants.temperaturaMax})',
        'SensorValidator',
      );
    }
    
    return isValid;
  }

  // 🌪️ Pressão: 50.000 a 110.000 Pa
  static bool isValidPressao(double pressao) {
    final isValid = pressao >= SensorConstants.pressaoMin &&
        pressao <= SensorConstants.pressaoMax;
    
    if (!isValid) {
      Logger.warning(
        '⚠️ Pressão inválida: $pressao Pa (range: ${SensorConstants.pressaoMin}-${SensorConstants.pressaoMax})',
        'SensorValidator',
      );
    }
    
    return isValid;
  }

  // 🎮 GyroZ: -360 a +360 °/s
  static bool isValidGyroZ(double gyroZ) {
    final isValid = gyroZ >= SensorConstants.gyroZMin &&
        gyroZ <= SensorConstants.gyroZMax;
    
    if (!isValid) {
      Logger.warning(
        '⚠️ GyroZ inválido: $gyroZ°/s (range: ${SensorConstants.gyroZMin}-${SensorConstants.gyroZMax})',
        'SensorValidator',
      );
    }
    
    return isValid;
  }

  // 📈 Aceleração X: -5 a +5 g
  static bool isValidAccelX(double accelX) {
    final isValid = accelX >= SensorConstants.accelMin &&
        accelX <= SensorConstants.accelMax;
    
    if (!isValid) {
      Logger.warning(
        '⚠️ AccelX inválido: ${accelX}g (range: ${SensorConstants.accelMin}-${SensorConstants.accelMax})',
        'SensorValidator',
      );
    }
    
    return isValid;
  }

  // 📉 Aceleração Y: -5 a +5 g
  static bool isValidAccelY(double accelY) {
    final isValid = accelY >= SensorConstants.accelMin &&
        accelY <= SensorConstants.accelMax;
    
    if (!isValid) {
      Logger.warning(
        '⚠️ AccelY inválido: ${accelY}g (range: ${SensorConstants.accelMin}-${SensorConstants.accelMax})',
        'SensorValidator',
      );
    }
    
    return isValid;
  }

  /// 📝 Retorna mensagem de status do GPS para UI
  static String getGpsStatusMessage(bool isValid) {
    return isValid ? '✅ GPS OK' : '⚠️ GPS sem sinal';
  }
}