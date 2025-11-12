import '../../models/flight_data.dart';

/// 🎯 REPOSITORY: Interface abstrata para fontes de dados de telemetria
/// 
/// Permite trocar implementação (WebSocket, Mock, Local, API) sem mudar providers
abstract class TelemetryRepository {
  /// Stream de dados de voo em tempo real
  Stream<FlightData> getFlightDataStream();
  
  /// Conecta à fonte de dados
  Future<void> connect(String address);
  
  /// Desconecta da fonte de dados
  void disconnect();
  
  /// Status de conexão
  bool get isConnected;
  
  /// Libera recursos
  void dispose();
}