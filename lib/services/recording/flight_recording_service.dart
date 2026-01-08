/// 🎬 FLIGHT RECORDING SERVICE
/// 
/// Grava dados REAIS de telemetria no SQLite
/// 
/// ⚠️ IMPORTANTE: Grava APENAS dados REAIS, NUNCA interpolados!

import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../models/telemetry_data.dart';
import '../../data/database/flight_database.dart';
import '../../data/database/models/flight_session_entity.dart';
import '../../data/database/models/telemetry_point_entity.dart';
import '../../data/repositories/flight_session_repository.dart';
import '../../data/repositories/telemetry_point_repository.dart';
import '../../core/utils/logger.dart';

class FlightRecordingService {
  final FlightSessionRepository _sessionRepository;
  final TelemetryPointRepository _pointRepository;
  final Uuid _uuid = const Uuid();

  bool _isRecording = false;
  String? _currentFlightId;
  DateTime? _startTime;
  int _pointsRecorded = 0;

  final List<TelemetryPointEntity> _buffer = [];
  static const int _bufferSize = 10;
  Timer? _flushTimer;

  FlightRecordingService({
    FlightSessionRepository? sessionRepository,
    TelemetryPointRepository? pointRepository,
  })  : _sessionRepository = sessionRepository ?? FlightSessionRepository(),
        _pointRepository = pointRepository ?? TelemetryPointRepository();

  bool get isRecording => _isRecording;
  String? get currentFlightId => _currentFlightId;
  int get pointsRecorded => _pointsRecorded;
  
  Duration get recordingDuration {
    if (_startTime == null) return Duration.zero;
    return DateTime.now().difference(_startTime!);
  }

  /// 🟢 INICIAR GRAVAÇÃO
  Future<String> startRecording({
    required String instructorId,
    String? studentId,
    required String aircraftId,
    int? tabletBatteryStart,
  }) async {
    if (_isRecording) {
      throw Exception('Já existe gravação em andamento: $_currentFlightId');
    }

    final flightId = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    
    Logger.info('🎬 Iniciando gravação: $flightId', 'Recording');

    try {
      await FlightDatabase.create(flightId);

      final session = FlightSessionEntity(
        id: flightId,
        instructorId: instructorId,
        studentId: studentId,
        aircraftId: aircraftId,
        startTime: now,
        createdAt: now,
        updatedAt: now,
        status: 'active',
        syncStatus: 'pending',
        tabletBatteryStart: tabletBatteryStart,
      );

      await _sessionRepository.insert(flightId, session);

      _isRecording = true;
      _currentFlightId = flightId;
      _startTime = DateTime.now();
      _pointsRecorded = 0;
      _buffer.clear();

      _flushTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _flushBuffer();
      });

      Logger.info('✅ Gravação iniciada: $flightId', 'Recording');
      
      return flightId;
    } catch (e) {
      Logger.error('❌ Erro ao iniciar gravação', e, null, 'Recording');
      try {
        await FlightDatabase.delete(flightId);
      } catch (_) {}
      rethrow;
    }
  }

  /// 📍 GRAVAR PONTO
  Future<void> recordPoint(TelemetryData data) async {
    if (!_isRecording || _currentFlightId == null) return;

    final entity = TelemetryPointEntity.fromTelemetryData(
      data,
      _currentFlightId!,
    );

    _buffer.add(entity);

    if (_buffer.length >= _bufferSize) {
      await _flushBuffer();
    }
  }

  /// 💾 FLUSH BUFFER
  Future<void> _flushBuffer() async {
    if (_buffer.isEmpty || _currentFlightId == null) return;

    final pointsToSave = List<TelemetryPointEntity>.from(_buffer);
    _buffer.clear();

    try {
      await _pointRepository.insertBatch(_currentFlightId!, pointsToSave);
      _pointsRecorded += pointsToSave.length;
      
      Logger.debug(
        '💾 Salvou ${pointsToSave.length} pontos (total: $_pointsRecorded)',
        'Recording',
      );
    } catch (e) {
      Logger.error('❌ Erro ao salvar pontos', e, null, 'Recording');
      _buffer.insertAll(0, pointsToSave);
    }
  }

  /// 🔴 FINALIZAR GRAVAÇÃO
  Future<void> stopRecording({int? tabletBatteryEnd}) async {
    if (!_isRecording || _currentFlightId == null) {
      throw Exception('Nenhuma gravação em andamento');
    }

    final flightId = _currentFlightId!;
    
    Logger.info('🛑 Finalizando gravação: $flightId', 'Recording');

    try {
      _flushTimer?.cancel();
      _flushTimer = null;

      await _flushBuffer();

      final stats = await _pointRepository.getFlightStats(flightId);
      
      final session = await _sessionRepository.getById(flightId);
      if (session != null) {
        final durationMs = stats['duration_ms'] as int? ?? 0;
        
        final updated = session.copyWith(
          endTime: DateTime.now().millisecondsSinceEpoch,
          status: 'completed',
          totalPoints: _pointsRecorded,
          durationSeconds: (durationMs / 1000).round(),
          maxAltitude: stats['max_altitude'] as double?,
          maxVelocity: stats['max_velocity'] as double?,
          tabletBatteryEnd: tabletBatteryEnd,
        );
        
        await _sessionRepository.update(flightId, updated);
      }

      await FlightDatabase.close(flightId);

      Logger.info(
        '✅ Gravação finalizada: $flightId ($_pointsRecorded pontos)',
        'Recording',
      );

    } finally {
      _isRecording = false;
      _currentFlightId = null;
      _startTime = null;
      _pointsRecorded = 0;
      _buffer.clear();
    }
  }

  /// 🔍 VERIFICAR VOO ATIVO (CRASH RECOVERY)
  Future<FlightSessionEntity?> getActiveSession() async {
    final activeSessions = await _sessionRepository.getByStatus('active');
    if (activeSessions.isEmpty) return null;
    return activeSessions.first;
  }

  /// 🔄 RETOMAR VOO (CRASH RECOVERY)
  Future<void> resumeRecording(String flightId) async {
    if (_isRecording) {
      throw Exception('Já existe gravação em andamento');
    }

    Logger.info('🔄 Retomando gravação: $flightId', 'Recording');

    final session = await _sessionRepository.getById(flightId);
    if (session == null) {
      throw Exception('Voo não encontrado: $flightId');
    }

    if (session.status != 'active') {
      throw Exception('Voo não está ativo: ${session.status}');
    }

    final existingPoints = await _pointRepository.countByFlight(flightId);

    _isRecording = true;
    _currentFlightId = flightId;
    _startTime = DateTime.fromMillisecondsSinceEpoch(session.startTime);
    _pointsRecorded = existingPoints;
    _buffer.clear();

    _flushTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _flushBuffer();
    });

    Logger.info(
      '✅ Gravação retomada: $flightId ($existingPoints pontos existentes)',
      'Recording',
    );
  }

  /// 🗑️ DESCARTAR VOO
  Future<void> discardRecording(String flightId) async {
    Logger.info('🗑️ Descartando voo: $flightId', 'Recording');
    
    if (_currentFlightId == flightId) {
      _flushTimer?.cancel();
      _isRecording = false;
      _currentFlightId = null;
      _startTime = null;
      _pointsRecorded = 0;
      _buffer.clear();
    }

    try {
      await FlightDatabase.delete(flightId);
    } catch (_) {}

    Logger.info('✅ Voo descartado: $flightId', 'Recording');
  }

  void dispose() {
    _flushTimer?.cancel();
    _buffer.clear();
  }
}
