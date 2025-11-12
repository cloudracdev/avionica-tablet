import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/websocket_provider.dart';
import 'sixpack_screen.dart';

/// 🔌 Connection Screen - Tela de conexão com ESP32
class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final TextEditingController _ipController = TextEditingController(
    text: '192.168.4.1', // IP padrão ESP32 AP Mode
  );
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    
    // ✅ PERMITIR TODAS AS ORIENTAÇÕES
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _connect() async {
    final ip = _ipController.text.trim();
    
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Digite um endereço IP válido')),
      );
      return;
    }

    setState(() => _isConnecting = true);

    try {
      // Conectar ao WebSocket
      final wsService = ref.read(webSocketServiceProvider);
      wsService.connect(ip);
      
      // Atualizar estado de conexão
      ref.read(connectionStateProvider.notifier).state = true;
      ref.read(ipAddressProvider.notifier).state = ip;

      // Aguardar 1 segundo para estabilizar conexão
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Navegar para SixPackScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SixPackScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro ao conectar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo/Título
              const Icon(
                Icons.flight,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              
              const Text(
                'QFLY Aviônica',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              const Text(
                'Sistema de Telemetria de Voo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Campo IP
              TextField(
                controller: _ipController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Endereço IP do ESP32',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: '192.168.4.1',
                  hintStyle: const TextStyle(color: Colors.white30),
                  prefixIcon: const Icon(Icons.wifi, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              
              const SizedBox(height: 24),
              
              // Botão Conectar
              ElevatedButton(
                onPressed: _isConnecting ? null : _connect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isConnecting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '🔌 CONECTAR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Dica
              const Text(
                '💡 Dica: Conecte-se à rede WiFi do ESP32\n(SSID: ESP32-AP)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}