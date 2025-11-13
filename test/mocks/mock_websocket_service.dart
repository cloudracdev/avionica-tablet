import 'dart:async';

/// 🎭 Mock simples do WebSocketService
class MockWebSocketService {
  bool _isConnected = false;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get dataStream => _controller.stream;
  bool get isConnected => _isConnected;
  int get packetsPerSecond => 20;

  void connect(String ipAddress) {
    _isConnected = true;
  }

  void disconnect() {
    _isConnected = false;
  }

  void sendData(String message) {}

  /// 🎯 Simular dados de teste
  void emitTestData(Map<String, dynamic> data) {
    _controller.add(data);
  }

  void dispose() {
    _controller.close();
  }
}