/// 🧪 TESTES - Flight Database Service
/// 
/// Valida:
/// - Criar database por voo (UUID naming)
/// - Abrir database existente
/// - Listar databases
/// - Deletar databases
/// - Integridade e metadata

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:qfly_avionica/data/database/flight_database.dart';

void main() {
  // 🔧 Setup SQLite FFI para testes
  setUpAll(() {
    // Inicializar Flutter binding para path_provider
    TestWidgetsFlutterBinding.ensureInitialized();
    
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // 🧹 Cleanup antes e após cada teste
  setUp(() async {
    await FlightDatabase.deleteAll();
  });

  tearDown(() async {
    await FlightDatabase.deleteAll();
  });

  group('📦 FlightDatabase - Create & Open', () {
    test('✅ Deve criar database novo com flightId', () async {
      final flightId = 'test_flight_001';
      
      final db = await FlightDatabase.create(flightId);
      
      expect(db, isNotNull);
      expect(db.isOpen, true);
      
      await FlightDatabase.close(flightId);
    });

    test('✅ Path deve seguir padrão flight_{id}.db', () async {
      final flightId = 'abc123-def456';
      
      final path = await FlightDatabase.getDatabasePath(flightId);
      
      expect(path, contains('flights'));
      expect(path, endsWith('flight_abc123-def456.db'));
    });

    test('✅ Deve executar migration v1 ao criar', () async {
      final flightId = 'test_migration';
      
      final db = await FlightDatabase.create(flightId);
      
      // Verificar tabelas criadas
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      
      final tableNames = tables.map((t) => t['name'] as String).toList();
      
      expect(tableNames, contains('flight_session'));
      expect(tableNames, contains('telemetry_points'));
      expect(tableNames, contains('evaluation'));
      expect(tableNames, contains('photos'));
      
      await FlightDatabase.close(flightId);
    });

    test('❌ Deve lançar erro ao criar database duplicado', () async {
      final flightId = 'test_duplicate';
      
      // Criar primeiro
      await FlightDatabase.create(flightId);
      
      // Tentar criar novamente
      expect(
        () async => await FlightDatabase.create(flightId),
        throwsA(isA<Exception>()),
      );
      
      await FlightDatabase.close(flightId);
    });

    test('✅ Deve abrir database existente', () async {
      final flightId = 'test_open';
      
      // Criar primeiro
      await FlightDatabase.create(flightId);
      await FlightDatabase.close(flightId);
      
      // Abrir novamente
      final db = await FlightDatabase.open(flightId);
      
      expect(db, isNotNull);
      expect(db.isOpen, true);
      
      await FlightDatabase.close(flightId);
    });

    test('❌ Deve lançar erro ao abrir database inexistente', () async {
      final flightId = 'nonexistent_flight';
      
      expect(
        () async => await FlightDatabase.open(flightId),
        throwsA(isA<Exception>()),
      );
    });

    test('✅ Deve retornar mesma instância se já aberto', () async {
      final flightId = 'test_singleton';
      
      final db1 = await FlightDatabase.create(flightId);
      final db2 = await FlightDatabase.open(flightId);
      
      expect(identical(db1, db2), true);
      
      await FlightDatabase.close(flightId);
    });
  });

  group('🗑️ FlightDatabase - Delete & Close', () {
    test('✅ Deve fechar database aberto', () async {
      final flightId = 'test_close';
      
      final db = await FlightDatabase.create(flightId);
      expect(db.isOpen, true);
      
      await FlightDatabase.close(flightId);
      expect(db.isOpen, false);
    });

    test('✅ Deve deletar database do filesystem', () async {
      final flightId = 'test_delete';
      
      await FlightDatabase.create(flightId);
      final path = await FlightDatabase.getDatabasePath(flightId);
      
      expect(await databaseExists(path), true);
      
      await FlightDatabase.delete(flightId);
      
      expect(await databaseExists(path), false);
    });

    test('❌ Deve lançar erro ao deletar database inexistente', () async {
      final flightId = 'nonexistent_delete';
      
      expect(
        () async => await FlightDatabase.delete(flightId),
        throwsA(isA<Exception>()),
      );
    });

    test('✅ Deve permitir close múltiplas vezes sem erro', () async {
      final flightId = 'test_multiple_close';
      
      await FlightDatabase.create(flightId);
      
      await FlightDatabase.close(flightId);
      await FlightDatabase.close(flightId); // Segunda vez
      await FlightDatabase.close(flightId); // Terceira vez
      
      // Não deve lançar erro
    });

    test('✅ closeAll deve fechar todas conexões', () async {
      final flight1 = 'test_close_all_1';
      final flight2 = 'test_close_all_2';
      final flight3 = 'test_close_all_3';
      
      final db1 = await FlightDatabase.create(flight1);
      final db2 = await FlightDatabase.create(flight2);
      final db3 = await FlightDatabase.create(flight3);
      
      expect(db1.isOpen, true);
      expect(db2.isOpen, true);
      expect(db3.isOpen, true);
      
      await FlightDatabase.closeAll();
      
      expect(db1.isOpen, false);
      expect(db2.isOpen, false);
      expect(db3.isOpen, false);
    });
  });

  group('📋 FlightDatabase - Listing', () {
    test('✅ listAllFlights deve retornar lista vazia inicialmente', () async {
      final flights = await FlightDatabase.listAllFlights();
      
      expect(flights, isA<List<String>>());
      expect(flights, isEmpty);
    });

    test('✅ listAllFlights deve retornar databases criados', () async {
      final flight1 = 'test_list_1';
      final flight2 = 'test_list_2';
      
      await FlightDatabase.create(flight1);
      await FlightDatabase.create(flight2);
      
      final flights = await FlightDatabase.listAllFlights();
      
      expect(flights, contains(flight1));
      expect(flights, contains(flight2));
    });

    test('✅ listPendingSync deve filtrar por sync_status', () async {
      final flightPending = 'test_pending';
      final flightSynced = 'test_synced';
      
      // Criar voo pendente
      final db1 = await FlightDatabase.create(flightPending);
      await db1.insert('flight_session', {
        'id': flightPending,
        'instructor_id': 'inst_123',
        'aircraft_id': 'PT-ABC',
        'start_time': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
        'sync_status': 'pending', // Pendente
      });
      await FlightDatabase.close(flightPending);
      
      // Criar voo synced
      final db2 = await FlightDatabase.create(flightSynced);
      await db2.insert('flight_session', {
        'id': flightSynced,
        'instructor_id': 'inst_123',
        'aircraft_id': 'PT-ABC',
        'start_time': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'status': 'completed',
        'sync_status': 'completed', // Synced
      });
      await FlightDatabase.close(flightSynced);
      
      // Listar pendentes
      final pending = await FlightDatabase.listPendingSync();
      
      expect(pending, contains(flightPending));
      expect(pending, isNot(contains(flightSynced)));
    });

    test('✅ listPendingSync deve incluir status failed', () async {
      final flightFailed = 'test_failed';
      
      final db = await FlightDatabase.create(flightFailed);
      await db.insert('flight_session', {
        'id': flightFailed,
        'instructor_id': 'inst_123',
        'aircraft_id': 'PT-ABC',
        'start_time': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
        'sync_status': 'failed', // Failed
      });
      await FlightDatabase.close(flightFailed);
      
      final pending = await FlightDatabase.listPendingSync();
      
      expect(pending, contains(flightFailed));
    });
  });

  group('📊 FlightDatabase - Info & Statistics', () {
    test('✅ getDatabaseInfo deve retornar metadata do voo', () async {
      final flightId = 'test_info';
      
      final db = await FlightDatabase.create(flightId);
      await db.insert('flight_session', {
        'id': flightId,
        'instructor_id': 'inst_123',
        'student_id': 'student_456',
        'aircraft_id': 'PT-ABC',
        'start_time': 1234567890000,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
        'sync_status': 'pending',
        'total_points': 1000,
      });
      await FlightDatabase.close(flightId);
      
      final info = await FlightDatabase.getDatabaseInfo(flightId);
      
      expect(info, isNotNull);
      expect(info!['flightId'], flightId);
      expect(info['status'], 'active');
      expect(info['syncStatus'], 'pending');
      expect(info['totalPoints'], 1000);
      expect(info['instructorId'], 'inst_123');
      expect(info['studentId'], 'student_456');
      expect(info['aircraftId'], 'PT-ABC');
      expect(info['sizeBytes'], greaterThan(0));
    });

    test('✅ getDatabaseInfo deve retornar null para DB inexistente', () async {
      final info = await FlightDatabase.getDatabaseInfo('nonexistent');
      
      expect(info, isNull);
    });

    test('✅ getStatistics deve retornar agregados corretos', () async {
      final flight1 = 'test_stats_1';
      final flight2 = 'test_stats_2';
      
      // Criar 2 voos
      final db1 = await FlightDatabase.create(flight1);
      await db1.insert('flight_session', {
        'id': flight1,
        'instructor_id': 'inst_123',
        'aircraft_id': 'PT-ABC',
        'start_time': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'status': 'active',
        'sync_status': 'pending',
        'total_points': 5000,
      });
      await FlightDatabase.close(flight1);
      
      final db2 = await FlightDatabase.create(flight2);
      await db2.insert('flight_session', {
        'id': flight2,
        'instructor_id': 'inst_123',
        'aircraft_id': 'PT-XYZ',
        'start_time': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'status': 'completed',
        'sync_status': 'completed',
        'total_points': 3000,
      });
      await FlightDatabase.close(flight2);
      
      final stats = await FlightDatabase.getStatistics();
      
      expect(stats['totalFlights'], equals(2));
      expect(stats['pendingSync'], equals(1));
      expect(stats['totalSizeBytes'], greaterThan(0));
      expect(stats['totalPoints'], equals(8000));
    });
  });

  group('✅ FlightDatabase - Integrity', () {
    test('✅ checkIntegrity deve validar database correto', () async {
      final flightId = 'test_integrity_ok';
      
      await FlightDatabase.create(flightId);
      
      final isValid = await FlightDatabase.checkIntegrity(flightId);
      
      expect(isValid, true);
    });

    test('✅ checkIntegrity deve retornar false para DB inexistente', () async {
      final isValid = await FlightDatabase.checkIntegrity('nonexistent');
      
      expect(isValid, false);
    });

    test('✅ checkIntegrity deve verificar tabelas essenciais', () async {
      final flightId = 'test_integrity_tables';
      
      final db = await FlightDatabase.create(flightId);
      
      // Verificar que tabelas existem
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      
      final tableNames = tables.map((t) => t['name']).toList();
      
      expect(tableNames, contains('flight_session'));
      expect(tableNames, contains('telemetry_points'));
      expect(tableNames, contains('evaluation'));
      expect(tableNames, contains('photos'));
      
      await FlightDatabase.close(flightId);
      
      final isValid = await FlightDatabase.checkIntegrity(flightId);
      expect(isValid, true);
    });
  });

  group('🔄 FlightDatabase - Edge Cases', () {
    test('✅ Deve lidar com flightId com caracteres especiais', () async {
      final flightId = 'test-flight_123.456';
      
      final db = await FlightDatabase.create(flightId);
      expect(db.isOpen, true);
      
      await FlightDatabase.close(flightId);
    });

    test('✅ Deve lidar com UUID padrão', () async {
      final flightId = 'abc123-def456-789xyz-012uvw';
      
      final db = await FlightDatabase.create(flightId);
      expect(db.isOpen, true);
      
      final path = await FlightDatabase.getDatabasePath(flightId);
      expect(path, contains(flightId));
      
      await FlightDatabase.close(flightId);
    });

    test('✅ Deve reabrir após close', () async {
      final flightId = 'test_reopen';
      
      // Criar e fechar
      await FlightDatabase.create(flightId);
      await FlightDatabase.close(flightId);
      
      // Reabrir
      final db = await FlightDatabase.open(flightId);
      expect(db.isOpen, true);
      
      await FlightDatabase.close(flightId);
    });

    test('✅ Múltiplos databases independentes', () async {
      final flight1 = 'test_multi_1';
      final flight2 = 'test_multi_2';
      final flight3 = 'test_multi_3';
      
      final db1 = await FlightDatabase.create(flight1);
      final db2 = await FlightDatabase.create(flight2);
      final db3 = await FlightDatabase.create(flight3);
      
      expect(db1.isOpen, true);
      expect(db2.isOpen, true);
      expect(db3.isOpen, true);
      
      // Todos devem ser instâncias diferentes
      expect(identical(db1, db2), false);
      expect(identical(db2, db3), false);
      
      await FlightDatabase.closeAll();
    });
  });

  group('🧹 FlightDatabase - DeleteAll', () {
    test('✅ deleteAll deve remover todos databases', () async {
      // Criar vários databases
      await FlightDatabase.create('delete_all_1');
      await FlightDatabase.create('delete_all_2');
      await FlightDatabase.create('delete_all_3');
      
      var flights = await FlightDatabase.listAllFlights();
      expect(flights.length, equals(3));
      
      // Deletar todos
      await FlightDatabase.deleteAll();
      
      flights = await FlightDatabase.listAllFlights();
      expect(flights, isEmpty);
    });

    test('✅ deleteAll deve funcionar com lista vazia', () async {
      // Garantir que está vazio
      await FlightDatabase.deleteAll();
      
      // Chamar novamente não deve dar erro
      await FlightDatabase.deleteAll();
      
      final flights = await FlightDatabase.listAllFlights();
      expect(flights, isEmpty);
    });
  });
}