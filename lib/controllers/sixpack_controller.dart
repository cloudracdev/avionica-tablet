import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/websocket_provider.dart';
import '../providers/connection_watchdog_provider.dart';
import '../screens/connection_screen.dart';

/// 🎮 CONTROLLER: Lógica de negócio da SixPackScreen
/// 
/// Gerencia conexões, watchdog, e navegação
class SixPackController {
  final WidgetRef _ref;
  final BuildContext _context;

  SixPackController(this._ref, this._context);

  /// 🐕 Inicializar watchdog de conexão
  void initializeWatchdog() {
    // Inicializar watchdog provider
    _ref.read(connectionWatchdogProvider);
    
    // Escutar notificações do watchdog
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

  /// 📱 Configurar orientações permitidas
  void setupOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// 🔄 Reconectar ao ESP32
  void reconnect() {
    final wsService = _ref.read(webSocketServiceProvider);
    final ip = _ref.read(ipAddressProvider);
    final watchdog = _ref.read(connectionWatchdogProvider);
    
    // Desconectar
    wsService.disconnect();
    
    // Aguardar 500ms e reconectar
    Future.delayed(const Duration(milliseconds: 500), () {
      wsService.connect(ip);
      _ref.read(connectionStateProvider.notifier).state = true;
      watchdog.reset();
    });
    
    // Feedback visual
    _showSnackBar(
      message: '🔄 Reconectando...',
      duration: const Duration(seconds: 1),
    );
  }

  /// ❌ Desconectar e voltar para ConnectionScreen
  Future<void> disconnect() async {
    // Confirmar ação
    final shouldDisconnect = await _showConfirmDialog(
      title: '⚠️ Desconectar',
      content: 'Deseja desconectar do ESP32?',
    );
    
    if (shouldDisconnect != true) return;
    
    // Desconectar ESP32
    final wsService = _ref.read(webSocketServiceProvider);
    wsService.disconnect();
    _ref.read(connectionStateProvider.notifier).state = false;
    
    // Feedback visual
    _showSnackBar(
      message: '❌ Desconectado do ESP32',
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    );
    
    // Aguardar e navegar
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_context.mounted) {
      Navigator.pushReplacement(
        _context,
        MaterialPageRoute(
          builder: (context) => const ConnectionScreen(),
        ),
      );
    }
  }

  /// 📢 Mostrar SnackBar
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

  /// ❓ Mostrar dialog de confirmação
  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: _context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    );
  }
}