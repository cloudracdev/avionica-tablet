import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/telemetry_data.dart';
import 'telemetry_provider.dart';
import 'websocket_provider.dart';
import '../core/utils/logger.dart';

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
  
  // 🔄 Tentativas de reconexão
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 3;

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
        _reconnectAttempts = 0; // Reset tentativas ao receber dados
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
    
    if (!isConnected) return; // Se não está conectado, ignora
    
    final secondsSinceLastData = 
        DateTime.now().difference(_lastDataReceived).inSeconds;

    if (secondsSinceLastData >= _timeoutSeconds) {
      Logger.warning(
        '⚠️ Sem dados há ${secondsSinceLastData}s. Reconectando...',
        'Watchdog',
      );
      _attemptReconnect();
    }
  }

  /// 🔄 Tenta reconectar
  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      Logger.error(
        '❌ Falha após $_maxReconnectAttempts tentativas. Parando watchdog.',
        null,
        null,
        'Watchdog',
      );
      _ref.read(connectionStateProvider.notifier).state = false;
      _ref.read(watchdogNotificationProvider.notifier).state = 
          '❌ Conexão perdida após $_maxReconnectAttempts tentativas';
      return;
    }

    _reconnectAttempts++;
    Logger.info(
      '🔄 Tentativa de reconexão $_reconnectAttempts/$_maxReconnectAttempts',
      'Watchdog',
    );

    // ✅ NOTIFICAR USUÁRIO
    _ref.read(watchdogNotificationProvider.notifier).state = 
        '🔄 Reconectando automaticamente... (tentativa $_reconnectAttempts/$_maxReconnectAttempts)';

    // Reconectar
    final wsService = _ref.read(webSocketServiceProvider);
    final ip = _ref.read(ipAddressProvider);
    
    wsService.disconnect();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      wsService.connect(ip);
      _lastDataReceived = DateTime.now(); // Reset timestamp
    });
  }

  /// 🛑 Para watchdog
  void dispose() {
    _watchdogTimer?.cancel();
  }

  /// ♻️ Reset watchdog (quando reconecta manualmente)
  void reset() {
    _lastDataReceived = DateTime.now();
    _reconnectAttempts = 0;
  }
}