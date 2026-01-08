/// 🗄️ TELEMETRY POINT REPOSITORY
/// 
/// Repository para operações CRUD na tabela telemetry_points
/// Otimizado para frequência variável (2-60Hz)
/// 
/// ⚠️ IMPORTANTE: Salvar APENAS dados REAIS, NUNCA interpolados!

import 'package:sqflite/sqflite.dart';
import '../database/flight_database.dart';
import '../database/models/telemetry_point_entity.dart';

class TelemetryPointRepository {
  
  /// ➕ Inserir batch de pontos (PERFORMANCE)
  /// 
  /// Usa transaction + batch para máxima performance
  /// 
  /// Returns: número de pontos inseridos
  Future<int> insertBatch(
    String flightId,
    List<TelemetryPointEntity> points,
  ) async {
    if (points.isEmpty) return 0;

    for (final point in points) {
      if (!point.isValid()) {
        final errors = point.validate().join(', ');
        throw Exception('TelemetryPoint inválido: $errors');
      }
    }

    final db = await FlightDatabase.open(flightId);

    final batch = db.batch();

    for (final point in points) {
      batch.insert(
        'telemetry_points',
        point.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }

    await batch.commit(noResult: true);

    return points.length;
  }

  /// ➕ Inserir ponto único
  Future<void> insert(String flightId, TelemetryPointEntity point) async {
    if (!point.isValid()) {
      final errors = point.validate().join(', ');
      throw Exception('TelemetryPoint inválido: $errors');
    }

    final db = await FlightDatabase.open(flightId);

    await db.insert(
      'telemetry_points',
      point.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// 📖 Buscar todos os pontos de um voo
  Future<List<TelemetryPointEntity>> getAllByFlight(String flightId) async {
    final db = await FlightDatabase.open(flightId);

    try {
      final results = await db.query(
        'telemetry_points',
        orderBy: 'timestamp ASC',
      );

      return results.map((map) => TelemetryPointEntity.fromMap(map)).toList();
    } finally {
      await FlightDatabase.close(flightId);
    }
  }

  /// 📖 Buscar pontos por range de tempo (REPLAY)
  Future<List<TelemetryPointEntity>> getByTimeRange(
    String flightId,
    int startTime,
    int endTime,
  ) async {
    final db = await FlightDatabase.open(flightId);

    try {
      final results = await db.query(
        'telemetry_points',
        where: 'timestamp >= ? AND timestamp <= ?',
        whereArgs: [startTime, endTime],
        orderBy: 'timestamp ASC',
      );

      return results.map((map) => TelemetryPointEntity.fromMap(map)).toList();
    } finally {
      await FlightDatabase.close(flightId);
    }
  }

  /// 📊 Contar total de pontos de um voo
  Future<int> countByFlight(String flightId) async {
    final db = await FlightDatabase.open(flightId);

    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM telemetry_points',
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } finally {
      await FlightDatabase.close(flightId);
    }
  }

  /// 📖 Buscar último ponto
  Future<TelemetryPointEntity?> getLastPoint(String flightId) async {
    final db = await FlightDatabase.open(flightId);

    try {
      final results = await db.query(
        'telemetry_points',
        orderBy: 'timestamp DESC',
        limit: 1,
      );

      if (results.isEmpty) return null;
      return TelemetryPointEntity.fromMap(results.first);
    } finally {
      await FlightDatabase.close(flightId);
    }
  }

  /// 📖 Buscar primeiro ponto
  Future<TelemetryPointEntity?> getFirstPoint(String flightId) async {
    final db = await FlightDatabase.open(flightId);

    try {
      final results = await db.query(
        'telemetry_points',
        orderBy: 'timestamp ASC',
        limit: 1,
      );

      if (results.isEmpty) return null;
      return TelemetryPointEntity.fromMap(results.first);
    } finally {
      await FlightDatabase.close(flightId);
    }
  }

  /// 📊 Estatísticas do voo
  Future<Map<String, dynamic>> getFlightStats(String flightId) async {
    final db = await FlightDatabase.open(flightId);

    try {
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_points,
          MIN(timestamp) as start_time,
          MAX(timestamp) as end_time,
          MAX(altitude) as max_altitude,
          MAX(velocity) as max_velocity
        FROM telemetry_points
      ''');

      if (result.isEmpty) {
        return {'total_points': 0};
      }

      final row = result.first;
      final startTime = row['start_time'] as int?;
      final endTime = row['end_time'] as int?;

      return {
        'total_points': row['total_points'] ?? 0,
        'duration_ms': (startTime != null && endTime != null) 
            ? endTime - startTime 
            : 0,
        'max_altitude': row['max_altitude'],
        'max_velocity': row['max_velocity'],
      };
    } finally {
      await FlightDatabase.close(flightId);
    }
  }
}
