import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/data/database/flight_database.dart';
import 'package:qfly_avionica/data/database/models/telemetry_point_entity.dart';
import 'package:qfly_avionica/data/repositories/telemetry_point_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late TelemetryPointRepository repository;
  late String testFlightId;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    repository = TelemetryPointRepository();
    testFlightId = 'test_${DateTime.now().millisecondsSinceEpoch}';
    await FlightDatabase.create(testFlightId);
  });

  tearDown(() async {
    try {
      await FlightDatabase.delete(testFlightId);
    } catch (_) {}
  });

  group('TelemetryPointRepository', () {
    test('deve inserir batch de pontos', () async {
      final points = List.generate(10, (i) => TelemetryPointEntity(
        flightSessionId: testFlightId,
        timestamp: 1000000 + (i * 100),
        lat: -25.4284,
        lng: -49.2733,
      ));

      final count = await repository.insertBatch(testFlightId, points);

      expect(count, 10);
    });

    test('deve contar pontos', () async {
      final points = List.generate(5, (i) => TelemetryPointEntity(
        flightSessionId: testFlightId,
        timestamp: 1000000 + (i * 100),
        lat: -25.4284,
        lng: -49.2733,
      ));

      await repository.insertBatch(testFlightId, points);
      final total = await repository.countByFlight(testFlightId);

      expect(total, 5);
    });

    test('deve buscar primeiro e último ponto', () async {
      final points = List.generate(5, (i) => TelemetryPointEntity(
        flightSessionId: testFlightId,
        timestamp: 1000000 + (i * 100),
        lat: -25.4284,
        lng: -49.2733,
      ));

      await repository.insertBatch(testFlightId, points);

      final first = await repository.getFirstPoint(testFlightId);
      final last = await repository.getLastPoint(testFlightId);

      expect(first?.timestamp, 1000000);
      expect(last?.timestamp, 1000400);
    });

    test('deve buscar por range de tempo', () async {
      final points = List.generate(10, (i) => TelemetryPointEntity(
        flightSessionId: testFlightId,
        timestamp: 1000000 + (i * 100),
        lat: -25.4284,
        lng: -49.2733,
      ));

      await repository.insertBatch(testFlightId, points);

      final result = await repository.getByTimeRange(
        testFlightId,
        1000000,
        1000400,
      );

      expect(result.length, 5);
    });

    test('deve rejeitar ponto inválido', () async {
      final invalidPoint = TelemetryPointEntity(
        flightSessionId: '',
        timestamp: 1000000,
        lat: -25.4284,
        lng: -49.2733,
      );

      expect(
        () => repository.insert(testFlightId, invalidPoint),
        throwsException,
      );
    });
  });
}
