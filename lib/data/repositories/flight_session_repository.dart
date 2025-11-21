/// 🗄️ FLIGHT SESSION REPOSITORY
/// 
/// Repository pattern para operações CRUD na tabela flight_session
/// 
/// Responsabilidades:
/// - Create, Read, Update, Delete sessions
/// - Usar FlightDatabase para lifecycle
/// - Converter Entity ↔ Database

import 'package:sqflite/sqflite.dart';
import '../database/flight_database.dart';
import '../database/models/flight_session_entity.dart';

class FlightSessionRepository {
  /// ➕ Inserir nova flight session
  /// 
  /// - Valida entity antes de inserir
  /// - Usa FlightDatabase.open() internamente
  /// - Fecha database após inserção
  /// 
  /// Throws:
  /// - Exception se entity inválida
  /// - Exception se já existe session com mesmo ID
  Future<void> insert(String flightId, FlightSessionEntity session) async {
    // Validar entity
    if (!session.isValid()) {
      final errors = session.validate().join(', ');
      throw Exception('FlightSession inválida: $errors');
    }

    // Abrir database
    final db = await FlightDatabase.open(flightId);

    try {
      // Inserir
      await db.insert(
        'flight_session',
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } finally {
      // Sempre fechar
      await FlightDatabase.close(flightId);
    }
  }

  /// 📖 Buscar flight session por ID
  /// 
  /// Returns:
  /// - FlightSessionEntity se encontrado
  /// - null se não existe
  Future<FlightSessionEntity?> getById(String flightId) async {
    try {
      // Abrir database
      final db = await FlightDatabase.open(flightId);

      try {
        // Query
        final results = await db.query(
          'flight_session',
          limit: 1,
        );

        if (results.isEmpty) {
          return null;
        }

        return FlightSessionEntity.fromMap(results.first);
      } finally {
        await FlightDatabase.close(flightId);
      }
    } catch (e) {
      // Database não existe
      return null;
    }
  }

  /// 📋 Buscar todas as flight sessions
  /// 
  /// Returns: Lista de todas as sessions
  Future<List<FlightSessionEntity>> getAll() async {
    final allFlights = await FlightDatabase.listAllFlights();
    final sessions = <FlightSessionEntity>[];

    for (final flightId in allFlights) {
      final session = await getById(flightId);
      if (session != null) {
        sessions.add(session);
      }
    }

    return sessions;
  }

  /// 🔄 Buscar sessions pendentes de sync
  /// 
  /// Returns: Lista de sessions com sync_status = pending ou failed
  Future<List<FlightSessionEntity>> getPendingSync() async {
    final pendingIds = await FlightDatabase.listPendingSync();
    final sessions = <FlightSessionEntity>[];

    for (final flightId in pendingIds) {
      final session = await getById(flightId);
      if (session != null) {
        sessions.add(session);
      }
    }

    return sessions;
  }

  /// 🔄 Buscar sessions por status
  /// 
  /// Example: getByStatus('active') → voos em andamento
  Future<List<FlightSessionEntity>> getByStatus(String status) async {
    final all = await getAll();
    return all.where((s) => s.status == status).toList();
  }

  /// 🔄 Buscar sessions por instrutor
  Future<List<FlightSessionEntity>> getByInstructor(String instructorId) async {
    final all = await getAll();
    return all.where((s) => s.instructorId == instructorId).toList();
  }

  /// ✏️ Atualizar flight session
  /// 
  /// - Valida entity antes de atualizar
  /// - Atualiza campo updated_at automaticamente
  /// 
  /// Throws:
  /// - Exception se entity inválida
  /// - Exception se session não existe
  Future<void> update(String flightId, FlightSessionEntity session) async {
    // Validar entity
    if (!session.isValid()) {
      final errors = session.validate().join(', ');
      throw Exception('FlightSession inválida: $errors');
    }

    // Atualizar timestamp
    final updatedSession = session.copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Abrir database
    final db = await FlightDatabase.open(flightId);

    try {
      final count = await db.update(
        'flight_session',
        updatedSession.toMap(),
        where: 'id = ?',
        whereArgs: [flightId],
      );

      if (count == 0) {
        throw Exception('Flight session não encontrada: $flightId');
      }
    } finally {
      await FlightDatabase.close(flightId);
    }
  }

  /// 🔄 Atualizar apenas sync_status
  /// 
  /// Útil para marcar como synced sem alterar outros campos
  Future<void> updateSyncStatus(
    String flightId,
    String syncStatus, {
    String? syncError,
  }) async {
    final session = await getById(flightId);
    if (session == null) {
      throw Exception('Flight session não encontrada: $flightId');
    }

    final updated = session.copyWith(
      syncStatus: syncStatus,
      syncError: syncError,
      syncAttempts: syncStatus == 'failed' 
          ? session.syncAttempts + 1 
          : session.syncAttempts,
      lastSyncAttempt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await update(flightId, updated);
  }

  /// 🔄 Atualizar status do voo
  /// 
  /// Example: updateStatus(flightId, 'completed')
  Future<void> updateStatus(String flightId, String status) async {
    final session = await getById(flightId);
    if (session == null) {
      throw Exception('Flight session não encontrada: $flightId');
    }

    final updated = session.copyWith(
      status: status,
      endTime: status == 'completed' 
          ? DateTime.now().millisecondsSinceEpoch 
          : session.endTime,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await update(flightId, updated);
  }

  /// 🔄 Incrementar sync attempts
  Future<void> incrementSyncAttempts(String flightId) async {
    final session = await getById(flightId);
    if (session == null) {
      throw Exception('Flight session não encontrada: $flightId');
    }

    final updated = session.copyWith(
      syncAttempts: session.syncAttempts + 1,
      lastSyncAttempt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await update(flightId, updated);
  }

  /// 🗑️ Deletar flight session
  /// 
  /// - Deleta session da tabela
  /// - NÃO deleta o database inteiro
  /// - Use FlightDatabase.delete() para deletar DB completo
  /// 
  /// Throws:
  /// - Exception se session não existe
  Future<void> delete(String flightId) async {
    final db = await FlightDatabase.open(flightId);

    try {
      final count = await db.delete(
        'flight_session',
        where: 'id = ?',
        whereArgs: [flightId],
      );

      if (count == 0) {
        throw Exception('Flight session não encontrada: $flightId');
      }
    } finally {
      await FlightDatabase.close(flightId);
    }
  }

  /// 🗑️ Deletar database completo (session + telemetria + fotos)
  /// 
  /// Wrapper para FlightDatabase.delete()
  Future<void> deleteCompleteFlight(String flightId) async {
    await FlightDatabase.delete(flightId);
  }

  /// 📊 Contar total de sessions
  Future<int> count() async {
    final all = await getAll();
    return all.length;
  }

  /// 📊 Contar sessions por status
  Future<int> countByStatus(String status) async {
    final sessions = await getByStatus(status);
    return sessions.length;
  }

  /// 📊 Contar sessions pendentes sync
  Future<int> countPendingSync() async {
    final sessions = await getPendingSync();
    return sessions.length;
  }

  /// ✅ Verificar se session existe
  Future<bool> exists(String flightId) async {
    final session = await getById(flightId);
    return session != null;
  }
}