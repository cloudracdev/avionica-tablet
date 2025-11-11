import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/websocket_provider.dart';

/// 🧪 TELA DE TESTE - STEP 2
/// Valida se o WebSocket Provider está funcionando
class WebSocketTestScreen extends ConsumerWidget {
  const WebSocketTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 📡 Observar estado de conexão
    final isConnected = ref.watch(connectionStateProvider);
    
    // 📡 Observar stream de telemetria
    final telemetryAsync = ref.watch(telemetryStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 WebSocket Test - STEP 2'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🎯 STATUS DE CONEXÃO
            Card(
              color: isConnected ? Colors.green.shade100 : Colors.red.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 🔘 BOTÕES DE TESTE
            ElevatedButton(
              onPressed: () {
                // Conectar ao ESP32 (IP de teste)
                final wsService = ref.read(webSocketServiceProvider);
                wsService.connect('192.168.4.1'); // IP padrão ESP32 AP
                ref.read(connectionStateProvider.notifier).state = true;
              },
              child: const Text('🔌 CONECTAR (192.168.4.1)'),
            ),
            
            ElevatedButton(
              onPressed: () {
                // Desconectar
                final wsService = ref.read(webSocketServiceProvider);
                wsService.disconnect();
                ref.read(connectionStateProvider.notifier).state = false;
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('❌ DESCONECTAR'),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // 📊 DADOS RECEBIDOS
            const Text(
              '📊 ÚLTIMOS DADOS RECEBIDOS:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: Card(
                color: Colors.grey.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: telemetryAsync.when(
                    // ✅ Dados recebidos
                    data: (data) {
                      return SingleChildScrollView(
                        child: Text(
                          data.entries
                              .map((e) => '${e.key}: ${e.value}')
                              .join('\n'),
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'Courier',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                    // ⏳ Carregando
                    loading: () => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Aguardando dados...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // ❌ Erro
                    error: (error, stack) => Center(
                      child: Text(
                        '❌ Erro: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}