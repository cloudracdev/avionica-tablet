import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/websocket_provider.dart';
import '../providers/telemetry_provider.dart';
import '../providers/mock_mode_provider.dart';
import '../models/telemetry_data.dart';

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
  String _connectionStatus = '';

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
    setState(() {
      _isConnecting = true;
      _connectionStatus = '';
    });

    try {
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
        setState(() {
          _isConnecting = false;
          _connectionStatus = '';
        });
      }
    }
  }

  Future<void> _connectMock() async {
    setState(() => _connectionStatus = '🎭 Iniciando modo mock...');
    
    final repo = ref.read(telemetryRepositoryProvider);
    await repo.connect('mock');
    
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      context.go('/calibration');
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

    setState(() => _connectionStatus = '🔌 Conectando ao ESP32...');
    
    final wsService = ref.read(webSocketServiceProvider);
    wsService.connect(ip);
    
    ref.read(connectionStateProvider.notifier).state = true;
    ref.read(ipAddressProvider.notifier).state = ip;

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _connectionStatus = '📡 Aguardando dados de telemetria...');
    
    final dataReceived = await _waitForTelemetryData();
    
    if (!dataReceived) {
      wsService.disconnect();
      ref.read(connectionStateProvider.notifier).state = false;
      
      if (mounted) {
        _showConnectionError();
      }
      return;
    }

    if (mounted) {
      final hz = ref.read(telemetryHzProvider);
      setState(() => _connectionStatus = '✅ Conectado! $hz Hz');
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      context.go('/calibration');
    }
  }

  Future<bool> _waitForTelemetryData() async {
    final completer = Completer<bool>();
    StreamSubscription<TelemetryData>? subscription;
    Timer? timeoutTimer;
    
    subscription = ref.read(telemetryProvider.notifier).stream.listen((data) {
      if (data.timestamp.isAfter(DateTime.now().subtract(const Duration(seconds: 2)))) {
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    });
    
    timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });
    
    final result = await completer.future;
    
    await subscription.cancel();
    timeoutTimer.cancel();
    
    return result;
  }

  void _showConnectionError() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('❌ Falha na Conexão'),
        content: const Text(
          'Não foi possível receber dados do ESP32.\n\n'
          '💡 Verifique:\n'
          '• ESP32 está ligado\n'
          '• Conectado ao WiFi do ESP32\n'
          '• IP correto (192.168.4.1)\n'
          '• Firmware atualizado no ESP32'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                      
                      if (_connectionStatus.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          _connectionStatus,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      
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