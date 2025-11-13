import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/services/calibration/calibration_service.dart';

void main() {
  group('CalibrationService Tests', () {
    late CalibrationService service;

    setUp(() {
      service = CalibrationService();
    });

    test('zeroPitch deve zerar pitch atual', () {
      service.zeroPitch(5.0);
      
      final calibrated = service.applyCalibratedPitch(5.0);
      
      expect(calibrated, equals(0.0));
      expect(service.pitchOffset, equals(-5.0));
    });

    test('zeroRoll deve zerar roll atual', () {
      service.zeroRoll(-3.0);
      
      final calibrated = service.applyCalibratedRoll(-3.0);
      
      expect(calibrated, equals(0.0));
      expect(service.rollOffset, equals(3.0));
    });

    test('zeroAltitude deve zerar altitude atual (QFE)', () {
      service.zeroAltitude(856.0); // Altitude de Curitiba
      
      final calibrated = service.applyCalibratedAltitude(856.0);
      
      expect(calibrated, equals(0.0));
      expect(service.altitudeOffset, equals(-856.0));
    });

    test('calibrateHeading deve corrigir erro de bússola', () {
      // Bússola mostra 90°, mas real é 95°
      service.calibrateHeading(95.0, 90.0);
      
      final calibrated = service.applyCalibratedHeading(90.0);
      
      expect(calibrated, equals(95.0));
      expect(service.headingOffset, equals(5.0));
    });

    test('applyCalibratedHeading deve normalizar 0-360', () {
      service.calibrateHeading(10.0, 350.0);
      
      final calibrated = service.applyCalibratedHeading(350.0);
      
      expect(calibrated, equals(10.0));
      expect(calibrated, greaterThanOrEqualTo(0.0));
      expect(calibrated, lessThan(360.0));
    });

    test('applyCalibratedHeading com wrap negativo', () {
      // Offset que resulta em valor negativo
      service.calibrateHeading(5.0, 10.0);
      
      final calibrated = service.applyCalibratedHeading(2.0);
      
      expect(calibrated, greaterThanOrEqualTo(0.0));
      expect(calibrated, lessThan(360.0));
    });

    test('applyCalibratedHeading com wrap positivo', () {
      // Offset que resulta em valor > 360
      service.calibrateHeading(5.0, 0.0);
      
      final calibrated = service.applyCalibratedHeading(358.0);
      
      expect(calibrated, greaterThanOrEqualTo(0.0));
      expect(calibrated, lessThan(360.0));
    });

    test('resetAll deve zerar todos os offsets', () {
      service.calibrateHeading(95.0, 90.0);
      service.zeroPitch(5.0);
      service.zeroRoll(-3.0);
      service.zeroAltitude(856.0);
      
      service.resetAll();
      
      expect(service.headingOffset, equals(0.0));
      expect(service.pitchOffset, equals(0.0));
      expect(service.rollOffset, equals(0.0));
      expect(service.altitudeOffset, equals(0.0));
    });

    test('múltiplas calibrações devem sobrescrever', () {
      service.zeroPitch(5.0);
      service.zeroPitch(10.0);
      
      expect(service.pitchOffset, equals(-10.0));
    });
  });
}