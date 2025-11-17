import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/telemetry_data.dart';
import 'telemetry_provider.dart';
import 'websocket_provider.dart';
import '../core/utils/logger.dart';
import '../core/utils/exponential_backoff.dart';

/// 🎯 PROVIDER: Watchdog de conexão
/// Monitora telemetria e reconecta automaticamente se dados param de chegar
final connectionWatchdogProvider = Provider<ConnectionWatchdog>((ref) {
  return ConnectionWatchdog(ref);
});

/// 🎯 PROVIDER: Callback para notificações
final watchdogNotificationProvider = StateProvider<String?>((ref) => null);

/// 🐕 WATCHDOG: Monitora conexão e reconecta automaticamente
class ConnectionWatchdog {
  final Ref _ref;
  Timer? _watchdogTimer;
  DateTime _lastDataReceived = DateTime.now();
  
  // ⏱️ Timeout: se passar X segundos sem dados, reconecta
  final int _timeoutSeconds = 5;
  
  // 🔄 Exponential backoff para reconnect
  final ExponentialBackoff _backoff = ExponentialBackoff(
    initialDelaySeconds: 1.0,
    multiplier: 1.3,
    maxDelaySeconds: 30.0,
    jitterPercent: 0.2,
  );
  
  // 🔒 Flag para evitar múltiplos reconnects simultâneos
  bool _isReconnecting = false;

  ConnectionWatchdog(this._ref) {
    _startWatchdog();
  }

  /// 🎬 Inicia watchdog
  void _startWatchdog() {
    // Escuta telemetria para atualizar timestamp
    _ref.listen<TelemetryData>(
      telemetryProvider,
      (previous, next) {
        _lastDataReceived = DateTime.now();
        
        // ✅ Reset backoff ao receber dados (conexão restaurada)
        if (_backoff.attemptCount > 0) {
          Logger.info(
            '✅ Conexão restaurada após ${_backoff.attemptCount} tentativas',
            'Watchdog',
          );
          _backoff.reset();
          _isReconnecting = false;
          _ref.read(watchdogNotificationProvider.notifier).state = null;
        }
      },
    );

    // Timer que verifica a cada 2 segundos
    _watchdogTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkConnection(),
    );
  }

  /// 🔍 Verifica se conexão está ativa
  void _checkConnection() {
    final isConnected = _ref.read(connectionStateProvider);
    
    if (!isConnected || _isReconnecting) return;
    
    final secondsSinceLastData = 
        DateTime.now().difference(_lastDataReceived).inSeconds;

    if (secondsSinceLastData >= _timeoutSeconds) {
      Logger.warning(
        '⚠️ Sem dados há ${secondsSinceLastData}s. Iniciando reconnect...',
        'Watchdog',
      );
      _attemptReconnect();
    }
  }

  /// 🔄 Tenta reconectar com exponential backoff
  void _attemptReconnect() {
    if (_isReconnecting) return;
    
    _isReconnecting = true;
    
    // Calcula próximo delay
    final delay = _backoff.getNextDelay();
    final attemptNumber = _backoff.attemptCount;
    
    Logger.info(
      '🔄 Tentativa #$attemptNumber - Aguardando ${(delay.inMilliseconds / 1000).toStringAsFixed(1)}s',
      'Watchdog',
    );

    // ✅ NOTIFICAR USUÁRIO
    final delaySeconds = (delay.inMilliseconds / 1000).toStringAsFixed(1);
    _ref.read(watchdogNotificationProvider.notifier).state = 
        '🔄 Reconectando... (tentativa #$attemptNumber em ${delaySeconds}s)';

    // Aguarda delay antes de reconectar
    Future.delayed(delay, () {
      if (!_isReconnecting) return; // Cancelado
      
      Logger.info('📡 Executando reconexão #$attemptNumber', 'Watchdog');
      
      final wsService = _ref.read(webSocketServiceProvider);
      final ip = _ref.read(ipAddressProvider);
      
      wsService.disconnect();
      
      // Pequeno delay antes de conectar novamente
      Future.delayed(const Duration(milliseconds: 300), () {
        wsService.connect(ip);
        _lastDataReceived = DateTime.now();
        _isReconnecting = false;
      });
    });
  }

  /// 🛑 Para watchdog
  void dispose() {
    _watchdogTimer?.cancel();
    _isReconnecting = false;
  }

  /// ♻️ Reset watchdog (quando reconecta manualmente)
  void reset() {
    _lastDataReceived = DateTime.now();
    _backoff.reset();
    _isReconnecting = false;
    _ref.read(watchdogNotificationProvider.notifier).state = null;
  }
  
  /// 📊 Getters para debug
  int get currentAttempt => _backoff.attemptCount;
  bool get isAtCap => _backoff.hasReachedCap;
}