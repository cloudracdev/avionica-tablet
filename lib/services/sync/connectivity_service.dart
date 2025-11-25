/// 📡 CONNECTIVITY SERVICE
///
/// Detecta estado da conexão de rede
/// Notifica quando WiFi conecta/desconecta
///
/// Padrão: Stream-based para reatividade

import 'dart:async';

/// 🌐 Tipos de conexão
enum ConnectivityType {
  none,
  wifi,
  mobile,
  ethernet,
}

/// 📊 Estado da conectividade
class ConnectivityState {
  final ConnectivityType type;
  final bool isConnected;
  final DateTime timestamp;

  const ConnectivityState({
    required this.type,
    required this.isConnected,
    required this.timestamp,
  });

  factory ConnectivityState.disconnected() {
    return ConnectivityState(
      type: ConnectivityType.none,
      isConnected: false,
      timestamp: DateTime.now(),
    );
  }

  factory ConnectivityState.wifi() {
    return ConnectivityState(
      type: ConnectivityType.wifi,
      isConnected: true,
      timestamp: DateTime.now(),
    );
  }

  factory ConnectivityState.mobile() {
    return ConnectivityState(
      type: ConnectivityType.mobile,
      isConnected: true,
      timestamp: DateTime.now(),
    );
  }

  /// ✅ Pode fazer sync? (apenas WiFi)
  bool get canSync => type == ConnectivityType.wifi;

  @override
  String toString() => 'ConnectivityState($type, connected: $isConnected)';
}

/// 📡 CONNECTIVITY SERVICE
class ConnectivityService {
  final _controller = StreamController<ConnectivityState>.broadcast();
  ConnectivityState _currentState = ConnectivityState.disconnected();
  Timer? _mockTimer;

  /// 📊 Estado atual
  ConnectivityState get currentState => _currentState;

  /// 📊 Stream de mudanças
  Stream<ConnectivityState> get onConnectivityChanged => _controller.stream;

  /// ✅ Está conectado?
  bool get isConnected => _currentState.isConnected;

  /// ✅ Pode fazer sync? (WiFi only)
  bool get canSync => _currentState.canSync;

  /// 🚀 Inicializar serviço
  /// 
  /// TODO: Implementar com connectivity_plus package
  /// Por agora usa mock que simula WiFi conectado
  Future<void> initialize() async {
    // Mock: assume WiFi conectado
    _updateState(ConnectivityState.wifi());
  }

  /// 📡 Atualizar estado manualmente (para testes)
  void updateState(ConnectivityState state) {
    _updateState(state);
  }

  /// 🔌 Simular desconexão (para testes)
  void simulateDisconnect() {
    _updateState(ConnectivityState.disconnected());
  }

  /// 📶 Simular WiFi conectado (para testes)
  void simulateWifiConnected() {
    _updateState(ConnectivityState.wifi());
  }

  /// 📱 Simular dados móveis (para testes)
  void simulateMobileConnected() {
    _updateState(ConnectivityState.mobile());
  }

  /// 🔄 Atualizar estado interno
  void _updateState(ConnectivityState state) {
    _currentState = state;
    _controller.add(state);
  }

  /// 🧹 Dispose
  void dispose() {
    _mockTimer?.cancel();
    _controller.close();
  }
}