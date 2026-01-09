/// 🔄 TELEMETRY SYNC SERVICE
///
/// Sincroniza telemetria em tempo real + backlog
/// 
/// Estratégia:
/// - Live: Batch a cada 1s (20 pontos)
/// - Backlog: 100 pontos por request em paralelo
/// - Prioridade: Ponto atual SEMPRE primeiro

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/models/telemetry_point_entity.dart';
import '../../data/repositories/telemetry_point_repository.dart';
import '../../core/utils/logger.dart';
import 'connectivity_service.dart';
import 'supabase_sync_service.dart';

/// 📊 Estado do sync
class TelemetrySyncState {
  final bool isRunning;
  final bool isConnected;
  final int pendingPoints;
  final int syncedPoints;
  final String? currentFlightId;
  final String? supabaseVooId;
  final String? lastError;

  const TelemetrySyncState({
    this.isRunning = false,
    this.isConnected = false,
    this.pendingPoints = 0,
    this.syncedPoints = 0,
    this.currentFlightId,
    this.supabaseVooId,
    this.lastError,
  });

  double get syncPercentage {
    final total = pendingPoints + syncedPoints;
    if (total == 0) return 100.0;
    return (syncedPoints / total) * 100;
  }

  TelemetrySyncState copyWith({
    bool? isRunning,
    bool? isConnected,
    int? pendingPoints,
    int? syncedPoints,
    String? currentFlightId,
    String? supabaseVooId,
    String? lastError,
  }) {
    return TelemetrySyncState(
      isRunning: isRunning ?? this.isRunning,
      isConnected: isConnected ?? this.isConnected,
      pendingPoints: pendingPoints ?? this.pendingPoints,
      syncedPoints: syncedPoints ?? this.syncedPoints,
      currentFlightId: currentFlightId ?? this.currentFlightId,
      supabaseVooId: supabaseVooId ?? this.supabaseVooId,
      lastError: lastError,
    );
  }
}

/// 🔄 TELEMETRY SYNC SERVICE
class TelemetrySyncService {
  final TelemetryPointRepository _repository;
  final SupabaseSyncService _supabaseService;
  final ConnectivityService _connectivity;

  // Estado
  TelemetrySyncState _state = const TelemetrySyncState();
  final _stateController = StreamController<TelemetrySyncState>.broadcast();

  // Timers
  Timer? _liveTimer;
  Timer? _backlogTimer;

  // Buffer para live sync (batch 1s)
  final List<TelemetryPointEntity> _liveBuffer = [];
  static const int _liveBatchIntervalMs = 1000;
  static const int _backlogBatchSize = 100;
  static const int _backlogIntervalMs = 2000;

  // Controle
  bool _isProcessingLive = false;
  bool _isProcessingBacklog = false;
  StreamSubscription<ConnectivityState>? _connectivitySubscription;

  TelemetrySyncService({
    TelemetryPointRepository? repository,
    SupabaseSyncService? supabaseService,
    required ConnectivityService connectivity,
  })  : _repository = repository ?? TelemetryPointRepository(),
        _supabaseService = supabaseService ?? SupabaseSyncService(),
        _connectivity = connectivity;

  /// 📊 Estado atual
  TelemetrySyncState get state => _state;

  /// 📊 Stream de estado
  Stream<TelemetrySyncState> get onStateChanged => _stateController.stream;

  /// 🚀 Iniciar sync para um voo
  Future<void> startSync(String flightId) async {
    if (_state.isRunning) {
      Logger.warning('Sync já está rodando', 'TelemetrySync');
      return;
    }

    Logger.info('🚀 Iniciando sync para voo: $flightId', 'TelemetrySync');

    // Verificar/criar voo no Supabase
    String? supabaseVooId = await _supabaseService.getVooIdByLocalId(flightId);

    _updateState(_state.copyWith(
      isRunning: true,
      currentFlightId: flightId,
      supabaseVooId: supabaseVooId,
      isConnected: _connectivity.canSync,
    ));

    // Escutar mudanças de conectividade
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Iniciar timers
    _startLiveTimer();
    _startBacklogTimer();
  }

  /// 🛑 Parar sync
  Future<void> stopSync() async {
    Logger.info('🛑 Parando sync', 'TelemetrySync');

    _liveTimer?.cancel();
    _backlogTimer?.cancel();
    _connectivitySubscription?.cancel();

    // Flush buffer restante
    if (_liveBuffer.isNotEmpty && _connectivity.canSync) {
      await _processLiveBuffer();
    }

    _updateState(const TelemetrySyncState());
  }

  /// ➕ Adicionar ponto ao buffer live
  void enqueuePoint(TelemetryPointEntity point) {
    _liveBuffer.add(point);
  }

  /// 📡 Callback quando conectividade muda
  void _onConnectivityChanged(ConnectivityState connectivity) {
    final wasConnected = _state.isConnected;
    final isNowConnected = connectivity.canSync;

    _updateState(_state.copyWith(isConnected: isNowConnected));

    if (!wasConnected && isNowConnected) {
      Logger.info('📶 Internet voltou! Iniciando sync...', 'TelemetrySync');
      _processBacklog();
    }
  }

  /// ⏱️ Iniciar timer live (1s)
  void _startLiveTimer() {
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(
      const Duration(milliseconds: _liveBatchIntervalMs),
      (_) => _processLiveBuffer(),
    );
  }

  /// ⏱️ Iniciar timer backlog (2s)
  void _startBacklogTimer() {
    _backlogTimer?.cancel();
    _backlogTimer = Timer.periodic(
      const Duration(milliseconds: _backlogIntervalMs),
      (_) => _processBacklog(),
    );
  }

  /// 🔄 Processar buffer live
  Future<void> _processLiveBuffer() async {
    if (_isProcessingLive) return;
    if (_liveBuffer.isEmpty) return;
    if (!_connectivity.canSync) return;
    if (_state.supabaseVooId == null) {
      await _ensureVooExists();
      if (_state.supabaseVooId == null) return;
    }

    _isProcessingLive = true;

    try {
      // Pegar todos do buffer
      final points = List<TelemetryPointEntity>.from(_liveBuffer);
      _liveBuffer.clear();

      // Enviar para Supabase
      final sent = await _supabaseService.uploadTelemetryBatch(
        _state.supabaseVooId!,
        points,
      );

      if (sent > 0) {
        // Marcar como sincronizados no SQLite
        final ids = points.map((p) => p.id!).toList();
        await _repository.markAsSynced(_state.currentFlightId!, ids);

        _updateState(_state.copyWith(
          syncedPoints: _state.syncedPoints + sent,
        ));
      } else {
        // Falhou - devolver ao buffer para retry
        _liveBuffer.insertAll(0, points);
      }

    } catch (e) {
      Logger.error('❌ Erro no live sync', e, null, 'TelemetrySync');
      _updateState(_state.copyWith(lastError: e.toString()));
    } finally {
      _isProcessingLive = false;
    }
  }

  /// 🔄 Processar backlog (pontos antigos não sincronizados)
  Future<void> _processBacklog() async {
    if (_isProcessingBacklog) return;
    if (!_connectivity.canSync) return;
    if (_state.currentFlightId == null) return;
    if (_state.supabaseVooId == null) {
      await _ensureVooExists();
      if (_state.supabaseVooId == null) return;
    }

    _isProcessingBacklog = true;

    try {
      // Buscar pontos pendentes
      final pending = await _repository.getPendingSync(
        _state.currentFlightId!,
        limit: _backlogBatchSize,
      );

      if (pending.isEmpty) {
        _isProcessingBacklog = false;
        return;
      }

      _updateState(_state.copyWith(pendingPoints: pending.length));

      // Enviar para Supabase
      final sent = await _supabaseService.uploadTelemetryBatch(
        _state.supabaseVooId!,
        pending,
      );

      if (sent > 0) {
        // Marcar como sincronizados
        final ids = pending.take(sent).map((p) => p.id!).toList();
        await _repository.markAsSynced(_state.currentFlightId!, ids);

        // Atualizar contadores
        final stats = await _repository.getSyncStats(_state.currentFlightId!);
        _updateState(_state.copyWith(
          syncedPoints: stats['synced'] as int,
          pendingPoints: stats['pending'] as int,
        ));
      }

    } catch (e) {
      Logger.error('❌ Erro no backlog sync', e, null, 'TelemetrySync');
      _updateState(_state.copyWith(lastError: e.toString()));
    } finally {
      _isProcessingBacklog = false;
    }
  }

  /// 🔍 Garantir que voo existe no Supabase
  Future<void> _ensureVooExists() async {
    if (_state.currentFlightId == null) return;

    // Verificar se já existe
    var vooId = await _supabaseService.getVooIdByLocalId(_state.currentFlightId!);

    if (vooId == null) {
      // Criar voo no Supabase
      // TODO: Buscar session do SQLite e criar
      Logger.warning(
        'Voo não existe no Supabase ainda. Será criado quando finalizar.',
        'TelemetrySync',
      );
    }

    if (vooId != null) {
      _updateState(_state.copyWith(supabaseVooId: vooId));
    }
  }

  /// 🔄 Atualizar estado
  void _updateState(TelemetrySyncState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// 🧹 Dispose
  void dispose() {
    _liveTimer?.cancel();
    _backlogTimer?.cancel();
    _connectivitySubscription?.cancel();
    _stateController.close();
  }
}

/// 🏭 Provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final telemetrySyncServiceProvider = Provider<TelemetrySyncService>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  final service = TelemetrySyncService(connectivity: connectivity);
  ref.onDispose(() => service.dispose());
  return service;
});
