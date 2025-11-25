import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/services/sync/i_sync_remote_service.dart';
import 'package:qfly_avionica/data/database/models/flight_session_entity.dart';

void main() {
  group('SyncResult', () {
    test('SyncResult.ok deve criar resultado sucesso', () {
      final result = SyncResult.ok(
        remoteId: 'remote_123',
        serverTimestamp: 1234567890,
      );

      expect(result.success, isTrue);
      expect(result.remoteId, 'remote_123');
      expect(result.serverTimestamp, 1234567890);
      expect(result.errorMessage, isNull);
    });

    test('SyncResult.error deve criar resultado falha', () {
      final result = SyncResult.error('Network timeout');

      expect(result.success, isFalse);
      expect(result.errorMessage, 'Network timeout');
      expect(result.remoteId, isNull);
    });
  });

  group('MockSyncRemoteService', () {
    late MockSyncRemoteService service;
    late FlightSessionEntity testSession;

    setUp(() {
      service = MockSyncRemoteService();
      testSession = FlightSessionEntity(
        id: 'flight_001',
        instructorId: 'instructor_001',
        aircraftId: 'aircraft_001',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'completed',
        syncStatus: 'pending',
      );
    });

    group('uploadFlightSession', () {
      test('deve retornar sucesso por padrão', () async {
        final result = await service.uploadFlightSession(testSession);

        expect(result.success, isTrue);
        expect(result.remoteId, 'remote_flight_001');
        expect(result.serverTimestamp, isNotNull);
      });

      test('deve incrementar contador de chamadas', () async {
        expect(service.uploadCallCount, 0);

        await service.uploadFlightSession(testSession);
        expect(service.uploadCallCount, 1);

        await service.uploadFlightSession(testSession);
        expect(service.uploadCallCount, 2);
      });

      test('deve falhar quando simulateFailure = true', () async {
        service.simulateFailure = true;

        final result = await service.uploadFlightSession(testSession);

        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Simulated'));
      });

      test('resetCallCount deve zerar contador', () async {
        await service.uploadFlightSession(testSession);
        await service.uploadFlightSession(testSession);
        expect(service.uploadCallCount, 2);

        service.resetCallCount();

        expect(service.uploadCallCount, 0);
      });
    });

    group('uploadTelemetry', () {
      test('deve retornar sucesso para telemetria', () async {
        final points = [
          {'altitude': 1000.0, 'speed': 120.0},
          {'altitude': 1050.0, 'speed': 125.0},
        ];

        final result = await service.uploadTelemetry('flight_001', points);

        expect(result.success, isTrue);
        expect(result.serverTimestamp, isNotNull);
      });

      test('deve falhar quando simulateFailure = true', () async {
        service.simulateFailure = true;

        final result = await service.uploadTelemetry('flight_001', []);

        expect(result.success, isFalse);
      });
    });

    group('existsOnServer', () {
      test('deve retornar false por padrão (mock)', () async {
        final exists = await service.existsOnServer('flight_001');

        expect(exists, isFalse);
      });
    });

    group('getServerVersion', () {
      test('deve retornar null por padrão (mock)', () async {
        final version = await service.getServerVersion('flight_001');

        expect(version, isNull);
      });
    });

    group('Delay Simulado', () {
      test('deve respeitar delay configurado', () async {
        service.simulatedDelayMs = 200;

        final stopwatch = Stopwatch()..start();
        await service.uploadFlightSession(testSession);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(180));
      });
    });
  });
}