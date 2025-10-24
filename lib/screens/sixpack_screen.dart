import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../utils/websocket_service.dart';

class SixPackScreen extends StatefulWidget {
  final WebSocketService wsService;

  const SixPackScreen({Key? key, required this.wsService}) : super(key: key);

  @override
  State<SixPackScreen> createState() => _SixPackScreenState();
}

class _SixPackScreenState extends State<SixPackScreen> {
  // Subscription do WebSocket
  StreamSubscription? _subscription;
  
  // Dados dos instrumentos
  double velocidade = 0;
  double altitude = 0;
  double heading = 0;
  double pitch = 0;
  double roll = 0;
  double vario = 0;

  @override
  void initState() {
    super.initState();

    // Forçar orientação horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Escutar dados do WebSocket com subscription cancelável
    _subscription = widget.wsService.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          velocidade = data['velocidade']?.toDouble() ?? 0.0;
          altitude = data['altitude']?.toDouble() ?? 0.0;
          heading = data['heading']?.toDouble() ?? 0.0;
          pitch = data['pitch']?.toDouble() ?? 0.0;
          roll = data['roll']?.toDouble() ?? 0.0;
          vario = data['vario']?.toDouble() ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    // Cancelar subscription
    _subscription?.cancel();
    
    // Restaurar orientações ao sair
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Grid 3x2
          Column(
            children: [
              // Linha superior
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: RepaintBoundary(child: _buildVelocimetro())),
                    Expanded(child: RepaintBoundary(child: _buildHorizonte())),
                    Expanded(child: RepaintBoundary(child: _buildAltimetro())),
                  ],
                ),
              ),
              // Linha inferior
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: RepaintBoundary(child: _buildDirecao())),
                    Expanded(child: RepaintBoundary(child: _buildCoordenador())),
                    Expanded(child: RepaintBoundary(child: _buildVariometro())),
                  ],
                ),
              ),
            ],
          ),

          // Botão desconectar (canto superior direito)
          Positioned(
            top: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.wsService.disconnect();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Desconectar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1️⃣ VELOCÍMETRO
  Widget _buildVelocimetro() {
    return _buildInstrumento(
      titulo: 'VELOCIDADE',
      valor: '${velocidade.toInt()}',
      unidade: 'km/h',
      cor: Colors.green,
      icone: Icons.speed,
    );
  }

  // 2️⃣ HORIZONTE ARTIFICIAL
  Widget _buildHorizonte() {
    return _buildInstrumento(
      titulo: 'HORIZONTE',
      valor: 'P:${pitch.toInt()}° R:${roll.toInt()}°',
      unidade: '',
      cor: Colors.blue,
      icone: Icons.airplanemode_active,
    );
  }

  // 3️⃣ ALTÍMETRO
  Widget _buildAltimetro() {
    return _buildInstrumento(
      titulo: 'ALTITUDE',
      valor: '${altitude.toInt()}',
      unidade: 'm',
      cor: Colors.orange,
      icone: Icons.height,
    );
  }

  // 4️⃣ INDICADOR DIREÇÃO
  Widget _buildDirecao() {
    return _buildInstrumento(
      titulo: 'DIREÇÃO',
      valor: '${heading.toInt()}',
      unidade: '°',
      cor: Colors.purple,
      icone: Icons.explore,
    );
  }

  // 5️⃣ COORDENADOR CURVA
  Widget _buildCoordenador() {
    return _buildInstrumento(
      titulo: 'COORDENADOR',
      valor: 'Roll: ${roll.toInt()}°',
      unidade: '',
      cor: Colors.teal,
      icone: Icons.sync,
    );
  }

  // 6️⃣ VARIÔMETRO
  Widget _buildVariometro() {
    return _buildInstrumento(
      titulo: 'VARIÔMETRO',
      valor: vario > 0 ? '+${vario.toStringAsFixed(1)}' : vario.toStringAsFixed(1),
      unidade: 'm/s',
      cor: vario > 0 ? Colors.green : Colors.red,
      icone: vario > 0 ? Icons.arrow_upward : Icons.arrow_downward,
    );
  }

  // Widget base para instrumentos
  Widget _buildInstrumento({
    required String titulo,
    required String valor,
    required String unidade,
    required Color cor,
    required IconData icone,
  }) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: cor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Título
          Text(
            titulo,
            style: TextStyle(
              color: cor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Ícone
          Icon(icone, color: cor, size: 32),
          const SizedBox(height: 12),

          // Valor principal
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Unidade
          Text(
            unidade,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
