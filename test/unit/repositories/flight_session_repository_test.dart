/// 🧪 TESTES - Flight Session Repository
/// 
/// Valida:
/// - CRUD operations (Create, Read, Update, Delete)
/// - Validações de entity
/// - Conversões Map ↔ Entity
/// - Business rules
/// - Edge cases

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../test_helper.dart';

import 'package:qfly_avionica/data/repositories/flight_session_repository.dart';
import 'package:qfly_avionica/data/database/models/flight_session_entity.dart';
import 'package:qfly_avionica/data/database/flight_database.dart';

void main() {
  // 🔧 Setup
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // 🧹 Cleanup
  tearDown(() async {
    await FlightDatabase.closeAll();
  });

  group('📦 FlightSessionRepository - Create', () {
    final repository = FlightSessionRepository();

    test('✅ Deve inserir session válida', () async {
      final flightId = 'test_insert_001';
      
      // Criar DB primeiro
      await FlightDatabase.create(flightId);
      
      final session = FlightSessionEntity(
        id: flightId,
        instructorId: 'inst_123',
        studentId: 'student_456',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
      );

      await repository.insert(flightId, session);

      // Verificar que foi inserido
      final retrieved = await repository.getById(flightId);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, flightId);
      expect(retrieved.instructorId, 'inst_123');
      expect(retrieved.aircraftId, 'PT-ABC');
      
      await FlightDatabase.delete(flightId);
    });

    test('❌ Deve rejeitar session inválida (campos obrigatórios)', () async {
      final flightId = 'test_invalid_001';
      await FlightDatabase.create(flightId);

      final invalidSession = FlightSessionEntity(
        id: '', // ❌ ID vazio
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
      );

      expect(
        () async => await repository.insert(flightId, invalidSession),
        throwsA(isA<Exception>()),
      );

      await FlightDatabase.delete(flightId);
    });

    test('❌ Deve rejeitar status inválido', () async {
      final flightId = 'test_invalid_status';
      await FlightDatabase.create(flightId);

      final invalidSession = FlightSessionEntity(
        id: flightId,
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'INVALID_STATUS', // ❌ Status inválido
        syncStatus: 'pending',
      );

      expect(
        () async => await repository.insert(flightId, invalidSession),
        throwsA(isA<Exception>()),
      );

      await FlightDatabase.delete(flightId);
    });

    test('❌ Deve rejeitar bateria fora do range', () async {
      final flightId = 'test_invalid_battery';
      await FlightDatabase.create(flightId);

      final invalidSession = FlightSessionEntity(
        id: flightId,
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
        tabletBatteryStart: 150, // ❌ > 100
      );

      expect(
        () async => await repository.insert(flightId, invalidSession),
        throwsA(isA<Exception>()),
      );

      await FlightDatabase.delete(flightId);
    });
  });

  group('📖 FlightSessionRepository - Read', () {
    final repository = FlightSessionRepository();

    test('✅ getById deve retornar session existente', () async {
      final flightId = 'test_getbyid_001';
      await FlightDatabase.create(flightId);

      final session = FlightSessionEntity(
        id: flightId,
        instructorId: 'inst_789',
        aircraftId: 'PT-XYZ',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
      );

      await repository.insert(flightId, session);

      final retrieved = await repository.getById(flightId);
      expect(retrieved, isNotNull);
      expect(retrieved!.instructorId, 'inst_789');
      expect(retrieved.aircraftId, 'PT-XYZ');

      await FlightDatabase.delete(flightId);
    });

    test('✅ getById deve retornar null para inexistente', () async {
      final retrieved = await repository.getById('nonexistent');
      expect(retrieved, isNull);
    });

    test('✅ getAll deve retornar múltiplas sessions', () async {
      final flight1 = 'test_getall_1';
      final flight2 = 'test_getall_2';

      await FlightDatabase.create(flight1);
      await FlightDatabase.create(flight2);

      final session1 = FlightSessionEntity(
        id: flight1,
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
      );

      final session2 = FlightSessionEntity(
        id: flight2,
        instructorId: 'inst_456',
        aircraftId: 'PT-XYZ',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'completed',
        syncStatus: 'completed',
      );

      await repository.insert(flight1, session1);
      await repository.insert(flight2, session2);

      final all = await repository.getAll();
      expect(all.length, greaterThanOrEqualTo(2));

      await FlightDatabase.delete(flight1);
      await FlightDatabase.delete(flight2);
    });

    test('✅ getPendingSync deve filtrar por sync_status', () async {
      final flightPending = 'test_pending_001';
      final flightSynced = 'test_synced_001';

      await FlightDatabase.create(flightPending);
      await FlightDatabase.create(flightSynced);

      final sessionPending = FlightSessionEntity(
        id: flightPending,
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending', // Pendente
      );

      final sessionSynced = FlightSessionEntity(
        id: flightSynced,
        instructorId: 'inst_456',
        aircraftId: 'PT-XYZ',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'completed',
        syncStatus: 'completed', // Synced
      );

      await repository.insert(flightPending, sessionPending);
      await repository.insert(flightSynced, sessionSynced);

      final pending = await repository.getPendingSync();
      
      final pendingIds = pending.map((s) => s.id).toList();
      expect(pendingIds, contains(flightPending));
      expect(pendingIds, isNot(contains(flightSynced)));

      await FlightDatabase.delete(flightPending);
      await FlightDatabase.delete(flightSynced);
    });

    test('✅ getByStatus deve filtrar corretamente', () async {
      final flightActive = 'test_status_active';
      final flightCompleted = 'test_status_completed';

      await FlightDatabase.create(flightActive);
      await FlightDatabase.create(flightCompleted);

      final sessionActive = FlightSessionEntity(
        id: flightActive,
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
      );

      final sessionCompleted = FlightSessionEntity(
        id: flightCompleted,
        instructorId: 'inst_456',
        aircraftId: 'PT-XYZ',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'completed',
        syncStatus: 'completed',
      );

      await repository.insert(flightActive, sessionActive);
      await repository.insert(flightCompleted, sessionCompleted);

      final active = await repository.getByStatus('active');
      final activeIds = active.map((s) => s.id).toList();
      
      expect(activeIds, contains(flightActive));
      expect(activeIds, isNot(contains(flightCompleted)));

      await FlightDatabase.delete(flightActive);
      await FlightDatabase.delete(flightCompleted);
    });

    test('✅ exists deve validar existência', () async {
      final flightId = 'test_exists_001';
      await FlightDatabase.create(flightId);

      // Antes de inserir
      expect(await repository.exists(flightId), false);

      final session = FlightSessionEntity(
        id: flightId,
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
      );

      await repository.insert(flightId, session);

      // Depois de inserir
      expect(await repository.exists(flightId), true);

      await FlightDatabase.delete(flightId);
    });
  });

  group('✏️ FlightSessionRepository - Update', () {
    final repository = FlightSessionRepository();

    test('✅ update deve atualizar session', () async {
      final flightId = 'test_update_001';
      await FlightDatabase.create(flightId);

      final session = FlightSessionEntity(
        id: flightId,
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
        totalPoints: 100,
      );

      await repository.insert(flightId, session);

      // Atualizar
      final updated = session.copyWith(
        totalPoints: 500,
        status: 'completed',
      );

      await repository.update(flightId, updated);

      // Verificar
      final retrieved = await repository.getById(flightId);
      expect(retrieved!.totalPoints, 500);
      expect(retrieved.status, 'completed');

      await FlightDatabase.delete(flightId);
    });

    test('✅ updateSyncStatus deve atualizar apenas sync', () async {
      final flightId = 'test_updatesync_001';
      await FlightDatabase.create(flightId);

      final session = FlightSessionEntity(
        id: flightId,
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
        syncAttempts: 0,
      );

      await repository.insert(flightId, session);

      // Atualizar sync
      await repository.updateSyncStatus(flightId, 'completed');

      final retrieved = await repository.getById(flightId);
      expect(retrieved!.syncStatus, 'completed');
      expect(retrieved.status, 'active'); // Status não mudou

      await FlightDatabase.delete(flightId);
    });

    test('✅ updateSyncStatus com failed deve incrementar attempts', () async {
      final flightId = 'test_syncfailed_001';
      await FlightDatabase.create(flightId);

      final session = FlightSessionEntity(
        id: flightId,
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
        syncAttempts: 2,
      );

      await repository.insert(flightId, session);

      await repository.updateSyncStatus(
        flightId, 
        'failed',
        syncError: 'Network timeout',
      );

      final retrieved = await repository.getById(flightId);
      expect(retrieved!.syncStatus, 'failed');
      expect(retrieved.syncAttempts, 3); // Incrementado
      expect(retrieved.syncError, 'Network timeout');

      await FlightDatabase.delete(flightId);
    });

    test('✅ updateStatus completed deve setar endTime', () async {
      final flightId = 'test_complete_001';
      await FlightDatabase.create(flightId);

      final session = FlightSessionEntity(
        id: flightId,
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
      );

      await repository.insert(flightId, session);

      // Completar voo
      await repository.updateStatus(flightId, 'completed');

      final retrieved = await repository.getById(flightId);
      expect(retrieved!.status, 'completed');
      expect(retrieved.endTime, isNotNull);

      await FlightDatabase.delete(flightId);
    });
  });

  group('🗑️ FlightSessionRepository - Delete', () {
    final repository = FlightSessionRepository();

    test('✅ delete deve remover session', () async {
      final flightId = 'test_delete_001';
      await FlightDatabase.create(flightId);

      final session = FlightSessionEntity(
        id: flightId,
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
      );

      await repository.insert(flightId, session);

      // Verificar que existe
      expect(await repository.exists(flightId), true);

      // Deletar
      await repository.delete(flightId);

      // Verificar que foi removido
      expect(await repository.exists(flightId), false);

      await FlightDatabase.delete(flightId);
    });

    test('❌ delete deve lançar erro para inexistente', () async {
      expect(
        () async => await repository.delete('nonexistent'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('📊 FlightSessionRepository - Helpers', () {
    final repository = FlightSessionRepository();

    test('✅ count deve retornar total correto', () async {
      final flight1 = 'test_count_1';
      final flight2 = 'test_count_2';

      await FlightDatabase.create(flight1);
      await FlightDatabase.create(flight2);

      final session1 = FlightSessionEntity(
        id: flight1,
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
      );

      final session2 = FlightSessionEntity(
        id: flight2,
        instructorId: 'inst_456',
        aircraftId: 'PT-XYZ',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'completed',
        syncStatus: 'completed',
      );

      await repository.insert(flight1, session1);
      await repository.insert(flight2, session2);

      final count = await repository.count();
      expect(count, greaterThanOrEqualTo(2));

      await FlightDatabase.delete(flight1);
      await FlightDatabase.delete(flight2);
    });

    test('✅ Entity helpers devem funcionar', () {
      final activeSession = FlightSessionEntity(
        id: 'test',
        instructorId: 'inst_123',
        aircraftId: 'PT-ABC',
        startTime: DateTime.now().millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        status: 'active',
        syncStatus: 'pending',
      );

      expect(activeSession.isActive, true);
      expect(activeSession.isCompleted, false);
      expect(activeSession.isPendingSync, true);
      expect(activeSession.isSynced, false);
    });
  });
}