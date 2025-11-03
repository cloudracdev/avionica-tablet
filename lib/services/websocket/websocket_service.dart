import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _dataController = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnected = false;

  // Stream para ouvir dados recebidos
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;
  bool get isConnected => _isConnected;

  // Conectar ao ESP32
  void connect(String ipAddress) {
    try {
      final uri = Uri.parse('ws://$ipAddress:81');
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      print('✅ Conectado ao ESP32: $ipAddress');

      // Escutar mensagens
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            _dataController.add(data);
            print('📥 Dados recebidos: $data');
          } catch (e) {
            print('❌ Erro ao decodificar: $e');
          }
        },
        onError: (error) {
          print('❌ Erro na conexão: $error');
          _isConnected = false;
        },
        onDone: () {
          print('⚠️ Conexão fechada');
          _isConnected = false;
        },
      );
    } catch (e) {
      print('❌ Falha ao conectar: $e');
      _isConnected = false;
    }
  }

  // Enviar dados para ESP32
  void sendData(String message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(message);
      print('📤 Enviado: $message');
    }
  }

  // Desconectar
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    print('🔌 Desconectado');
  }

  void dispose() {
    disconnect();
    _dataController.close();
  }
}
