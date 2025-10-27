import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../utils/websocket_service.dart';
import '../utils/calibration_service.dart';
import '../utils/smoothing_service.dart';
import '../widgets/calibration_dialog.dart';
import '../widgets/artificial_horizon.dart';

class SixPackScreen extends StatefulWidget {
  final WebSocketService wsService;

  const SixPackScreen({Key? key, required this.wsService}) : super(key: key);

  @override
  State<SixPackScreen> createState() => _SixPackScreenState();
}

class _SixPackScreenState extends State<SixPackScreen> {
  StreamSubscription? _subscription;
  final PageController _pageController = PageController();
  final CalibrationService _calib = CalibrationService();
  final SmoothingService _smooth = SmoothingService();
  
  double _rawV = 0, _rawA = 0, _rawH = 0, _rawP = 0, _rawR = 0;
  
  // Para cálculo do variômetro (CALCULADO LOCALMENTE)
  double _altitudePrevious = 0;
  int _timePrevious = 0;
  bool _firstVarioCalc = true;
  double _varioSmooth = 0;
  final double _varioAlpha = 0.2; // Filtro EMA
  
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

    // ForÃ§ar orientaÃ§Ã£o horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _subscription = widget.wsService.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          // 1. Converter dados recebidos para formato do smoothing
          Map<String, double> rawData = {
            'velocidade': data['velocidade']?.toDouble() ?? 0.0,
            'altitude': data['altitude']?.toDouble() ?? 0.0,
            'heading': data['heading']?.toDouble() ?? 0.0,
            'pitch': data['pitch']?.toDouble() ?? 0.0,
            'roll': data['roll']?.toDouble() ?? 0.0,
            'temperatura': data['temperatura']?.toDouble() ?? 0.0,
            'pressao': data['pressao']?.toDouble() ?? 0.0,
            'lat': data['lat']?.toDouble() ?? 0.0,
            'lng': data['lng']?.toDouble() ?? 0.0,
          };
          
          // 2. Aplicar suavizaÃ§Ã£o (EMA + Dead Zone)
          Map<String, double> smoothData = _smooth.smoothData(rawData);
          
          // 3. Armazenar valores RAW suavizados (para calibraÃ§Ã£o)
          _rawV = smoothData['velocidade']!;
          _rawA = smoothData['altitude']!;
          _rawH = smoothData['heading']!;
          _rawP = smoothData['pitch']!;
          _rawR = smoothData['roll']!;
          
          // 4. Aplicar calibraÃ§Ã£o nos valores suavizados
          velocidade = _rawV;
          altitude = _calib.applyCalibratedAltitude(_rawA);
          heading = _calib.applyCalibratedHeading(_rawH);
          pitch = _calib.applyCalibratedPitch(_rawP);
          roll = _calib.applyCalibratedRoll(_rawR);
          
          // 5. CALCULAR VARIÔMETRO (m/s) baseado na altitude calibrada
          int timeNow = DateTime.now().millisecondsSinceEpoch;
          
          if (_firstVarioCalc) {
            _altitudePrevious = altitude;
            _timePrevious = timeNow;
            _varioSmooth = 0;
            _firstVarioCalc = false;
            vario = 0;
          } else {
            double deltaAltitude = altitude - _altitudePrevious;
            int deltaTime = timeNow - _timePrevious;
            
            if (deltaTime > 0) {
              double varioInstant = (deltaAltitude * 1000.0) / deltaTime; // m/s
              _varioSmooth = _varioAlpha * varioInstant + (1 - _varioAlpha) * _varioSmooth;
              vario = _varioSmooth;
              
              _altitudePrevious = altitude;
              _timePrevious = timeNow;
            }
          }
          
          // 6. Dados extras (jÃ¡ suavizados)
          temperatura = smoothData['temperatura']!;
          pressao = smoothData['pressao']!;
          lat = smoothData['lat']!;
          lng = smoothData['lng']!;
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

  void _openCalibrationDialog() {
    if (_rawH == 0 && _rawP == 0 && _rawA == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('âš ï¸ Aguarde dados chegarem!'), duration: Duration(seconds: 2)),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => CalibrationDialog(
        calibrationService: _calib,
        currentHeading: _rawH,
        currentPitch: _rawP,
        currentRoll: _rawR,
        currentAltitude: _rawA,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView com 2 pÃ¡ginas
          PageView(
            controller: _pageController,
            children: [
              _buildSixPackPage(),
              _buildTelemetryPage(),
            ],
          ),

          // BotÃµes
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _openCalibrationDialog,
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('Calibrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
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
              ],
            ),
          ),

          // Indicador de pÃ¡gina
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
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

  // PÃGINA 1: SIX-PACK
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

  // PÃGINA 2: TELEMETRIA EXTRA
  Widget _buildTelemetryPage() {
    return Column(
      children: [
        // Mapa - TODA a tela horizontal
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.grey.shade900,
            child: Stack(
              children: [
                // Border apenas
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                  ),
                ),
                // ConteÃºdo centralizado
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map, color: Colors.blue, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'ðŸ“ MAPA',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Lat: ${lat.toStringAsFixed(9)}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        'Lng: ${lng.toStringAsFixed(9)}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Temperatura e PressÃ£o - altura mÃ­nima 70px
        SizedBox(
          height: 70,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(1),
                  color: Colors.grey.shade900,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'TEMP',
                        style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${temperatura.toStringAsFixed(1)}°C',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(1),
                  color: Colors.grey.shade900,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'PRESSÃƒO',
                        style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(pressao / 100).toStringAsFixed(0)} hPa',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 1ï¸âƒ£ VELOCÃMETRO
  Widget _buildVelocimetro() {
    return _buildInstrumento(
      titulo: 'VELOCIDADE',
      valor: '${velocidade.toStringAsFixed(3)}',
      unidade: 'km/h',
      cor: Colors.green,
      icone: Icons.speed,
    );
  }

  // 2ï¸âƒ£ HORIZONTE ARTIFICIAL
  Widget _buildHorizonte() {
    return ArtificialHorizon(
      pitch: pitch,
      roll: roll,
    );
  }

  // 3ï¸âƒ£ ALTÃMETRO
  Widget _buildAltimetro() {
    return _buildInstrumento(
      titulo: 'ALTITUDE',
      valor: '${altitude.toStringAsFixed(3)}',
      unidade: 'm',
      cor: Colors.orange,
      icone: Icons.height,
    );
  }

  // 4ï¸âƒ£ BÚSSOLA
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

  // 5ï¸âƒ£ COORDENADOR DE CURVA
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

  // 6ï¸âƒ£ VARIÃ”METRO
  Widget _buildVariometro() {
    return _buildInstrumento(
      titulo: 'VARIÔMETRO',
      valor: vario > 0 ? '+${vario.toStringAsFixed(3)}' : vario.toStringAsFixed(3),
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
          // TÃ­tulo
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

          // Ãcone
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

  // Widget compacto para pÃ¡gina de telemetria (menor)
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
          // TÃ­tulo
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

          // Ãcone menor
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