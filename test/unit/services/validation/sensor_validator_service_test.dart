import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/services/validation/sensor_validator_service.dart';

void main() {
  group('SensorValidatorService', () {
    
    group('isValidGPS', () {
      test('deve aceitar coordenadas válidas Brasil', () {
        expect(SensorValidatorService.isValidGPS(-25.4284, -49.2733), isTrue);
      });

      test('deve aceitar coordenadas válidas extremas', () {
        expect(SensorValidatorService.isValidGPS(-90.0, -180.0), isTrue);
        expect(SensorValidatorService.isValidGPS(90.0, 180.0), isTrue);
      });

      test('deve rejeitar coordenadas zero', () {
        expect(SensorValidatorService.isValidGPS(0.0, 0.0), isFalse);
      });

      test('deve aceitar coordenadas com precisão válida', () {
        expect(SensorValidatorService.isValidGPS(0.001, 0.001), isTrue);
      });
    });

    group('isValidVelocidade', () {
      test('deve aceitar velocidade zero', () {
        expect(SensorValidatorService.isValidVelocidade(0.0), isTrue);
      });

      test('deve aceitar velocidade típica', () {
        expect(SensorValidatorService.isValidVelocidade(120.0), isTrue);
      });

      test('deve aceitar velocidade máxima', () {
        expect(SensorValidatorService.isValidVelocidade(500.0), isTrue);
      });

      test('deve rejeitar velocidade negativa', () {
        expect(SensorValidatorService.isValidVelocidade(-1.0), isFalse);
      });

      test('deve rejeitar velocidade acima do máximo', () {
        expect(SensorValidatorService.isValidVelocidade(501.0), isFalse);
      });
    });

    group('isValidAltitude', () {
      test('deve aceitar altitude zero', () {
        expect(SensorValidatorService.isValidAltitude(0.0), isTrue);
      });

      test('deve aceitar altitude negativa', () {
        expect(SensorValidatorService.isValidAltitude(-500.0), isTrue);
      });

      test('deve aceitar altitude máxima', () {
        expect(SensorValidatorService.isValidAltitude(10000.0), isTrue);
      });

      test('deve rejeitar altitude abaixo do mínimo', () {
        expect(SensorValidatorService.isValidAltitude(-501.0), isFalse);
      });

      test('deve rejeitar altitude acima do máximo', () {
        expect(SensorValidatorService.isValidAltitude(10001.0), isFalse);
      });
    });

    group('isValidHeading', () {
      test('deve aceitar heading zero', () {
        expect(SensorValidatorService.isValidHeading(0.0), isTrue);
      });

      test('deve aceitar heading cardeal', () {
        expect(SensorValidatorService.isValidHeading(90.0), isTrue);
        expect(SensorValidatorService.isValidHeading(180.0), isTrue);
        expect(SensorValidatorService.isValidHeading(270.0), isTrue);
      });

      test('deve aceitar heading máximo', () {
        expect(SensorValidatorService.isValidHeading(360.0), isTrue);
      });

      test('deve rejeitar heading negativo', () {
        expect(SensorValidatorService.isValidHeading(-1.0), isFalse);
      });

      test('deve rejeitar heading acima de 360', () {
        expect(SensorValidatorService.isValidHeading(361.0), isFalse);
      });
    });

    group('isValidPitch', () {
      test('deve aceitar pitch zero', () {
        expect(SensorValidatorService.isValidPitch(0.0), isTrue);
      });

      test('deve aceitar pitch positivo', () {
        expect(SensorValidatorService.isValidPitch(45.0), isTrue);
      });

      test('deve aceitar pitch negativo', () {
        expect(SensorValidatorService.isValidPitch(-45.0), isTrue);
      });

      test('deve aceitar pitch extremo', () {
        expect(SensorValidatorService.isValidPitch(90.0), isTrue);
        expect(SensorValidatorService.isValidPitch(-90.0), isTrue);
      });

      test('deve rejeitar pitch fora do range', () {
        expect(SensorValidatorService.isValidPitch(91.0), isFalse);
        expect(SensorValidatorService.isValidPitch(-91.0), isFalse);
      });
    });

    group('isValidRoll', () {
      test('deve aceitar roll zero', () {
        expect(SensorValidatorService.isValidRoll(0.0), isTrue);
      });

      test('deve aceitar roll típico de curva', () {
        expect(SensorValidatorService.isValidRoll(30.0), isTrue);
        expect(SensorValidatorService.isValidRoll(-30.0), isTrue);
      });

      test('deve aceitar roll extremo', () {
        expect(SensorValidatorService.isValidRoll(180.0), isTrue);
        expect(SensorValidatorService.isValidRoll(-180.0), isTrue);
      });

      test('deve rejeitar roll fora do range', () {
        expect(SensorValidatorService.isValidRoll(181.0), isFalse);
        expect(SensorValidatorService.isValidRoll(-181.0), isFalse);
      });
    });

    group('isValidVario', () {
      test('deve aceitar vario zero', () {
        expect(SensorValidatorService.isValidVario(0.0), isTrue);
      });

      test('deve aceitar vario positivo', () {
        expect(SensorValidatorService.isValidVario(15.0), isTrue);
      });

      test('deve aceitar vario negativo', () {
        expect(SensorValidatorService.isValidVario(-15.0), isTrue);
      });

      test('deve aceitar vario extremo', () {
        expect(SensorValidatorService.isValidVario(30.0), isTrue);
        expect(SensorValidatorService.isValidVario(-30.0), isTrue);
      });

      test('deve rejeitar vario fora do range', () {
        expect(SensorValidatorService.isValidVario(31.0), isFalse);
        expect(SensorValidatorService.isValidVario(-31.0), isFalse);
      });
    });

    group('isValidTemperatura', () {
      test('deve aceitar temperatura ambiente', () {
        expect(SensorValidatorService.isValidTemperatura(25.0), isTrue);
      });

      test('deve aceitar temperatura fria', () {
        expect(SensorValidatorService.isValidTemperatura(-30.0), isTrue);
        expect(SensorValidatorService.isValidTemperatura(-50.0), isTrue);
      });

      test('deve aceitar temperatura quente', () {
        expect(SensorValidatorService.isValidTemperatura(40.0), isTrue);
        expect(SensorValidatorService.isValidTemperatura(60.0), isTrue);
      });

      test('deve rejeitar temperatura fora do range', () {
        expect(SensorValidatorService.isValidTemperatura(-51.0), isFalse);
        expect(SensorValidatorService.isValidTemperatura(61.0), isFalse);
      });
    });

    group('isValidPressao', () {
      test('deve aceitar pressão ao nível do mar', () {
        expect(SensorValidatorService.isValidPressao(101325.0), isTrue);
      });

      test('deve aceitar pressão em altitude', () {
        expect(SensorValidatorService.isValidPressao(70000.0), isTrue);
        expect(SensorValidatorService.isValidPressao(50000.0), isTrue);
      });

      test('deve aceitar pressão alta', () {
        expect(SensorValidatorService.isValidPressao(110000.0), isTrue);
      });

      test('deve rejeitar pressão fora do range', () {
        expect(SensorValidatorService.isValidPressao(49999.0), isFalse);
        expect(SensorValidatorService.isValidPressao(110001.0), isFalse);
      });
    });

    group('isValidGyroZ', () {
      test('deve aceitar gyro zero', () {
        expect(SensorValidatorService.isValidGyroZ(0.0), isTrue);
      });

      test('deve aceitar gyro típico', () {
        expect(SensorValidatorService.isValidGyroZ(30.0), isTrue);
        expect(SensorValidatorService.isValidGyroZ(-30.0), isTrue);
      });

      test('deve aceitar gyro extremo', () {
        expect(SensorValidatorService.isValidGyroZ(360.0), isTrue);
        expect(SensorValidatorService.isValidGyroZ(-360.0), isTrue);
      });

      test('deve rejeitar gyro fora do range', () {
        expect(SensorValidatorService.isValidGyroZ(361.0), isFalse);
        expect(SensorValidatorService.isValidGyroZ(-361.0), isFalse);
      });
    });

    group('isValidAccelX', () {
      test('deve aceitar accel zero', () {
        expect(SensorValidatorService.isValidAccelX(0.0), isTrue);
      });

      test('deve aceitar accel normal', () {
        expect(SensorValidatorService.isValidAccelX(1.0), isTrue);
        expect(SensorValidatorService.isValidAccelX(-1.0), isTrue);
      });

      test('deve aceitar accel extremo', () {
        expect(SensorValidatorService.isValidAccelX(5.0), isTrue);
        expect(SensorValidatorService.isValidAccelX(-5.0), isTrue);
      });

      test('deve rejeitar accel fora do range', () {
        expect(SensorValidatorService.isValidAccelX(5.1), isFalse);
        expect(SensorValidatorService.isValidAccelX(-5.1), isFalse);
      });
    });

    group('isValidAccelY', () {
      test('deve aceitar accel zero', () {
        expect(SensorValidatorService.isValidAccelY(0.0), isTrue);
      });

      test('deve aceitar accel normal', () {
        expect(SensorValidatorService.isValidAccelY(1.0), isTrue);
        expect(SensorValidatorService.isValidAccelY(-1.0), isTrue);
      });

      test('deve aceitar accel extremo', () {
        expect(SensorValidatorService.isValidAccelY(5.0), isTrue);
        expect(SensorValidatorService.isValidAccelY(-5.0), isTrue);
      });

      test('deve rejeitar accel fora do range', () {
        expect(SensorValidatorService.isValidAccelY(5.1), isFalse);
        expect(SensorValidatorService.isValidAccelY(-5.1), isFalse);
      });
    });

    group('getGpsStatusMessage', () {
      test('deve retornar mensagem OK para GPS válido', () {
        expect(SensorValidatorService.getGpsStatusMessage(true), contains('OK'));
      });

      test('deve retornar mensagem erro para GPS inválido', () {
        expect(SensorValidatorService.getGpsStatusMessage(false), contains('sem sinal'));
      });
    });
  });
}