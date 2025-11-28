import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/sixpack_controller.dart';
import '../models/telemetry_data.dart';
import '../providers/telemetry_provider.dart';
import '../providers/telemetry_settings_provider.dart';
import '../services/interpolation/interpolation_service.dart';
import '../widgets/artificial_horizon.dart';
import '../widgets/velocimetro_widget.dart';
import '../widgets/altimetro_widget.dart';
import '../widgets/bussola_widget.dart';
import '../widgets/coordenador_widget.dart';
import '../widgets/variometro_widget.dart';
import '../widgets/connection_status_widget.dart';

/// 🎯 SixPack Screen - Tela principal de instrumentos
/// 
/// Usa interpolação 60fps para animações suaves dos instrumentos.
/// Dados brutos chegam a 3-4Hz do ESP32, interpolação preenche os frames.
class SixPackScreen extends ConsumerStatefulWidget {
  const SixPackScreen({super.key});

  @override
  ConsumerState<SixPackScreen> createState() => _SixPackScreenState();
}

class _SixPackScreenState extends ConsumerState<SixPackScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final SixPackController _controller;
  
  // 🎯 Interpolação 60fps
  late final InterpolationService _interpolation;
  Ticker? _ticker;
  TelemetryData _displayData = TelemetryData.initial();
  TelemetryData? _lastRawData;

  @override
  void initState() {
    super.initState();
    
    _controller = SixPackController(ref, context);
    _interpolation = InterpolationService();

    Future.microtask(() {
      _controller.initializeWatchdog();
      _controller.setupOrientations();
      _startInterpolation();
    });
  }

  void _startInterpolation() {
    final settings = ref.read(telemetrySettingsProvider);
    if (settings.interpolationEnabled) {
      _ticker = createTicker(_onTick);
      _ticker!.start();
    }
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    final rawData = ref.read(telemetryProvider);
    
    // Só atualiza target quando raw data muda (3-4Hz)
    if (rawData != _lastRawData) {
      _interpolation.setTarget(rawData);
      _lastRawData = rawData;
    }
    
    // Pega valor interpolado (60fps)
    setState(() {
      _displayData = _interpolation.getInterpolated();
    });
  }

  @override
  void dispose() {
    _ticker?.stop();
    _ticker?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 📡 Verifica se interpolação está ativa
    final settings = ref.watch(telemetrySettingsProvider);
    
    // Se interpolação desativada, usa dados brutos diretamente
    final telemetry = settings.interpolationEnabled 
        ? _displayData 
        : ref.watch(telemetryProvider);

    // 🔴 Verifica se dados estão stale (sem atualização > 1s)
    final isStale = settings.interpolationEnabled && _interpolation.isStale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Conteúdo principal (instrumentos)
            PageView(
              controller: _pageController,
              children: [
                _buildSixPackPage(telemetry),
                _buildTelemetryPage(telemetry),
              ],
            ),
            
            // 📡 INDICADOR DE STATUS (overlay no topo)
            const Positioned(
              top: 0,
              left: 0,
              child: ConnectionStatusWidget(),
            ),

            // ⚠️ INDICADOR STALE (sem dados)
            if (isStale)
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '⚠️ SEM SINAL - Dados congelados',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔄 Botão Reconectar
          FloatingActionButton(
            heroTag: 'reconnect',
            onPressed: () {
              _interpolation.reset();
              _controller.reconnect();
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 8),
          
          // ❌ Botão Desconectar
          FloatingActionButton(
            heroTag: 'disconnect',
            onPressed: _controller.disconnect,
            backgroundColor: Colors.red,
            child: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  // ========================================
  // PÁGINA 1: SIX-PACK
  // ========================================
  Widget _buildSixPackPage(TelemetryData telemetry) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;

        if (isLandscape) {
          // LANDSCAPE: 2 linhas x 3 colunas
          return Column(
            children: [
              // Linha superior
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: RepaintBoundary(
                        child: VelocimetroWidget(velocidade: telemetry.velocidade),
                      ),
                    ),
                    Expanded(
                      child: RepaintBoundary(
                        child: ArtificialHorizon(
                          pitch: telemetry.pitch,
                          roll: telemetry.roll,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RepaintBoundary(
                        child: AltimetroWidget(
                          altitude: telemetry.altitude,
                          pressao: telemetry.pressao,
                        ),
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
                          roll: telemetry.roll,
                          turnRate: telemetry.gyroZ,
                          accelX: telemetry.accelX,
                          accelY: telemetry.accelY,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RepaintBoundary(
                        child: BussolaWidget(heading: telemetry.heading),
                      ),
                    ),
                    Expanded(
                      child: RepaintBoundary(
                        child: VariometroWidget(vario: telemetry.vario),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          // PORTRAIT: 3 linhas x 2 colunas
          return Column(
            children: [
              // Linha 1: Velocímetro | Horizonte
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: RepaintBoundary(
                        child: VelocimetroWidget(velocidade: telemetry.velocidade),
                      ),
                    ),
                    Expanded(
                      child: RepaintBoundary(
                        child: ArtificialHorizon(
                          pitch: telemetry.pitch,
                          roll: telemetry.roll,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Linha 2: Altímetro | Bússola
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: RepaintBoundary(
                        child: AltimetroWidget(
                          altitude: telemetry.altitude,
                          pressao: telemetry.pressao,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RepaintBoundary(
                        child: BussolaWidget(heading: telemetry.heading),
                      ),
                    ),
                  ],
                ),
              ),
              // Linha 3: Coordenador | Variômetro
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: RepaintBoundary(
                        child: CoordenadorWidget(
                          roll: telemetry.roll,
                          turnRate: telemetry.gyroZ,
                          accelX: telemetry.accelX,
                          accelY: telemetry.accelY,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RepaintBoundary(
                        child: VariometroWidget(vario: telemetry.vario),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  // ========================================
  // PÁGINA 2: TELEMETRIA EXTRA
  // ========================================
  Widget _buildTelemetryPage(TelemetryData telemetry) {
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
                        'Lat: ${telemetry.lat.toStringAsFixed(9)}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        'Lng: ${telemetry.lng.toStringAsFixed(9)}',
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
                        '${telemetry.temperatura.toStringAsFixed(1)}°C',
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
                        '${(telemetry.pressao / 100).toStringAsFixed(0)} hPa',
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
