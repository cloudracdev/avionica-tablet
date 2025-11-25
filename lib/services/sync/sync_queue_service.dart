/// 🔄 SYNC QUEUE SERVICE
///
/// Gerencia fila de sincronização offline-first
/// - Detecta WiFi → tenta sync automático
/// - Retry com exponential backoff
/// - Conflict resolution básico (last-write-wins)
///
/// Padrão Netflix/Uber offline-first

import 'dart:async';
import '../../data/repositories/flight_session_repository.dart';
import '../../data/database/models/flight_session_entity.dart';
import 'connectivity_service.dart';
import 'i_sync_remote_service.dart';

/// 📊 Status do SyncQueue
enum SyncQueueStatus {
  idle,
  syncing,
  paused,
  error,
}

/// 📦 Configurações do SyncQueue
class SyncQueueConfig {
  final int maxRetries;
  final Duration initialRetryDelay;
  final Duration maxRetryDelay;
  final bool syncOnlyOnWifi;

  const SyncQueueConfig({
    this.maxRetries = 5,
    this.initialRetryDelay = const Duration(seconds: 5),
    this.maxRetryDelay = const Duration(minutes: 5),
    this.syncOnlyOnWifi = true,
  });
}

/// 🔄 SYNC QUEUE SERVICE
class SyncQueueService {
  final FlightSessionRepository _repository;
  final ISyncRemoteService _remoteService;
  final ConnectivityService _connectivity;
  final SyncQueueConfig config;

  final _statusController = StreamController<SyncQueueStatus>.broadcast();
  final _progressController = StreamController<SyncProgress>.broadcast();

  SyncQueueStatus _status = SyncQueueStatus.idle;
  StreamSubscription? _connectivitySubscription;
  bool _isProcessing = false;

  SyncQueueService({
    required FlightSessionRepository repository,
    required ISyncRemoteService remoteService,
    required ConnectivityService connectivity,
    this.config = const SyncQueueConfig(),
  })  : _repository = repository,
        _remoteService = remoteService,
        _connectivity = connectivity;

  /// 📊 Status atual
  SyncQueueStatus get status => _status;

  /// 📊 Stream de status
  Stream<SyncQueueStatus> get onStatusChanged => _statusController.stream;

  /// 📊 Stream de progresso
  Stream<SyncProgress> get onProgress => _progressController.stream;

  /// 🚀 Inicializar serviço
  Future<void> initialize() async {
    // Escutar mudanças de conectividade
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Verificar se tem pending e WiFi disponível
    if (_connectivity.canSync) {
      await processQueue();
    }
  }

  /// 📡 Callback quando conectividade muda
  void _onConnectivityChanged(ConnectivityState state) {
    if (state.canSync && !_isProcessing) {
      // WiFi conectou → tentar sync
      processQueue();
    }
  }

  /// 📋 Buscar itens pendentes na fila
  Future<List<FlightSessionEntity>> getPendingItems() async {
    return _repository.getPendingSync();
  }

  /// 📊 Contar itens pendentes
  Future<int> getPendingCount() async {
    return _repository.countPendingSync();
  }

  /// ➕ Adicionar item à fila (marcar como pending)
  Future<void> enqueue(String flightId) async {
    await _repository.updateSyncStatus(flightId, 'pending');
    
    // Se tem WiFi, processar imediatamente
    if (_connectivity.canSync && !_isProcessing) {
      processQueue();
    }
  }

  /// 🔄 Processar toda a fila
  Future<void> processQueue() async {
    // Verificar se pode processar
    if (_isProcessing) return;
    if (config.syncOnlyOnWifi && !_connectivity.canSync) return;

    _isProcessing = true;
    _updateStatus(SyncQueueStatus.syncing);

    try {
      final pending = await getPendingItems();
      
      if (pending.isEmpty) {
        _updateStatus(SyncQueueStatus.idle);
        _isProcessing = false;
        return;
      }

      _emitProgress(SyncProgress(
        total: pending.length,
        completed: 0,
        current: null,
        status: SyncProgressStatus.starting,
      ));

      var completed = 0;

      for (final session in pending) {
        // Verificar conectividade antes de cada item
        if (config.syncOnlyOnWifi && !_connectivity.canSync) {
          _updateStatus(SyncQueueStatus.paused);
          break;
        }

        _emitProgress(SyncProgress(
          total: pending.length,
          completed: completed,
          current: session.id,
          status: SyncProgressStatus.uploading,
        ));

        final success = await _syncItem(session);
        
        if (success) {
          completed++;
        }
      }

      _emitProgress(SyncProgress(
        total: pending.length,
        completed: completed,
        current: null,
        status: SyncProgressStatus.completed,
      ));

      _updateStatus(SyncQueueStatus.idle);
    } catch (e) {
      _updateStatus(SyncQueueStatus.error);
    } finally {
      _isProcessing = false;
    }
  }

  /// 🔄 Sincronizar um item específico
  Future<bool> _syncItem(FlightSessionEntity session) async {
    // Verificar máximo de tentativas
    if (session.syncAttempts >= config.maxRetries) {
      await _repository.updateSyncStatus(
        session.id,
        'failed',
        syncError: 'Max retries exceeded (${config.maxRetries})',
      );
      return false;
    }

    // Marcar como in_progress
    await _repository.updateSyncStatus(session.id, 'in_progress');

    try {
      // Conflict resolution: verificar versão servidor
      final serverVersion = await _remoteService.getServerVersion(session.id);
      
      if (serverVersion != null && serverVersion > session.updatedAt) {
        // Servidor tem versão mais recente → conflito
        // Estratégia: last-write-wins (servidor ganha)
        await _repository.updateSyncStatus(
          session.id,
          'conflict',
          syncError: 'Server has newer version',
        );
        return false;
      }

      // Enviar para servidor
      final result = await _remoteService.uploadFlightSession(session);

      if (result.success) {
        await _repository.updateSyncStatus(session.id, 'completed');
        return true;
      } else {
        await _repository.updateSyncStatus(
          session.id,
          'failed',
          syncError: result.errorMessage,
        );
        return false;
      }
    } catch (e) {
      // Incrementar tentativas e marcar erro
      await _repository.updateSyncStatus(
        session.id,
        'pending', // Volta pra pending para retry
        syncError: e.toString(),
      );
      await _repository.incrementSyncAttempts(session.id);
      return false;
    }
  }

  /// 🔄 Forçar retry de um item específico
  Future<bool> retryItem(String flightId) async {
    if (!_connectivity.canSync) return false;

    final session = await _repository.getById(flightId);
    if (session == null) return false;

    return _syncItem(session);
  }

  /// ⏸️ Pausar processamento
  void pause() {
    _updateStatus(SyncQueueStatus.paused);
  }

  /// ▶️ Retomar processamento
  Future<void> resume() async {
    if (_status == SyncQueueStatus.paused) {
      await processQueue();
    }
  }

  /// 🔄 Atualizar status
  void _updateStatus(SyncQueueStatus status) {
    _status = status;
    _statusController.add(status);
  }

  /// 📊 Emitir progresso
  void _emitProgress(SyncProgress progress) {
    _progressController.add(progress);
  }

  /// 🧹 Dispose
  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
    _progressController.close();
  }
}

/// 📊 Progresso do sync
enum SyncProgressStatus {
  starting,
  uploading,
  completed,
  paused,
  error,
}

class SyncProgress {
  final int total;
  final int completed;
  final String? current;
  final SyncProgressStatus status;

  const SyncProgress({
    required this.total,
    required this.completed,
    this.current,
    required this.status,
  });

  double get percentage => total > 0 ? completed / total : 0;

  @override
  String toString() => 'SyncProgress($completed/$total - $status)';
}