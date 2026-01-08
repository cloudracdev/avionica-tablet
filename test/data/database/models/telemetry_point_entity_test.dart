import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/data/database/models/telemetry_point_entity.dart';
import 'package:qfly_avionica/models/telemetry_data.dart';

void main() {
  group('TelemetryPointEntity', () {
    group('fromTelemetryData', () {
      test('deve converter TelemetryData corretamente', () {
        final telemetryData = TelemetryData(
          velocidade: 120.5,
          altitude: 1500.0,
          heading: 270.0,
          pitch: 5.0,
          roll: -3.0,
          vario: 2.5,
          temperatura: 15.0,
          pressao: 101325.0,
          lat: -25.4284,
          lng: -49.2733,
          gyroZ: 0.5,
          accelX: 0.1,
          accelY: -0.05,
          timestamp: DateTime(2025, 1, 8, 12, 0, 0),
          gpsValid: true,
        );

        final entity = TelemetryPointEntity.fromTelemetryData(telemetryData, 'flight_123');

        expect(entity.flightSessionId, 'flight_123');
        expect(entity.lat, -25.4284);
        expect(entity.lng, -49.2733);
        expect(entity.velocity, 120.5);
        expect(entity.altitude, 1500.0);
        expect(entity.dataQuality, 'valid');
      });

      test('deve marcar fallback quando GPS inválido', () {
        final telemetryData = TelemetryData(
          velocidade: 0, altitude: 0, heading: 0, pitch: 0, roll: 0,
          vario: 0, temperatura: 0, pressao: 101325, lat: 0, lng: 0,
          gyroZ: 0, accelX: 0, accelY: 0, timestamp: DateTime.now(), gpsValid: false,
        );

        final entity = TelemetryPointEntity.fromTelemetryData(telemetryData, 'flight_123');

        expect(entity.dataQuality, 'fallback');
      });
    });

    group('toMap / fromMap', () {
      test('deve converter para Map e voltar sem perda', () {
        final original = TelemetryPointEntity(
          flightSessionId: 'flight_abc',
          timestamp: 1704715200000,
          lat: -25.4284,
          lng: -49.2733,
          velocity: 120.5,
          altitude: 1500.0,
          dataQuality: 'valid',
        );

        final map = original.toMap();
        final restored = TelemetryPointEntity.fromMap({...map, 'id': 1});

        expect(restored.flightSessionId, original.flightSessionId);
        expect(restored.timestamp, original.timestamp);
        expect(restored.lat, original.lat);
        expect(restored.velocity, original.velocity);
      });

      test('deve lidar com campos NULL', () {
        final entity = TelemetryPointEntity(
          flightSessionId: 'flight_123',
          timestamp: 1704715200000,
          lat: -25.4284,
          lng: -49.2733,
        );

        final map = entity.toMap();
        final restored = TelemetryPointEntity.fromMap(map);

        expect(restored.gpsAltitude, isNull);
        expect(restored.gpsSatellites, isNull);
      });
    });

    group('toTelemetryData', () {
      test('deve converter para TelemetryData', () {
        final entity = TelemetryPointEntity(
          flightSessionId: 'flight_123',
          timestamp: 1704715200000,
          lat: -25.4284,
          lng: -49.2733,
          velocity: 120.5,
          altitude: 1500.0,
          imuPitch: 5.0,
          imuRoll: -3.0,
          dataQuality: 'valid',
        );

        final telemetry = entity.toTelemetryData();

        expect(telemetry.velocidade, 120.5);
        expect(telemetry.altitude, 1500.0);
        expect(telemetry.gpsValid, true);
      });
    });

    group('validate', () {
      test('deve passar com dados válidos', () {
        final entity = TelemetryPointEntity(
          flightSessionId: 'flight_123',
          timestamp: 1704715200000,
          lat: -25.4284,
          lng: -49.2733,
        );

        expect(entity.isValid(), true);
      });

      test('deve falhar com flightSessionId vazio', () {
        final entity = TelemetryPointEntity(
          flightSessionId: '',
          timestamp: 1704715200000,
          lat: -25.4284,
          lng: -49.2733,
        );

        expect(entity.isValid(), false);
      });

      test('deve falhar com lat fora do range', () {
        final entity = TelemetryPointEntity(
          flightSessionId: 'flight_123',
          timestamp: 1704715200000,
          lat: -91.0,
          lng: -49.2733,
        );

        expect(entity.isValid(), false);
      });
    });
  });
}
