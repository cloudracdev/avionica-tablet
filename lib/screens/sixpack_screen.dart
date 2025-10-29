import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../utils/websocket_service.dart';
import '../utils/calibration_service.dart';
import '../utils/smoothing_service.dart';
import '../widgets/calibration_dialog.dart';
import '../widgets/artificial_horizon.dart';
import '../widgets/velocimetro_widget.dart';
import '../widgets/altimetro_widget.dart';
import '../widgets/bussola_widget.dart';
import '../widgets/coordenador_widget.dart';
import '../widgets/variometro_widget.dart';

class SixPackScreen extends StatefulWidget {
  final WebSocketService wsService;
  final CalibrationService? calibrationService;

  const SixPackScreen({
    Key? key,
    required this.wsService,
    this.calibrationService,
  }) : super(key: key);

  @override
  State<SixPackScreen> createState() => _SixPackScreenState();
}

class _SixPackScreenState extends State<SixPackScreen> {
  StreamSubscription? _subscription;
  final PageController _pageController = PageController();
  late final CalibrationService _calib;
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
  
  // Dados para coordenador de curva
  double gyroZ = 0;
  double accelX = 0;
  double accelY = 0;
  
  // Offsets de calibração (ajustar quando parado)
  double _gyroZOffset = 0;
  double _accelXOffset = 0;
  double _accelYOffset = 0;

  @override
  void initState() {
    super.initState();

    // Usar calibração recebida ou criar nova
    _calib = widget.calibrationService ?? CalibrationService();

    // Forçar orientação horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _subscription = widget.wsService.dataStream.listen((data) {
      if (mounted) {
        // DEBUG: Mostrar dados formatados no console
        print('\n' + '='*60);
        print('📥 DADOS DO ESP32:');
        print('='*60);
        print('🎯 INSTRUMENTOS PRINCIPAIS:');
        print('   Velocidade: ${data['velocidade']} km/h');
        print('   Altitude: ${data['altitude']} m (${data['altitude_ft']} ft)');
        print('   Heading: ${data['heading']}°');
        print('   Pitch: ${data['pitch']}°');
        print('   Roll: ${data['roll']}°');
        print('   Variômetro: ${data['variometro']} m/s (${data['variometro_ft']} ft/min)');
        print('');
        print('🌡️  AMBIENTE:');
        print('   Temperatura: ${data['temperatura']}°C');
        print('   Pressão: ${data['pressao']} Pa (${(data['pressao']/100).toStringAsFixed(0)} hPa)');
        print('');
        print('🛰️  GPS:');
        print('   Lat: ${data['lat']}');
        print('   Lng: ${data['lng']}');
        print('   Satélites: ${data['satelites']}');
        print('   HDOP: ${data['hdop']}');
        print('');
        print('🔄 GIROSCÓPIOS:');
        print('   L3G4200D → X:${data['gyro_x']} Y:${data['gyro_y']} Z:${data['gyro_z']}');
        print('   LSM6DS3  → X:${data['lsm_gx']}°/s Y:${data['lsm_gy']}°/s Z:${data['lsm_gz']}°/s');
        print('');
        print('📐 ACELERÔMETROS:');
        print('   ADXL345  → X:${data['acel_x']} Y:${data['acel_y']} Z:${data['acel_z']}');
        print('   LSM6DS3  → X:${data['lsm_ax']}g Y:${data['lsm_ay']}g Z:${data['lsm_az']}g');
        print('');
        print('🎛️  COORDENADOR DE CURVA (dados usados):');
        print('   Roll (agulha): ${data['roll']}°');
        print('   Accel X (bolinha): ${data['lsm_ax']}g');
        print('   Accel Y (bolinha): ${data['lsm_ay']}g');
        print('   Taxa Giro (ref): ${data['lsm_gz']}°/s');
        print('='*60 + '\n');
        
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
          
          // 2. Aplicar suavização (EMA + Dead Zone)
          Map<String, double> smoothData = _smooth.smoothData(rawData);
          
          // 3. Armazenar valores RAW suavizados (para calibração)
          _rawV = smoothData['velocidade']!;
          _rawA = smoothData['altitude']!;
          _rawH = smoothData['heading']!;
          _rawP = smoothData['pitch']!;
          _rawR = smoothData['roll']!;
          
          // 4. Aplicar calibração nos valores suavizados
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
          
          // 6. Dados extras (já suavizados)
          temperatura = smoothData['temperatura']!;
          pressao = smoothData['pressao']!;
          lat = smoothData['lat']!;
          lng = smoothData['lng']!;
          
          // 7. Dados do coordenador de curva
          double rawGyroZ = data['lsm_gz']?.toDouble() ?? 0.0;
          double rawAccelX = data['lsm_ax']?.toDouble() ?? 0.0;
          double rawAccelY = data['lsm_ay']?.toDouble() ?? 0.0;
          
          // Aplicar offsets de calibração
          gyroZ = rawGyroZ - _gyroZOffset;
          accelX = rawAccelX - _accelXOffset;
          accelY = rawAccelY - _accelYOffset;
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

  void _openCalibrationDialog() {
    if (_rawH == 0 && _rawP == 0 && _rawA == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Aguarde dados chegarem!'), 
          duration: Duration(seconds: 2)
        ),
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

  void _calibrarCoordenador() {
    setState(() {
      _gyroZOffset = gyroZ + _gyroZOffset;
      _accelXOffset = accelX + _accelXOffset;
      _accelYOffset = accelY + _accelYOffset;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Coordenador calibrado! (Agulha e bolinha zerados)'),
        duration: Duration(seconds: 2),
      ),
    );
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

          // Botões
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
                  onPressed: _calibrarCoordenador,
                  icon: const Icon(Icons.center_focus_strong, size: 16),
                  label: const Text('Zerar Coord'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
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

          // Indicador de página
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

  // ========================================
  // PÁGINA 1: SIX-PACK
  // ========================================
  Widget _buildSixPackPage() {
    return Column(
      children: [
        // Linha superior
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: RepaintBoundary(
                  child: VelocimetroWidget(velocidade: velocidade),
                ),
              ),
              Expanded(
                child: RepaintBoundary(
                  child: ArtificialHorizon(pitch: pitch, roll: roll),
                ),
              ),
              Expanded(
                child: RepaintBoundary(
                  child: AltimetroWidget(altitude: altitude),
                ),
              ),
            ],
          ),
        ),
        // Linha inferior
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: RepaintBoundary(
                  child: CoordenadorWidget(
                    roll: roll,
                    turnRate: gyroZ,
                    accelX: accelX,
                    accelY: accelY,
                  ),
                ),
              ),
              Expanded(
                child: RepaintBoundary(
                  child: BussolaWidget(heading: heading),
                ),
              ),
              Expanded(
                child: RepaintBoundary(
                  child: VariometroWidget(vario: vario),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========================================
  // PÁGINA 2: TELEMETRIA EXTRA
  // ========================================
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
                // Conteúdo centralizado
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map, color: Colors.blue, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        '🗺️ MAPA',
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
        // Temperatura e Pressão - altura mínima 70px
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
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${temperatura.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                        'PRESSÃO',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(pressao / 100).toStringAsFixed(0)} hPa',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
}