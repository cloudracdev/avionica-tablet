/// 🌐 INTERFACE SYNC REMOTE SERVICE
///
/// Contrato para envio de dados ao backend
/// Permite mock para testes e troca fácil de implementação
///
/// Implementações:
/// - MockSyncRemoteService (agora)
/// - SupabaseSyncRemoteService (quando Davi implementar)

import '../../data/database/models/flight_session_entity.dart';

/// 📦 Resultado de uma tentativa de sync
class SyncResult {
  final bool success;
  final String? errorMessage;
  final String? remoteId;
  final int? serverTimestamp;

  const SyncResult({
    required this.success,
    this.errorMessage,
    this.remoteId,
    this.serverTimestamp,
  });

  factory SyncResult.ok({String? remoteId, int? serverTimestamp}) {
    return SyncResult(
      success: true,
      remoteId: remoteId,
      serverTimestamp: serverTimestamp,
    );
  }

  factory SyncResult.error(String message) {
    return SyncResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// 🔌 Interface para serviço de sync remoto
abstract class ISyncRemoteService {
  /// 📤 Enviar flight session para backend
  Future<SyncResult> uploadFlightSession(FlightSessionEntity session);

  /// 📤 Enviar telemetria de um voo
  Future<SyncResult> uploadTelemetry(String flightId, List<Map<String, dynamic>> points);

  /// 🔍 Verificar se voo já existe no servidor
  Future<bool> existsOnServer(String flightId);

  /// 📥 Buscar versão do servidor (para conflict resolution)
  Future<int?> getServerVersion(String flightId);
}

/// 🧪 MOCK IMPLEMENTATION (para testes e desenvolvimento)
class MockSyncRemoteService implements ISyncRemoteService {
  /// Simular falha? (para testar retry)
  bool simulateFailure;
  
  /// Delay simulado (ms)
  int simulatedDelayMs;
  
  /// Contador de chamadas (para testes)
  int uploadCallCount = 0;

  MockSyncRemoteService({
    this.simulateFailure = false,
    this.simulatedDelayMs = 100,
  });

  @override
  Future<SyncResult> uploadFlightSession(FlightSessionEntity session) async {
    uploadCallCount++;
    
    // Simular latência de rede
    await Future.delayed(Duration(milliseconds: simulatedDelayMs));

    if (simulateFailure) {
      return SyncResult.error('Mock: Simulated network failure');
    }

    return SyncResult.ok(
      remoteId: 'remote_${session.id}',
      serverTimestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<SyncResult> uploadTelemetry(
    String flightId,
    List<Map<String, dynamic>> points,
  ) async {
    await Future.delayed(Duration(milliseconds: simulatedDelayMs));

    if (simulateFailure) {
      return SyncResult.error('Mock: Simulated upload failure');
    }

    return SyncResult.ok(
      serverTimestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<bool> existsOnServer(String flightId) async {
    await Future.delayed(Duration(milliseconds: simulatedDelayMs ~/ 2));
    return false; // Mock sempre retorna false
  }

  @override
  Future<int?> getServerVersion(String flightId) async {
    await Future.delayed(Duration(milliseconds: simulatedDelayMs ~/ 2));
    return null; // Mock não tem versão
  }

  /// 🧪 Reset contador para testes
  void resetCallCount() {
    uploadCallCount = 0;
  }
}