import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/websocket_provider.dart';
import '../providers/telemetry_provider.dart';
import '../providers/telemetry_settings_provider.dart';
import '../providers/connection_watchdog_provider.dart';

class SixPackController {
  final WidgetRef _ref;
  final BuildContext _context;

  SixPackController(this._ref, this._context);

  void initializeWatchdog() {
    _ref.read(connectionWatchdogProvider);

    _ref.listenManual(watchdogNotificationProvider, (previous, next) {
      if (next != null) {
        _showSnackBar(
          message: next,
          backgroundColor: next.contains('❌') ? Colors.red : Colors.orange,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  void setupOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void reconnect() {
    final wsService = _ref.read(webSocketServiceProvider);
    final ip = _ref.read(ipAddressProvider);
    final watchdog = _ref.read(connectionWatchdogProvider);

    _ref.read(calibrationServiceProvider).resetAll();

    wsService.disconnect();

    Future.delayed(const Duration(milliseconds: 500), () {
      wsService.connect(ip);
      _ref.read(connectionStateProvider.notifier).state = true;
      watchdog.reset();
    });

    _showSnackBar(
      message: '🔄 Reconectando...',
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> disconnect() async {
    final shouldDisconnect = await _showConfirmDialog(
      title: '⚠️ Desconectar',
      content: 'Deseja desconectar do ESP32?',
    );

    if (shouldDisconnect != true) return;

    final wsService = _ref.read(webSocketServiceProvider);
    final watchdog = _ref.read(connectionWatchdogProvider);

    wsService.disconnect();
    watchdog.reset();
    _ref.read(connectionStateProvider.notifier).state = false;

    _ref.read(calibrationServiceProvider).resetAll();

    _showSnackBar(
      message: '❌ Desconectado do ESP32',
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (_context.mounted) {
      _context.go('/connection');
    }
  }

  /// 🎯 Toggle interpolação 60fps ON/OFF
  void toggleInterpolation() {
    final settings = _ref.read(telemetrySettingsProvider);
    _ref.read(telemetrySettingsProvider.notifier).toggleInterpolation();

    final newState = !settings.interpolationEnabled;
    _showSnackBar(
      message: newState 
          ? '✨ Interpolação ATIVADA (60fps)' 
          : '📊 Interpolação DESATIVADA (dados brutos)',
      backgroundColor: newState ? Colors.green : Colors.orange,
      duration: const Duration(seconds: 2),
    );
  }

  /// 🔍 Retorna estado atual da interpolação
  bool get isInterpolationEnabled {
    return _ref.read(telemetrySettingsProvider).interpolationEnabled;
  }

  void _showSnackBar({
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!_context.mounted) return;

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: _context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
  }
}
