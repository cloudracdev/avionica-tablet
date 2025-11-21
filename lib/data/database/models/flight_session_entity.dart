/// 📦 FLIGHT SESSION ENTITY
/// 
/// Representa uma linha da tabela flight_session no SQLite
/// 
/// Responsabilidades:
/// - Conversão Map ↔ Object
/// - Validações de dados
/// - Immutable model

class FlightSessionEntity {
  final String id;
  final String instructorId;
  final String? studentId;
  final String aircraftId;
  final int startTime;
  final int? endTime;
  final int createdAt;
  final int updatedAt;
  final String status;
  final String syncStatus;
  final int syncAttempts;
  final int? lastSyncAttempt;
  final String? syncError;
  final int totalPoints;
  final int? durationSeconds;
  final double? maxAltitude;
  final double? maxVelocity;
  final double? distanceKm;
  final String? missionType;
  final String? weatherConditions;
  final String? notes;
  final String? deviceId;
  final String? appVersion;
  final double dataLossPercent;
  final int connectionDrops;
  final int? tabletBatteryStart;
  final int? tabletBatteryEnd;
  final double? tabletBatteryDrainRate;

  const FlightSessionEntity({
    required this.id,
    required this.instructorId,
    this.studentId,
    required this.aircraftId,
    required this.startTime,
    this.endTime,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.syncStatus,
    this.syncAttempts = 0,
    this.lastSyncAttempt,
    this.syncError,
    this.totalPoints = 0,
    this.durationSeconds,
    this.maxAltitude,
    this.maxVelocity,
    this.distanceKm,
    this.missionType,
    this.weatherConditions,
    this.notes,
    this.deviceId,
    this.appVersion,
    this.dataLossPercent = 0.0,
    this.connectionDrops = 0,
    this.tabletBatteryStart,
    this.tabletBatteryEnd,
    this.tabletBatteryDrainRate,
  });

  /// 📤 Converter para Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'instructor_id': instructorId,
      'student_id': studentId,
      'aircraft_id': aircraftId,
      'start_time': startTime,
      'end_time': endTime,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'status': status,
      'sync_status': syncStatus,
      'sync_attempts': syncAttempts,
      'last_sync_attempt': lastSyncAttempt,
      'sync_error': syncError,
      'total_points': totalPoints,
      'duration_seconds': durationSeconds,
      'max_altitude': maxAltitude,
      'max_velocity': maxVelocity,
      'distance_km': distanceKm,
      'mission_type': missionType,
      'weather_conditions': weatherConditions,
      'notes': notes,
      'device_id': deviceId,
      'app_version': appVersion,
      'data_loss_percent': dataLossPercent,
      'connection_drops': connectionDrops,
      'tablet_battery_start': tabletBatteryStart,
      'tablet_battery_end': tabletBatteryEnd,
      'tablet_battery_drain_rate': tabletBatteryDrainRate,
    };
  }

  /// 📥 Criar de Map (do SQLite)
  factory FlightSessionEntity.fromMap(Map<String, dynamic> map) {
    return FlightSessionEntity(
      id: map['id'] as String,
      instructorId: map['instructor_id'] as String,
      studentId: map['student_id'] as String?,
      aircraftId: map['aircraft_id'] as String,
      startTime: map['start_time'] as int,
      endTime: map['end_time'] as int?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      status: map['status'] as String,
      syncStatus: map['sync_status'] as String,
      syncAttempts: map['sync_attempts'] as int? ?? 0,
      lastSyncAttempt: map['last_sync_attempt'] as int?,
      syncError: map['sync_error'] as String?,
      totalPoints: map['total_points'] as int? ?? 0,
      durationSeconds: map['duration_seconds'] as int?,
      maxAltitude: map['max_altitude'] as double?,
      maxVelocity: map['max_velocity'] as double?,
      distanceKm: map['distance_km'] as double?,
      missionType: map['mission_type'] as String?,
      weatherConditions: map['weather_conditions'] as String?,
      notes: map['notes'] as String?,
      deviceId: map['device_id'] as String?,
      appVersion: map['app_version'] as String?,
      dataLossPercent: map['data_loss_percent'] as double? ?? 0.0,
      connectionDrops: map['connection_drops'] as int? ?? 0,
      tabletBatteryStart: map['tablet_battery_start'] as int?,
      tabletBatteryEnd: map['tablet_battery_end'] as int?,
      tabletBatteryDrainRate: map['tablet_battery_drain_rate'] as double?,
    );
  }

  /// 🔄 CopyWith para imutabilidade
  FlightSessionEntity copyWith({
    String? id,
    String? instructorId,
    String? studentId,
    String? aircraftId,
    int? startTime,
    int? endTime,
    int? createdAt,
    int? updatedAt,
    String? status,
    String? syncStatus,
    int? syncAttempts,
    int? lastSyncAttempt,
    String? syncError,
    int? totalPoints,
    int? durationSeconds,
    double? maxAltitude,
    double? maxVelocity,
    double? distanceKm,
    String? missionType,
    String? weatherConditions,
    String? notes,
    String? deviceId,
    String? appVersion,
    double? dataLossPercent,
    int? connectionDrops,
    int? tabletBatteryStart,
    int? tabletBatteryEnd,
    double? tabletBatteryDrainRate,
  }) {
    return FlightSessionEntity(
      id: id ?? this.id,
      instructorId: instructorId ?? this.instructorId,
      studentId: studentId ?? this.studentId,
      aircraftId: aircraftId ?? this.aircraftId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      syncAttempts: syncAttempts ?? this.syncAttempts,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      syncError: syncError ?? this.syncError,
      totalPoints: totalPoints ?? this.totalPoints,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      maxAltitude: maxAltitude ?? this.maxAltitude,
      maxVelocity: maxVelocity ?? this.maxVelocity,
      distanceKm: distanceKm ?? this.distanceKm,
      missionType: missionType ?? this.missionType,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      notes: notes ?? this.notes,
      deviceId: deviceId ?? this.deviceId,
      appVersion: appVersion ?? this.appVersion,
      dataLossPercent: dataLossPercent ?? this.dataLossPercent,
      connectionDrops: connectionDrops ?? this.connectionDrops,
      tabletBatteryStart: tabletBatteryStart ?? this.tabletBatteryStart,
      tabletBatteryEnd: tabletBatteryEnd ?? this.tabletBatteryEnd,
      tabletBatteryDrainRate: tabletBatteryDrainRate ?? this.tabletBatteryDrainRate,
    );
  }

  /// ✅ Validar entity
  bool isValid() {
    return validate().isEmpty;
  }

  /// 📋 Listar erros de validação
  List<String> validate() {
    final errors = <String>[];

    if (id.isEmpty) {
      errors.add('ID não pode ser vazio');
    }

    if (instructorId.isEmpty) {
      errors.add('Instrutor ID não pode ser vazio');
    }

    if (aircraftId.isEmpty) {
      errors.add('Aeronave ID não pode ser vazio');
    }

    if (startTime <= 0) {
      errors.add('Start time deve ser maior que zero');
    }

    final validStatuses = ['active', 'completed', 'syncing', 'synced', 'failed'];
    if (!validStatuses.contains(status)) {
      errors.add('Status inválido: $status');
    }

    final validSyncStatuses = ['pending', 'in_progress', 'completed', 'failed'];
    if (!validSyncStatuses.contains(syncStatus)) {
      errors.add('Sync status inválido: $syncStatus');
    }

    if (tabletBatteryStart != null && 
        (tabletBatteryStart! < 0 || tabletBatteryStart! > 100)) {
      errors.add('Bateria start deve estar entre 0-100');
    }

    if (tabletBatteryEnd != null && 
        (tabletBatteryEnd! < 0 || tabletBatteryEnd! > 100)) {
      errors.add('Bateria end deve estar entre 0-100');
    }

    return errors;
  }

  /// 📊 Helper: Voo está ativo?
  bool get isActive => status == 'active';

  /// 📊 Helper: Voo está completo?
  bool get isCompleted => status == 'completed';

  /// 📊 Helper: Sync pendente?
  bool get isPendingSync => syncStatus == 'pending' || syncStatus == 'failed';

  /// 📊 Helper: Já sincronizado?
  bool get isSynced => syncStatus == 'completed';

  @override
  String toString() {
    return 'FlightSessionEntity(id: $id, instructor: $instructorId, '
           'aircraft: $aircraftId, status: $status, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlightSessionEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}