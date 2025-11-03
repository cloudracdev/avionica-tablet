import 'package:flutter/material.dart';
import '../services/websocket/websocket_service.dart';
import 'sixpack_screen.dart';

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({Key? key}) : super(key: key);

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  final WebSocketService _wsService = WebSocketService();
  final TextEditingController _ipController = TextEditingController(text: '192.168.4.1');

  // Dados de telemetria
  double _altitude = 0.0;
  double _velocidade = 0.0;
  double _temperatura = 0.0;
  int _satelites = 0;

  @override
  void initState() {
    super.initState();
    
    // Escutar dados do WebSocket
    _wsService.dataStream.listen((data) {
      setState(() {
        _altitude = data['altitude']?.toDouble() ?? 0.0;
        _velocidade = data['velocidade']?.toDouble() ?? 0.0;
        _temperatura = data['temperatura']?.toDouble() ?? 0.0;
        _satelites = data['satelites']?.toInt() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _wsService.dispose();
    _ipController.dispose();
    super.dispose();
  }

  void _conectar() {
    _wsService.connect(_ipController.text);
    
    // Aguardar conexão e navegar para sixpack
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_wsService.isConnected && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SixPackScreen(wsService: _wsService),
          ),
        );
      }
    });
  }

  void _desconectar() {
    _wsService.disconnect();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📡 Telemetria ESP32'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo IP e botões de conexão
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: '🔌 IP do ESP32',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _wsService.isConnected ? null : _conectar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Conectar'),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  onPressed: _wsService.isConnected ? _desconectar : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Desconectar'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status da conexão
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _wsService.isConnected ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _wsService.isConnected ? Icons.check_circle : Icons.cancel,
                    color: _wsService.isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _wsService.isConnected ? '✅ Conectado' : '❌ Desconectado',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Cards de telemetria
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildTelemetryCard('✈️ Altitude', '$_altitude m', Colors.blue),
                  _buildTelemetryCard('⚡ Velocidade', '$_velocidade km/h', Colors.orange),
                  _buildTelemetryCard('🌡️ Temperatura', '$_temperatura °C', Colors.red),
                  _buildTelemetryCard('🛰️ Satélites', '$_satelites', Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard(String title, String value, MaterialColor color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.shade300, color.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
