import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/sixpack_controller.dart';
import '../providers/telemetry_provider.dart';
import '../widgets/artificial_horizon.dart';
import '../widgets/velocimetro_widget.dart';
import '../widgets/altimetro_widget.dart';
import '../widgets/bussola_widget.dart';
import '../widgets/coordenador_widget.dart';
import '../widgets/variometro_widget.dart';
import '../widgets/connection_status_widget.dart';

/// 🎯 SixPack Screen - Tela principal de instrumentos
/// 
/// Apenas UI - lógica delegada ao SixPackController
/// DI via Riverpod: Controller acessa dependencies via ref
class SixPackScreen extends ConsumerStatefulWidget {
  const SixPackScreen({super.key});

  @override
  ConsumerState<SixPackScreen> createState() => _SixPackScreenState();
}

class _SixPackScreenState extends ConsumerState<SixPackScreen> {
  final PageController _pageController = PageController();
  late final SixPackController _controller;

  @override
  void initState() {
    super.initState();
    
    // ✅ DI: Controller criado com ref (acessa providers)
    _controller = SixPackController(ref, context);

    // Inicializar após primeiro build
    Future.microtask(() {
      _controller.initializeWatchdog();
      _controller.setupOrientations();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 📡 Observar telemetria processada
    final telemetry = ref.watch(telemetryProvider);

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
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔄 Botão Reconectar
          FloatingActionButton(
            heroTag: 'reconnect',
            onPressed: _controller.reconnect,
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
  Widget _buildSixPackPage(telemetry) {
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
  Widget _buildTelemetryPage(telemetry) {
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