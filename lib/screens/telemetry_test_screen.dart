import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/telemetry_provider.dart';
import '../providers/websocket_provider.dart';

/// 🧪 TELA DE TESTE - STEP 3
/// Valida se o Telemetry Provider está processando dados corretamente
class TelemetryTestScreen extends ConsumerWidget {
  const TelemetryTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 📡 Observar telemetria processada
    final telemetry = ref.watch(telemetryProvider);
    
    // 📡 Observar frequência (Hz)
    final hz = ref.watch(telemetryHzProvider);
    
    // 📡 Observar estado de conexão
    final isConnected = ref.watch(connectionStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Telemetry Test - STEP 3'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // 🎯 STATUS DE CONEXÃO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: isConnected ? Colors.green.shade100 : Colors.red.shade100,
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.error,
                  color: isConnected ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Text(
                  isConnected ? '✅ CONECTADO' : '❌ DESCONECTADO',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // 📊 FREQUÊNCIA (Hz)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: hz >= 18
                        ? Colors.green
                        : hz >= 10
                            ? Colors.orange
                            : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.speed, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$hz Hz',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔘 BOTÕES DE CONTROLE
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final wsService = ref.read(webSocketServiceProvider);
                      wsService.connect('192.168.4.1');
                      ref.read(connectionStateProvider.notifier).state = true;
                    },
                    child: const Text('🔌 CONECTAR'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final wsService = ref.read(webSocketServiceProvider);
                      wsService.disconnect();
                      ref.read(connectionStateProvider.notifier).state = false;
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('❌ DESCONECTAR'),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // 📊 DADOS PROCESSADOS
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 TELEMETRIA PROCESSADA:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🛩️ Instrumentos principais
                  _buildSection(
                    '🛩️ INSTRUMENTOS',
                    [
                      _buildDataRow('Velocidade', '${telemetry.velocidade.toStringAsFixed(1)} km/h', Colors.blue),
                      _buildDataRow('Altitude', '${telemetry.altitude.toStringAsFixed(1)} m', Colors.green),
                      _buildDataRow('Heading', '${telemetry.heading.toStringAsFixed(1)}°', Colors.orange),
                      _buildDataRow('Pitch', '${telemetry.pitch.toStringAsFixed(1)}°', Colors.purple),
                      _buildDataRow('Roll', '${telemetry.roll.toStringAsFixed(1)}°', Colors.pink),
                      _buildDataRow('Variômetro', '${telemetry.vario.toStringAsFixed(2)} m/s', Colors.teal),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🌡️ Ambiente
                  _buildSection(
                    '🌡️ AMBIENTE',
                    [
                      _buildDataRow('Temperatura', '${telemetry.temperatura.toStringAsFixed(1)}°C', Colors.red),
                      _buildDataRow('Pressão', '${(telemetry.pressao / 100).toStringAsFixed(0)} hPa', Colors.indigo),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🗺️ GPS
                  _buildSection(
                    '🗺️ GPS',
                    [
                      _buildDataRow('Latitude', telemetry.lat.toStringAsFixed(6), Colors.cyan),
                      _buildDataRow('Longitude', telemetry.lng.toStringAsFixed(6), Colors.cyan),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🎮 Coordenador
                  _buildSection(
                    '🎮 COORDENADOR',
                    [
                      _buildDataRow('Gyro Z', '${telemetry.gyroZ.toStringAsFixed(2)}°/s', Colors.amber),
                      _buildDataRow('Accel X', '${telemetry.accelX.toStringAsFixed(2)} g', Colors.lime),
                      _buildDataRow('Accel Y', '${telemetry.accelY.toStringAsFixed(2)} g', Colors.lime),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ⏱️ Timestamp
                  Text(
                    '⏱️ Última atualização: ${telemetry.timestamp.toString().substring(11, 19)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color, // ✅ CORRIGIDO: usar cor direta
              ),
            ),
          ),
        ],
      ),
    );
  }
}