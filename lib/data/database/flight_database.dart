/// 🗄️ FLIGHT DATABASE SERVICE
/// 
/// Gerencia lifecycle de databases SQLite (1 DB por voo)
/// 
/// Responsabilidades:
/// - Criar novo database para voo
/// - Abrir database existente
/// - Executar migrations
/// - Listar databases pendentes sync
/// - Deletar databases

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

import 'migrations/migration_v1.dart';

/// 🏭 Factory Service para gerenciar databases de voos
class FlightDatabase {
  // 🔒 Singleton pattern para controle de instâncias abertas
  static final Map<String, Database> _openDatabases = {};

  /// 📂 Diretório base para databases de voos
  static Future<String> get _databasesDirectory async {
    // Detectar se está em ambiente de teste
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    
    String baseDir;
    if (isTest) {
      // Em testes: usar diretório temporário
      baseDir = Directory.systemTemp.path;
    } else {
      // Em produção: usar path padrão do sqflite
      baseDir = await getDatabasesPath();
    }
    
    final flightsDir = Directory(join(baseDir, 'flights'));
    
    // Criar diretório se não existe
    if (!await flightsDir.exists()) {
      await flightsDir.create(recursive: true);
    }
    
    return flightsDir.path;
  }

  /// 📍 Gerar path completo para database de um voo
  /// 
  /// Example: /data/flights/flight_abc123-def456.db
  static Future<String> getDatabasePath(String flightId) async {
    final dir = await _databasesDirectory;
    return join(dir, 'flight_$flightId.db');
  }

  /// ✨ Criar novo database para voo
  /// 
  /// - Executa migration v1
  /// - Retorna database aberto e pronto
  /// - Armazena referência em _openDatabases
  /// 
  /// Throws:
  /// - Exception se já existe DB com mesmo flightId
  static Future<Database> create(String flightId) async {
    // Verificar se já existe
    final path = await getDatabasePath(flightId);
    
    if (await databaseExists(path)) {
      throw Exception('Database already exists for flight: $flightId');
    }

    // Criar e executar migration
    final db = await openDatabase(
      path,
      version: MigrationV1.version,
      onCreate: (db, version) async {
        // Executar migration v1
        await db.execute(MigrationV1.create);
      },
    );

    // Armazenar referência
    _openDatabases[flightId] = db;

    return db;
  }

  /// 📖 Abrir database existente de um voo
  /// 
  /// - Retorna database se já aberto
  /// - Abre database se existir no filesystem
  /// - Executa migrations pendentes se necessário
  /// 
  /// Throws:
  /// - Exception se database não existe
  static Future<Database> open(String flightId) async {
    // Se já está aberto, retorna referência
    if (_openDatabases.containsKey(flightId)) {
      return _openDatabases[flightId]!;
    }

    final path = await getDatabasePath(flightId);

    // Verificar se existe
    if (!await databaseExists(path)) {
      throw Exception('Database not found for flight: $flightId');
    }

    // Abrir database
    final db = await openDatabase(
      path,
      version: MigrationV1.version,
      onUpgrade: (db, oldVersion, newVersion) async {
        // TODO: Implementar migrations futuras (v2, v3, etc)
        // Por enquanto só temos v1
      },
    );

    // Armazenar referência
    _openDatabases[flightId] = db;

    return db;
  }

  /// 🔒 Fechar database de um voo
  /// 
  /// - Remove referência de _openDatabases
  /// - Fecha conexão SQLite
  /// - Safe para chamar múltiplas vezes
  static Future<void> close(String flightId) async {
    if (_openDatabases.containsKey(flightId)) {
      final db = _openDatabases[flightId]!;
      await db.close();
      _openDatabases.remove(flightId);
    }
  }

  /// 🗑️ Deletar database de um voo
  /// 
  /// - Fecha database se estiver aberto
  /// - Deleta arquivo .db do filesystem
  /// - Útil para cleanup após sync bem-sucedido
  /// 
  /// Throws:
  /// - Exception se database não existe
  static Future<void> delete(String flightId) async {
    // Fechar se estiver aberto
    await close(flightId);

    final path = await getDatabasePath(flightId);

    // Verificar se existe
    if (!await databaseExists(path)) {
      throw Exception('Database not found for flight: $flightId');
    }

    // Deletar arquivo
    await deleteDatabase(path);
  }

  /// 📋 Listar todos os databases de voos existentes
  /// 
  /// Returns: Lista de flightIds
  /// 
  /// Example: ['abc123', 'def456', 'xyz789']
  static Future<List<String>> listAllFlights() async {
    final dir = await _databasesDirectory;
    final directory = Directory(dir);

    if (!await directory.exists()) {
      return [];
    }

    final files = await directory.list().toList();
    
    final flightIds = files
        .where((file) => file.path.endsWith('.db'))
        .map((file) {
          // Extrair flightId do filename
          // flight_abc123.db → abc123
          final filename = basename(file.path);
          return filename
              .replaceFirst('flight_', '')
              .replaceFirst('.db', '');
        })
        .toList();

    return flightIds;
  }

  /// 🔄 Listar databases pendentes de sync
  /// 
  /// - Lê todos os databases
  /// - Filtra por sync_status = 'pending' ou 'failed'
  /// - Útil para UI mostrar "X voos pendentes"
  /// 
  /// Returns: Lista de flightIds pendentes
  static Future<List<String>> listPendingSync() async {
    final allFlights = await listAllFlights();
    final pendingFlights = <String>[];

    for (final flightId in allFlights) {
      try {
        // Abrir DB temporariamente
        final db = await open(flightId);

        // Query sync_status
        final result = await db.query(
          'flight_session',
          columns: ['sync_status'],
          limit: 1,
        );

        if (result.isNotEmpty) {
          final syncStatus = result.first['sync_status'] as String;
          if (syncStatus == 'pending' || syncStatus == 'failed') {
            pendingFlights.add(flightId);
          }
        }

        // Fechar DB
        await close(flightId);
      } catch (e) {
        // Se erro ao ler DB, considerar pendente por segurança
        pendingFlights.add(flightId);
      }
    }

    return pendingFlights;
  }

  /// 📊 Obter informações de um database (metadata)
  /// 
  /// Returns: Map com informações do voo
  /// 
  /// Example:
  /// {
  ///   'flightId': 'abc123',
  ///   'status': 'completed',
  ///   'syncStatus': 'pending',
  ///   'totalPoints': 72000,
  ///   'startTime': 1234567890000,
  ///   'sizeBytes': 2500000
  /// }
  static Future<Map<String, dynamic>?> getDatabaseInfo(String flightId) async {
    try {
      final path = await getDatabasePath(flightId);

      // Verificar se existe
      if (!await databaseExists(path)) {
        return null;
      }

      // Abrir DB
      final db = await open(flightId);

      // Query flight_session
      final result = await db.query(
        'flight_session',
        limit: 1,
      );

      if (result.isEmpty) {
        await close(flightId);
        return null;
      }

      final session = result.first;

      // Obter tamanho do arquivo
      final file = File(path);
      final sizeBytes = await file.length();

      // Fechar DB
      await close(flightId);

      return {
        'flightId': flightId,
        'status': session['status'],
        'syncStatus': session['sync_status'],
        'totalPoints': session['total_points'],
        'startTime': session['start_time'],
        'endTime': session['end_time'],
        'sizeBytes': sizeBytes,
        'instructorId': session['instructor_id'],
        'studentId': session['student_id'],
        'aircraftId': session['aircraft_id'],
      };
    } catch (e) {
      return null;
    }
  }

  /// 🧹 Fechar todas as conexões abertas
  /// 
  /// Útil para:
  /// - Cleanup na finalização do app
  /// - Testes
  /// - Reset de estado
  static Future<void> closeAll() async {
    final flightIds = _openDatabases.keys.toList();
    
    for (final flightId in flightIds) {
      await close(flightId);
    }
  }

  /// 📈 Estatísticas gerais de databases
  /// 
  /// Returns: Map com estatísticas agregadas
  /// 
  /// Example:
  /// {
  ///   'totalFlights': 5,
  ///   'pendingSync': 3,
  ///   'totalSizeBytes': 12500000,
  ///   'totalPoints': 360000
  /// }
  static Future<Map<String, dynamic>> getStatistics() async {
    final allFlights = await listAllFlights();
    final pendingFlights = await listPendingSync();

    int totalSizeBytes = 0;
    int totalPoints = 0;

    for (final flightId in allFlights) {
      final info = await getDatabaseInfo(flightId);
      if (info != null) {
        totalSizeBytes += info['sizeBytes'] as int;
        totalPoints += (info['totalPoints'] as int?) ?? 0;
      }
    }

    return {
      'totalFlights': allFlights.length,
      'pendingSync': pendingFlights.length,
      'synced': allFlights.length - pendingFlights.length,
      'totalSizeBytes': totalSizeBytes,
      'totalSizeMB': (totalSizeBytes / 1024 / 1024).toStringAsFixed(2),
      'totalPoints': totalPoints,
    };
  }

  /// ⚠️ Verificar integridade de um database
  /// 
  /// - Executa PRAGMA integrity_check
  /// - Verifica se tabelas existem
  /// 
  /// Returns: true se database íntegro
  static Future<bool> checkIntegrity(String flightId) async {
    try {
      final db = await open(flightId);

      // PRAGMA integrity_check
      final result = await db.rawQuery('PRAGMA integrity_check');
      
      if (result.isEmpty || result.first.values.first != 'ok') {
        await close(flightId);
        return false;
      }

      // Verificar se tabelas essenciais existem
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );

      final tableNames = tables.map((t) => t['name']).toList();
      
      final requiredTables = [
        'flight_session',
        'telemetry_points',
        'evaluation',
        'photos',
      ];

      for (final table in requiredTables) {
        if (!tableNames.contains(table)) {
          await close(flightId);
          return false;
        }
      }

      await close(flightId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 🧹 Deletar TODOS os databases (uso em testes)
  /// 
  /// ⚠️ CUIDADO: Deleta permanentemente todos os voos!
  /// Útil para cleanup em testes e reset completo.
  static Future<void> deleteAll() async {
    // Fechar todas conexões primeiro
    await closeAll();
    
    // Listar todos os flights
    final allFlights = await listAllFlights();
    
    // Deletar cada um
    for (final flightId in allFlights) {
      try {
        final path = await getDatabasePath(flightId);
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Ignorar erros de delete individual
      }
    }
  }
}