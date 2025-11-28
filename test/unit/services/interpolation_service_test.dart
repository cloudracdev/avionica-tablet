import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/models/telemetry_data.dart';
import 'package:qfly_avionica/services/interpolation/interpolation_service.dart';

void main() {
  group('InterpolationService', () {
    late InterpolationService service;

    setUp(() {
      service = InterpolationService();
    });

    group('initialization', () {
      test('should return initial data when not initialized', () {
        final result = service.getInterpolated();
        expect(result.velocidade, 0);
        expect(result.altitude, 0);
      });

      test('should snap to first target immediately', () {
        final target = _createTelemetry(velocidade: 100, altitude: 500);
        service.setTarget(target);
        final result = service.getInterpolated();
        expect(result.velocidade, 100);
        expect(result.altitude, 500);
      });

      test('should not be stale after setTarget', () {
        service.setTarget(_createTelemetry());
        expect(service.isStale, false);
      });
    });

    group('linear interpolation', () {
      test('should interpolate velocidade towards target', () {
        service.setTarget(_createTelemetry(velocidade: 0));
        service.getInterpolated();
        service.setTarget(_createTelemetry(velocidade: 100));
        final result = service.getInterpolated();
        expect(result.velocidade, greaterThan(0));
        expect(result.velocidade, lessThan(100));
      });

      test('should converge to target over multiple frames', () {
        service.setTarget(_createTelemetry(velocidade: 0));
        service.getInterpolated();
        service.setTarget(_createTelemetry(velocidade: 100));
        TelemetryData result = TelemetryData.initial();
        for (int i = 0; i < 100; i++) {
          result = service.getInterpolated();
        }
        expect(result.velocidade, closeTo(100, 1.0));
      });
    });

    group('circular interpolation (heading)', () {
      test('should take shortest path from 350 to 10 degrees', () {
        service.setTarget(_createTelemetry(heading: 350));
        service.getInterpolated();
        service.setTarget(_createTelemetry(heading: 10));
        for (int i = 0; i < 5; i++) {
          service.getInterpolated();
        }
        final result = service.getInterpolated();
        expect(result.heading > 350 || result.heading < 30, true);
      });
    });

    group('spring interpolation', () {
      test('should interpolate pitch with spring physics', () async {
        service.setTarget(_createTelemetry(pitch: 0));
        service.getInterpolated();
        
        // Wait to allow deltaTime > 0
        await Future.delayed(const Duration(milliseconds: 20));
        
        service.setTarget(_createTelemetry(pitch: 30));
        
        // Multiple frames with delay to accumulate spring movement
        TelemetryData result = TelemetryData.initial();
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 16));
          result = service.getInterpolated();
        }
        
        expect(result.pitch, greaterThan(0));
        expect(result.pitch, lessThan(30));
      });

      test('should interpolate roll with spring physics', () async {
        service.setTarget(_createTelemetry(roll: 0));
        service.getInterpolated();
        
        await Future.delayed(const Duration(milliseconds: 20));
        
        service.setTarget(_createTelemetry(roll: 45));
        
        TelemetryData result = TelemetryData.initial();
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 16));
          result = service.getInterpolated();
        }
        
        expect(result.roll, greaterThan(0));
        expect(result.roll, lessThan(45));
      });
    });

    group('stale detection', () {
      test('should become stale after timeout', () async {
        service.setTarget(_createTelemetry());
        expect(service.isStale, false);
        await Future.delayed(const Duration(milliseconds: 3100));
        expect(service.isStale, true);
      });
    });

    group('reset', () {
      test('should reset all values to initial', () {
        service.setTarget(_createTelemetry(velocidade: 100, altitude: 500));
        service.getInterpolated();
        service.reset();
        final result = service.getInterpolated();
        expect(result.velocidade, 0);
        expect(result.altitude, 0);
      });
    });
  });
}

TelemetryData _createTelemetry({
  double velocidade = 0,
  double altitude = 0,
  double heading = 0,
  double pitch = 0,
  double roll = 0,
  double vario = 0,
  double temperatura = 20,
  double pressao = 101325,
  double lat = -25.4284,
  double lng = -49.2733,
  double gyroZ = 0,
  double accelX = 0,
  double accelY = 0,
}) {
  return TelemetryData(
    velocidade: velocidade,
    altitude: altitude,
    heading: heading,
    pitch: pitch,
    roll: roll,
    vario: vario,
    temperatura: temperatura,
    pressao: pressao,
    lat: lat,
    lng: lng,
    gyroZ: gyroZ,
    accelX: accelX,
    accelY: accelY,
    timestamp: DateTime.now(),
    gpsValid: true,
  );
}
