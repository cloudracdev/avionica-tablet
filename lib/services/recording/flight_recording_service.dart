/// 🎬 FLIGHT RECORDING SERVICE
/// 
/// Grava dados REAIS de telemetria no SQLite
/// Sincroniza com Supabase se tiver internet
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
import '../sync/connectivity_service.dart';
import '../sync/supabase_sync_service.dart';

class FlightRecordingService {
  final FlightSessionRepository _sessionRepository;
  final TelemetryPointRepository _pointRepository;
  final ConnectivityService _connectivity;
  final SupabaseSyncService _supabaseService;
  final Uuid _uuid = const Uuid();

  bool _isRecording = false;
  String? _currentFlightId;
  String? _supabaseVooId;
  DateTime? _startTime;
  int _pointsRecorded = 0;
  int _pointsSynced = 0;

  final List<TelemetryPointEntity> _buffer = [];
  final List<TelemetryPointEntity> _syncBuffer = [];
  static const int _bufferSize = 10;
  static const int _syncBatchSize = 20;
  Timer? _flushTimer;
  Timer? _syncTimer;

  FlightRecordingService({
    FlightSessionRepository? sessionRepository,
    TelemetryPointRepository? pointRepository,
    ConnectivityService? connectivity,
    SupabaseSyncService? supabaseService,
  })  : _sessionRepository = sessionRepository ?? FlightSessionRepository(),
        _pointRepository = pointRepository ?? TelemetryPointRepository(),
        _connectivity = connectivity ?? ConnectivityService(),
        _supabaseService = supabaseService ?? SupabaseSyncService();

  bool get isRecording => _isRecording;
  String? get currentFlightId => _currentFlightId;
  String? get supabaseVooId => _supabaseVooId;
  int get pointsRecorded => _pointsRecorded;
  int get pointsSynced => _pointsSynced;
  bool get isSyncing => _supabaseVooId != null;
  
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
      _pointsSynced = 0;
      _buffer.clear();
      _syncBuffer.clear();
      _supabaseVooId = null;

      _flushTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _flushBuffer();
      });

      _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _syncToSupabase();
      });

      // 🌐 Se tiver internet, cria voo no Supabase
      if (_connectivity.canSync) {
        _createSupabaseVoo(session);
      }

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

  /// 🌐 CRIAR VOO NO SUPABASE
  Future<void> _createSupabaseVoo(FlightSessionEntity session) async {
    print('🌐 _createSupabaseVoo: session.id=${session.id}');
    try {
      final vooId = await _supabaseService.createFlight(session);
      if (vooId != null) {
        _supabaseVooId = vooId;
        print('✅ _supabaseVooId setado: $vooId');
        Logger.info('🌐 Voo criado no Supabase: $vooId', 'Recording');
      }
    } catch (e) {
      Logger.error('❌ Erro ao criar voo no Supabase', e, null, 'Recording');
    }
  }

  /// 📍 GRAVAR PONTO
  Future<void> recordPoint(TelemetryData data) async {
    print('📍 recordPoint called - isRecording: $_isRecording, buffer: ${_syncBuffer.length}');
    if (!_isRecording || _currentFlightId == null) return;

    final entity = TelemetryPointEntity.fromTelemetryData(
      data,
      _currentFlightId!,
    );

    _buffer.add(entity);
    _syncBuffer.add(entity);

    if (_buffer.length >= _bufferSize) {
      await _flushBuffer();
    }
  }

  /// 💾 FLUSH BUFFER (SQLite)
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

  /// 🌐 SYNC TO SUPABASE
  Future<void> _syncToSupabase() async {
    print('🔄 _syncToSupabase: buffer=${_syncBuffer.length}, vooId=$_supabaseVooId, canSync=${_connectivity.canSync}');
    if (_syncBuffer.isEmpty) return;
    if (!_connectivity.canSync) return;

    // Se não tem voo no Supabase ainda, tenta criar
    if (_supabaseVooId == null && _currentFlightId != null) {
      final session = await _sessionRepository.getById(_currentFlightId!);
      if (session != null) {
        await _createSupabaseVoo(session);
      }
      if (_supabaseVooId == null) { print('❌ _supabaseVooId ainda null, abortando sync'); return; }
    }

    final pointsToSync = List<TelemetryPointEntity>.from(_syncBuffer);
    _syncBuffer.clear();

    try {
      print('📤 Enviando ${pointsToSync.length} pontos para voo $_supabaseVooId');
      final sent = await _supabaseService.uploadTelemetryBatch(
        _supabaseVooId!,
        pointsToSync,
      );

      if (sent > 0) {
        _pointsSynced += sent;
        Logger.debug(
          '🌐 Enviou $sent pontos para Supabase (total: $_pointsSynced)',
          'Recording',
        );
      } else {
        _syncBuffer.insertAll(0, pointsToSync);
        print('⚠️ Upload retornou 0, readicionando ao buffer');
      }
    } catch (e) {
      Logger.error('❌ Erro ao enviar para Supabase', e, null, 'Recording');
      _syncBuffer.insertAll(0, pointsToSync);
        print('⚠️ Upload retornou 0, readicionando ao buffer');
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
      _syncTimer?.cancel();
      _syncTimer = null;

      await _flushBuffer();
      await _syncToSupabase();

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

        // 🌐 Atualiza status no Supabase
        if (_supabaseVooId != null) {
          await _supabaseService.updateFlightStatus(_supabaseVooId!, 'completed');
        }
      }

      await FlightDatabase.close(flightId);

      Logger.info(
        '✅ Gravação finalizada: $flightId ($_pointsRecorded pontos, $_pointsSynced enviados)',
        'Recording',
      );

    } finally {
      _isRecording = false;
      _currentFlightId = null;
      _supabaseVooId = null;
      _startTime = null;
      _pointsRecorded = 0;
      _pointsSynced = 0;
      _buffer.clear();
      _syncBuffer.clear();
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
    _pointsSynced = 0;
    _buffer.clear();
    _syncBuffer.clear();
    _supabaseVooId = null;

    _flushTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _flushBuffer();
    });

    _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncToSupabase();
    });

    // 🌐 Verifica se voo já existe no Supabase
    final existingVooId = await _supabaseService.getVooIdByLocalId(flightId);
    if (existingVooId != null) {
      _supabaseVooId = existingVooId;
    } else if (_connectivity.canSync) {
      await _createSupabaseVoo(session);
    }

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
      _syncTimer?.cancel();
      _isRecording = false;
      _currentFlightId = null;
      _supabaseVooId = null;
      _startTime = null;
      _pointsRecorded = 0;
      _pointsSynced = 0;
      _buffer.clear();
      _syncBuffer.clear();
    }

    try {
      await FlightDatabase.delete(flightId);
    } catch (_) {}

    Logger.info('✅ Voo descartado: $flightId', 'Recording');
  }

  void dispose() {
    _flushTimer?.cancel();
    _syncTimer?.cancel();
    _buffer.clear();
    _syncBuffer.clear();
  }
}
