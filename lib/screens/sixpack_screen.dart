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
  
  // PageView controller
  final PageController _pageController = PageController();
  
  // Dados dos instrumentos
  double velocidade = 0;
  double altitude = 0;
  double heading = 0;
  double pitch = 0;
  double roll = 0;
  double vario = 0;
  double temperatura = 0;
  double pressao = 0;
  double lat = 0;
  double lng = 0;

  @override
  void initState() {
    super.initState();

    // Forçar orientação horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Escutar dados do WebSocket
    _subscription = widget.wsService.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          velocidade = data['velocidade']?.toDouble() ?? 0.0;
          altitude = data['altitude']?.toDouble() ?? 0.0;
          heading = data['heading']?.toDouble() ?? 0.0;
          pitch = data['pitch']?.toDouble() ?? 0.0;
          roll = data['roll']?.toDouble() ?? 0.0;
          vario = data['vario']?.toDouble() ?? 0.0;
          temperatura = data['temperatura']?.toDouble() ?? 0.0;
          pressao = data['pressao']?.toDouble() ?? 0.0;
          lat = data['lat']?.toDouble() ?? 0.0;
          lng = data['lng']?.toDouble() ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pageController.dispose();
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  // Converter heading em direção cardinal
  String _getCardinalDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees >= 22.5 && degrees < 67.5) return 'NE';
    if (degrees >= 67.5 && degrees < 112.5) return 'L';
    if (degrees >= 112.5 && degrees < 157.5) return 'SE';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'SO';
    if (degrees >= 247.5 && degrees < 292.5) return 'O';
    return 'NO';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView com 2 páginas
          PageView(
            controller: _pageController,
            children: [
              _buildSixPackPage(),
              _buildTelemetryPage(),
            ],
          ),

          // Botão desconectar
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

          // Indicador de página
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PÁGINA 1: SIX-PACK
  Widget _buildSixPackPage() {
    return Column(
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
              Expanded(child: RepaintBoundary(child: _buildBussola())),
              Expanded(child: RepaintBoundary(child: _buildCoordenador())),
              Expanded(child: RepaintBoundary(child: _buildVariometro())),
            ],
          ),
        ),
      ],
    );
  }

  // PÁGINA 2: TELEMETRIA EXTRA
  Widget _buildTelemetryPage() {
    return Column(
      children: [
        // Mapa (futuro) - ocupa toda largura
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4), // Apenas margem vertical
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map, color: Colors.blue, size: 64),
                const SizedBox(height: 16),
                const Text(
                  '📍 MAPA',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Lat: ${lat.toStringAsFixed(6)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Lng: ${lng.toStringAsFixed(6)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Temperatura e Pressão - mais compactos
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24), // Espaço para indicador
            child: Row(
              children: [
                Expanded(
                  child: RepaintBoundary(
                    child: _buildInstrumentoCompacto(
                      titulo: 'TEMPERATURA',
                      valor: '${temperatura.toStringAsFixed(1)}',
                      unidade: '°C',
                      cor: Colors.red,
                      icone: Icons.thermostat,
                    ),
                  ),
                ),
                Expanded(
                  child: RepaintBoundary(
                    child: _buildInstrumentoCompacto(
                      titulo: 'PRESSÃO',
                      valor: '${(pressao / 100).toStringAsFixed(0)}',
                      unidade: 'hPa',
                      cor: Colors.purple,
                      icone: Icons.compress,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
      titulo: 'HORIZONTE ARTIFICIAL',
      valor: 'P:${pitch.toInt()}° R:${roll.toInt()}°',
      unidade: '',
      cor: Colors.blue,
      icone: Icons.airplanemode_active,
      fontSize: 14, // Fonte menor para caber o título
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

  // 4️⃣ BÚSSOLA
  Widget _buildBussola() {
    String cardinal = _getCardinalDirection(heading);
    return _buildInstrumento(
      titulo: 'BÚSSOLA',
      valor: '${heading.toInt()}° ($cardinal)',
      unidade: '',
      cor: Colors.purple,
      icone: Icons.explore,
      fontSize: 36, // Valor um pouco menor para caber tudo
    );
  }

  // 5️⃣ COORDENADOR DE CURVA
  Widget _buildCoordenador() {
    return _buildInstrumento(
      titulo: 'COORDENADOR DE CURVA',
      valor: 'Roll: ${roll.toInt()}°',
      unidade: '',
      cor: Colors.teal,
      icone: Icons.sync,
      fontSize: 14, // Fonte menor para caber o título
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
    double fontSize = 16,
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
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
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
            textAlign: TextAlign.center,
          ),

          // Unidade
          if (unidade.isNotEmpty)
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

  // Widget compacto para página de telemetria (menor)
  Widget _buildInstrumentoCompacto({
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Ícone menor
          Icon(icone, color: cor, size: 24),
          const SizedBox(height: 8),

          // Valor menor
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          // Unidade
          if (unidade.isNotEmpty)
            Text(
              unidade,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
