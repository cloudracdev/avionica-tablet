import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/utils/logger.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _dataController = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnected = false;

  // 📊 Contador de pacotes recebidos
  int _packetCount = 0;
  int _lastSecond = 0;
  int _currentPacketsPerSecond = 0;

  // Stream para ouvir dados recebidos
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;
  bool get isConnected => _isConnected;
  int get packetsPerSecond => _currentPacketsPerSecond;

  // Conectar ao ESP32
  void connect(String ipAddress) {
    try {
      final uri = Uri.parse('ws://$ipAddress:81');
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      Logger.info('Conectado ao ESP32: $ipAddress', 'WebSocket');

      // Escutar mensagens
      _channel!.stream.listen(
        (message) {
          try {
            // 📊 Contar pacotes por segundo
            final currentSecond = DateTime.now().second;
            if (currentSecond != _lastSecond) {
              _currentPacketsPerSecond = _packetCount;
              if (_packetCount > 0) {
                Logger.info('📊 Recebendo $_packetCount pacotes/s', 'WebSocket');
              }
              _packetCount = 0;
              _lastSecond = currentSecond;
            }
            _packetCount++;

            final data = jsonDecode(message);
            _dataController.add(data);
            
            // ✅ Log reduzido: apenas a cada segundo
            // Logger.debug('Dados recebidos: $data', 'WebSocket');
          } catch (e) {
            Logger.error('Erro ao decodificar mensagem', e, null, 'WebSocket');
          }
        },
        onError: (error) {
          Logger.error('Erro na conexão', error, null, 'WebSocket');
          _isConnected = false;
        },
        onDone: () {
          Logger.warning('Conexão fechada', 'WebSocket');
          _isConnected = false;
        },
      );
    } catch (e) {
      Logger.error('Falha ao conectar', e, null, 'WebSocket');
      _isConnected = false;
    }
  }

  // Enviar dados para ESP32
  void sendData(String message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(message);
      Logger.debug('Enviado: $message', 'WebSocket');
    }
  }

  // Desconectar
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    _packetCount = 0;
    _currentPacketsPerSecond = 0;
    Logger.info('Desconectado', 'WebSocket');
  }

  void dispose() {
    disconnect();
    _dataController.close();
  }
}