import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket/websocket_service.dart';

// 🎯 PROVIDER: Instância única do WebSocketService
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  
  // 🧹 Cleanup automático quando provider é destruído
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

// 🎯 PROVIDER: Estado de conexão (conectado/desconectado)
final connectionStateProvider = StateProvider<bool>((ref) {
  return false; // Inicialmente desconectado
});

// 🎯 PROVIDER: Stream de dados do WebSocket
final telemetryStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  
  // Retorna o stream de dados
  return wsService.dataStream;
});

// 🎯 PROVIDER: IP Address atual
final ipAddressProvider = StateProvider<String>((ref) {
  return ''; // Será preenchido na tela de conexão
});