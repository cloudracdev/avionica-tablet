/// 🧪 TESTES - Flight Database Migration v1
/// 
/// Valida:
/// - Criação de banco de dados
/// - Execução migration_v1
/// - Estrutura tabelas
/// - Triggers e constraints
/// - Foreign keys CASCADE

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../../test_helper.dart';

// Import da migration
import 'package:qfly_avionica/data/database/migrations/migration_v1.dart';

void main() {
  // 🔧 Setup SQLite FFI para testes
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('📦 Migration V1 - Schema Creation', () {
    late Database db;

    setUp(() async {
      // Criar DB em memória para testes
      db = await openDatabase(
        inMemoryDatabasePath,
        version: MigrationV1.version,
        onCreate: (db, version) async {
          // Executar migration v1
          await db.execute(MigrationV1.create);
        },
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('✅ Deve criar todas as 4 tabelas', () async {
      // Query para listar tabelas
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      final tableNames = tables.map((t) => t['name'] as String).toList();

      expect(tableNames, contains('flight_session'));
      expect(tableNames, contains('telemetry_points'));
      expect(tableNames, contains('evaluation'));
      expect(tableNames, contains('photos'));
      expect(tableNames.length, 4);
    });

    test('✅ Deve criar todos os 7 índices', () async {
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'",
      );

      final indexNames = indexes.map((i) => i['name'] as String).toList();

      expect(indexNames, contains('idx_telemetry_timestamp'));
      expect(indexNames, contains('idx_telemetry_session_time'));
      expect(indexNames, contains('idx_telemetry_location'));
      expect(indexNames, contains('idx_telemetry_quality'));
      expect(indexNames, contains('idx_session_sync_status'));
      expect(indexNames, contains('idx_photos_sync'));
      expect(indexNames, contains('idx_evaluation_session'));
      expect(indexNames.length, 7);
    });

    test('✅ Deve criar todos os 6 triggers', () async {
      final triggers = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='trigger'",
      );

      final triggerNames = triggers.map((t) => t['name'] as String).toList();

      expect(triggerNames, contains('validate_flight_session_status'));
      expect(triggerNames, contains('validate_sync_status'));
      expect(triggerNames, contains('validate_telemetry_coordinates'));
      expect(triggerNames, contains('validate_tablet_battery'));
      expect(triggerNames, contains('update_flight_session_timestamp'));
      expect(triggerNames, contains('increment_total_points'));
      expect(triggerNames.length, 6);
    });

    test('✅ flight_session deve ter colunas corretas', () async {
      final columns = await db.rawQuery('PRAGMA table_info(flight_session)');
      final columnNames = columns.map((c) => c['name'] as String).toList();

      // Campos essenciais
      expect(columnNames, contains('id'));
      expect(columnNames, contains('instructor_id'));
      expect(columnNames, contains('student_id'));
      expect(columnNames, contains('aircraft_id'));
      expect(columnNames, contains('start_time'));
      expect(columnNames, contains('end_time'));
      expect(columnNames, contains('status'));
      expect(columnNames, contains('sync_status'));
      expect(columnNames, contains('sync_attempts'));
      
      // 🔋 Bateria tablet
      expect(columnNames, contains('tablet_battery_start'));
      expect(columnNames, contains('tablet_battery_end'));
      expect(columnNames, contains('tablet_battery_drain_rate'));
      
      // Métricas
      expect(columnNames, contains('total_points'));
      expect(columnNames, contains('data_loss_percent'));
      expect(columnNames, contains('connection_drops'));
    });

    test('✅ telemetry_points deve ter todos sensores', () async {
      final columns = await db.rawQuery('PRAGMA table_info(telemetry_points)');
      final columnNames = columns.map((c) => c['name'] as String).toList();

      // GPS
      expect(columnNames, contains('lat'));
      expect(columnNames, contains('lng'));
      expect(columnNames, contains('gps_altitude'));
      expect(columnNames, contains('gps_speed'));
      expect(columnNames, contains('gps_heading'));
      
      // Barômetro
      expect(columnNames, contains('baro_altitude'));
      expect(columnNames, contains('baro_pressure'));
      expect(columnNames, contains('baro_temperature'));
      
      // Compass
      expect(columnNames, contains('mag_heading'));
      expect(columnNames, contains('mag_x'));
      
      // Acelerômetro
      expect(columnNames, contains('accel_x'));
      expect(columnNames, contains('accel_y'));
      expect(columnNames, contains('accel_z'));
      
      // Giroscópio
      expect(columnNames, contains('gyro_x'));
      expect(columnNames, contains('gyro_y'));
      expect(columnNames, contains('gyro_z'));
      
      // IMU
      expect(columnNames, contains('imu_pitch'));
      expect(columnNames, contains('imu_roll'));
      expect(columnNames, contains('imu_yaw'));
      
      // Quality
      expect(columnNames, contains('data_quality'));
      expect(columnNames, contains('raw_json'));
    });
  });

  group('💾 Flight Session - CRUD Operations', () {
    late Database db;

    setUp(() async {
      db = await openDatabase(
        inMemoryDatabasePath,
        version: MigrationV1.version,
        onCreate: (db, version) async {
          await db.execute(MigrationV1.create);
        },
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('✅ Deve inserir flight_session válido', () async {
      final flightId = 'test_flight_001';
      
      await db.insert('flight_session', {
        'id': flightId,
        'instructor_id': 'instructor_123',
        'student_id': 'student_456',
        'aircraft_id': 'PT-ABC',
        'start_time': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
        'sync_status': 'pending',
        'tablet_battery_start': 85,
        'tablet_battery_end': 62,
      });

      final result = await db.query(
        'flight_session',
        where: 'id = ?',
        whereArgs: [flightId],
      );

      expect(result.length, 1);
      expect(result.first['id'], flightId);
      expect(result.first['instructor_id'], 'instructor_123');
      expect(result.first['tablet_battery_start'], 85);
    });

    test('❌ Deve rejeitar status inválido', () async {
      expect(
        () async => await db.insert('flight_session', {
          'id': 'test_002',
          'instructor_id': 'instructor_123',
          'aircraft_id': 'PT-ABC',
          'start_time': DateTime.now().millisecondsSinceEpoch,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'status': 'INVALID_STATUS', // ❌ Status inválido
          'sync_status': 'pending',
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('❌ Deve rejeitar bateria fora do range 0-100', () async {
      // Bateria > 100
      expect(
        () async => await db.insert('flight_session', {
          'id': 'test_003',
          'instructor_id': 'instructor_123',
          'aircraft_id': 'PT-ABC',
          'start_time': DateTime.now().millisecondsSinceEpoch,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'status': 'active',
          'sync_status': 'pending',
          'tablet_battery_start': 150, // ❌ > 100
        }),
        throwsA(isA<DatabaseException>()),
      );

      // Bateria < 0
      expect(
        () async => await db.insert('flight_session', {
          'id': 'test_004',
          'instructor_id': 'instructor_123',
          'aircraft_id': 'PT-ABC',
          'start_time': DateTime.now().millisecondsSinceEpoch,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
          'status': 'active',
          'sync_status': 'pending',
          'tablet_battery_end': -10, // ❌ < 0
        }),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('📡 Telemetry Points - Validation', () {
    late Database db;
    late String flightId;

    setUp(() async {
      db = await openDatabase(
        inMemoryDatabasePath,
        version: MigrationV1.version,
        onCreate: (db, version) async {
          await db.execute(MigrationV1.create);
        },
      );

      // Criar flight_session primeiro
      flightId = 'test_flight_telemetry';
      await db.insert('flight_session', {
        'id': flightId,
        'instructor_id': 'instructor_123',
        'aircraft_id': 'PT-ABC',
        'start_time': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
        'sync_status': 'pending',
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('✅ Deve inserir telemetry point válido', () async {
      await db.insert('telemetry_points', {
        'flight_session_id': flightId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'lat': -25.4284,
        'lng': -49.2733,
        'gps_altitude': 920.5,
        'gps_speed': 75.0,
        'gps_heading': 180.0,
        'baro_altitude': 918.2,
        'velocity': 75.5,
        'altitude': 920.0,
        'heading': 180.0,
        'data_quality': 'valid',
      });

      final result = await db.query(
        'telemetry_points',
        where: 'flight_session_id = ?',
        whereArgs: [flightId],
      );

      expect(result.length, 1);
      expect(result.first['lat'], -25.4284);
      expect(result.first['lng'], -49.2733);
    });

    test('❌ Deve rejeitar latitude inválida', () async {
      // Latitude > 90
      expect(
        () async => await db.insert('telemetry_points', {
          'flight_session_id': flightId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'lat': 95.0, // ❌ > 90
          'lng': -49.2733,
        }),
        throwsA(isA<DatabaseException>()),
      );

      // Latitude < -90
      expect(
        () async => await db.insert('telemetry_points', {
          'flight_session_id': flightId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'lat': -95.0, // ❌ < -90
          'lng': -49.2733,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('❌ Deve rejeitar longitude inválida', () async {
      // Longitude > 180
      expect(
        () async => await db.insert('telemetry_points', {
          'flight_session_id': flightId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'lat': -25.4284,
          'lng': 185.0, // ❌ > 180
        }),
        throwsA(isA<DatabaseException>()),
      );

      // Longitude < -180
      expect(
        () async => await db.insert('telemetry_points', {
          'flight_session_id': flightId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'lat': -25.4284,
          'lng': -185.0, // ❌ < -180
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('✅ Deve incrementar total_points automaticamente', () async {
      // Inserir 3 pontos
      for (int i = 0; i < 3; i++) {
        await db.insert('telemetry_points', {
          'flight_session_id': flightId,
          'timestamp': DateTime.now().millisecondsSinceEpoch + i,
          'lat': -25.4284,
          'lng': -49.2733,
        });
      }

      // Verificar total_points
      final result = await db.query(
        'flight_session',
        where: 'id = ?',
        whereArgs: [flightId],
      );

      expect(result.first['total_points'], 3);
    });
  });

  group('🔗 Foreign Keys - CASCADE Delete', () {
    late Database db;
    late String flightId;

    setUp(() async {
      db = await openDatabase(
        inMemoryDatabasePath,
        version: MigrationV1.version,
        onCreate: (db, version) async {
          await db.execute(MigrationV1.create);
        },
      );

      // Habilitar foreign keys
      await db.execute('PRAGMA foreign_keys = ON');

      // Criar flight_session
      flightId = 'test_flight_cascade';
      await db.insert('flight_session', {
        'id': flightId,
        'instructor_id': 'instructor_123',
        'aircraft_id': 'PT-ABC',
        'start_time': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
        'sync_status': 'pending',
      });

      // Inserir dados relacionados
      await db.insert('telemetry_points', {
        'flight_session_id': flightId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'lat': -25.4284,
        'lng': -49.2733,
      });

      await db.insert('evaluation', {
        'id': 'eval_001',
        'flight_session_id': flightId,
        'fap_data': '{}',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'status': 'draft',
      });

      await db.insert('photos', {
        'id': 'photo_001',
        'flight_session_id': flightId,
        'file_path': '/path/to/photo.jpg',
        'file_name': 'photo.jpg',
        'taken_at': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('✅ Deve deletar CASCADE todos dados relacionados', () async {
      // Deletar flight_session
      await db.delete(
        'flight_session',
        where: 'id = ?',
        whereArgs: [flightId],
      );

      // Verificar que telemetry_points foram deletados
      final telemetry = await db.query(
        'telemetry_points',
        where: 'flight_session_id = ?',
        whereArgs: [flightId],
      );
      expect(telemetry.length, 0);

      // Verificar que evaluation foi deletada
      final evaluation = await db.query(
        'evaluation',
        where: 'flight_session_id = ?',
        whereArgs: [flightId],
      );
      expect(evaluation.length, 0);

      // Verificar que photos foram deletadas
      final photos = await db.query(
        'photos',
        where: 'flight_session_id = ?',
        whereArgs: [flightId],
      );
      expect(photos.length, 0);
    });
  });

  group('📊 Performance - Indexes', () {
    late Database db;

    setUp(() async {
      db = await openDatabase(
        inMemoryDatabasePath,
        version: MigrationV1.version,
        onCreate: (db, version) async {
          await db.execute(MigrationV1.create);
        },
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('✅ Índice idx_telemetry_timestamp deve existir', () async {
      final explain = await db.rawQuery(
        'EXPLAIN QUERY PLAN SELECT * FROM telemetry_points WHERE timestamp > 0',
      );

      // Verificar que está usando índice
      final queryPlan = explain.toString();
      expect(queryPlan.toLowerCase(), contains('index'));
    });
  });
}