import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/mock_telemetry_repository.dart';
import '../data/repositories/websocket_telemetry_repository.dart';
import '../data/repositories/telemetry_repository.dart';
import 'websocket_provider.dart';

/// 🎭 PROVIDER: Estado do modo mock (ON/OFF)
final mockModeProvider = StateProvider<bool>((ref) => false);

/// 🎯 PROVIDER: Repository dinâmico (Mock ou WebSocket)
final telemetryRepositoryProvider = Provider<TelemetryRepository>((ref) {
  final isMockMode = ref.watch(mockModeProvider);
  
  if (isMockMode) {
    // MODO MOCK
    final mockRepo = MockTelemetryRepository();
    
    ref.onDispose(() {
      mockRepo.dispose();
    });
    
    return mockRepo;
  } else {
    // MODO REAL (WebSocket)
    final wsService = ref.watch(webSocketServiceProvider);
    final repository = WebSocketTelemetryRepository(wsService);
    
    ref.onDispose(() {
      repository.dispose();
    });
    
    return repository;
  }
});