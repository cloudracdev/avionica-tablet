import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/websocket_provider.dart';
import '../providers/telemetry_provider.dart';
import '../providers/mock_mode_provider.dart';
import 'calibration_screen.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final TextEditingController _ipController = TextEditingController(
    text: '192.168.4.1',
  );
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
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
    setState(() => _isConnecting = true);

    try {
      // RESETAR calibração
      ref.read(calibrationServiceProvider).resetAll();
      
      final isMockMode = ref.read(mockModeProvider);
      
      if (isMockMode) {
        await _connectMock();
      } else {
        await _connectReal();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _connectMock() async {
    // Pegar repository mock e conectar
    final repo = ref.read(telemetryRepositoryProvider);
    await repo.connect('mock');
    
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CalibrationScreen(),
        ),
      );
    }
  }

  Future<void> _connectReal() async {
    final ip = _ipController.text.trim();
    
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Digite um IP válido')),
      );
      return;
    }

    final wsService = ref.read(webSocketServiceProvider);
    wsService.connect(ip);
    
    ref.read(connectionStateProvider.notifier).state = true;
    ref.read(ipAddressProvider.notifier).state = ip;

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CalibrationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMockMode = ref.watch(mockModeProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.flight, size: 80, color: Colors.blue),
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
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // TOGGLE MOCK MODE
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isMockMode 
                            ? Colors.orange.shade900.withOpacity(0.3) 
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMockMode ? Colors.orange : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMockMode ? '🎭 Modo Mock' : '🌐 Modo Real',
                                  style: TextStyle(
                                    color: isMockMode ? Colors.orange : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isMockMode ? 'Dados simulados' : 'Conectar ESP32',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: isMockMode,
                              onChanged: (value) {
                                // ATUALIZAR PROVIDER GLOBAL
                                ref.read(mockModeProvider.notifier).state = value;
                              },
                              activeColor: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      if (!isMockMode) ...[
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      ElevatedButton(
                        onPressed: _isConnecting ? null : _connect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMockMode ? Colors.orange : Colors.blue,
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
                          : Text(
                              isMockMode ? '🎭 INICIAR MOCK' : '🔌 CONECTAR',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      if (!isMockMode)
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
          },
        ),
      ),
    );
  }
}