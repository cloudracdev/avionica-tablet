import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';
import 'telemetry_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  bool _conectando = false;

  void _conectar() async {
    setState(() => _conectando = true);
    
    try {
      // Tentar conectar ao ESP32
      final uri = Uri.parse('ws://192.168.4.1:81');
      final channel = WebSocketChannel.connect(uri);
      
      // Aguardar primeiro dado com timeout de 5 segundos
      await channel.stream.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Tempo esgotado');
        },
      );
      
      // Fechar canal de teste
      await channel.sink.close();
      
      // Conexão OK! Navegar para instrumentos
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TelemetryScreen()),
      );
      
    } catch (e) {
      // Erro de conexão
      if (!mounted) return;
      
      setState(() => _conectando = false);
      
      // Mostrar erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao conectar: ${_getTipoErro(e)}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Tentar novamente',
            textColor: Colors.white,
            onPressed: _conectar,
          ),
        ),
      );
    }
  }
  
  String _getTipoErro(dynamic erro) {
    if (erro is TimeoutException) {
      return 'Tempo esgotado. Verifique o WiFi.';
    } else if (erro.toString().contains('SocketException')) {
      return 'ESP32 não encontrado. Verifique o WiFi.';
    } else {
      return 'Falha na conexão';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade800,
              Colors.purple.shade700,
              Colors.deepPurple.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.02,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      iconSize: isLandscape ? size.height * 0.05 : 24,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Icon(
                      Icons.wifi,
                      color: Colors.white,
                      size: isLandscape ? size.height * 0.08 : 32,
                    ),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      'Conexão WiFi',
                      style: TextStyle(
                        fontSize: isLandscape ? size.height * 0.06 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Card central
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.08,
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isLandscape ? size.width * 0.5 : size.width * 0.9,
                      ),
                      padding: EdgeInsets.all(size.height * 0.025),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Título (sem ícone grande)
                          Text(
                            'Conecte-se ao WiFi da Aeronave',
                            style: TextStyle(
                              fontSize: isLandscape ? size.height * 0.045 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: size.height * 0.02),
                          
                          // Card com SSID
                          Container(
                            padding: EdgeInsets.all(size.height * 0.015),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.indigo.shade200,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.wifi_password,
                                      color: Colors.indigo.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Rede WiFi:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.01),
                                Text(
                                  '[CÓDIGO]-qfly-AP',
                                  style: TextStyle(
                                    fontSize: isLandscape ? size.height * 0.045 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade700,
                                    letterSpacing: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: size.height * 0.01),
                                Text(
                                  'Ex: PT-ABC-qfly-AP',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: size.height * 0.015),
                          
                          // Instruções
                          Container(
                            padding: EdgeInsets.all(size.height * 0.012),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade700,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Instruções:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '1. Conecte seu dispositivo ao WiFi da aeronave\n'
                                  '2. Aguarde a conexão estabelecer\n'
                                  '3. Clique em CONECTAR abaixo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue.shade900,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: size.height * 0.02),
                          
                          // Botão conectar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _conectando ? null : _conectar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 4,
                              ),
                              child: _conectando
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'CONECTANDO...',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.link, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'CONECTAR',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          
                          SizedBox(height: size.height * 0.015),
                          
                          // Info conexão
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green.shade700,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Conexão real • IP: 192.168.4.1:81 • Timeout: 5s',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}