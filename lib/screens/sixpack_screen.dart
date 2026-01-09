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
import '../widgets/recording/flight_recording_controls.dart';
import '../providers/flight_recording_provider.dart';

/// 🎯 SixPack Screen - Tela principal de instrumentos
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
  bool _recoveryDialogShown = false;
  bool _controlsVisible = true;
  
  // 🔄 Listener manual para recovery
  ProviderSubscription<RecordingState>? _recordingSubscription;

  @override
  void initState() {
    super.initState();

    _controller = SixPackController(ref, context);
    _interpolation = InterpolationService();

    Future.microtask(() {
      _controller.initializeWatchdog();
      _controller.setupOrientations();
      _startInterpolationIfEnabled();
      _setupRecoveryListener();
    });
  }

  void _setupRecoveryListener() {
    // Cancelar listener anterior se existir
    _recordingSubscription?.close();
    
    // Criar listener manual (funciona fora do build)
    _recordingSubscription = ref.listenManual<RecordingState>(
      flightRecordingProvider,
      (previous, next) {
        _tryShowRecoveryDialog(next);
      },
      fireImmediately: true, // 🔑 Dispara imediatamente com estado atual
    );
  }

  void _tryShowRecoveryDialog(RecordingState state) {
    if (!mounted || _recoveryDialogShown) return;
    if (state.flightId != null && !state.isRecording) {
      _recoveryDialogShown = true;
      
      // Usar addPostFrameCallback para garantir que o context está pronto
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showRecoveryDialog(state.flightId!, state.pointsRecorded);
        }
      });
    }
  }

  void _startInterpolationIfEnabled() {
    final settings = ref.read(telemetrySettingsProvider);
    if (settings.interpolationEnabled) {
      _startTicker();
    }
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
  }

  void _showRecoveryDialog(String flightId, int points) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Voo Interrompido'),
        content: Text(
          'Encontrado voo não finalizado.\n\n'
          'ID: ${flightId.substring(0, 8)}...\n'
          'Pontos salvos: $points\n\n'
          'Deseja retomar ou descartar?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(flightRecordingProvider.notifier).discardRecording();
            },
            child: const Text('DESCARTAR', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(flightRecordingProvider.notifier).resumeRecording();
            },
            child: const Text('RETOMAR'),
          ),
        ],
      ),
    );
  }

  void _startTicker() {
    if (_ticker != null) return;
    _ticker = createTicker(_onTick);
    _ticker!.start();
  }

  void _stopTicker() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    final rawData = ref.read(telemetryProvider);

    if (rawData != _lastRawData) {
      _interpolation.setTarget(rawData);
      _lastRawData = rawData;
    }

    setState(() {
      _displayData = _interpolation.getInterpolated();
    });
  }

  void _handleToggleInterpolation() {
    final wasEnabled = ref.read(telemetrySettingsProvider).interpolationEnabled;
    
    _controller.toggleInterpolation();

    if (wasEnabled) {
      _stopTicker();
    } else {
      _interpolation.reset();
      _startTicker();
    }
  }

  @override
  void dispose() {
    _recordingSubscription?.close();
    _stopTicker();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(telemetrySettingsProvider);

    final telemetry = settings.interpolationEnabled
        ? _displayData
        : ref.watch(telemetryProvider);

    final isStale = settings.interpolationEnabled && _interpolation.isStale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _toggleControls,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                children: [
                  _buildSixPackPage(telemetry),
                  _buildTelemetryPage(telemetry),
                ],
              ),

              // 🎬 Controles de gravação
              Positioned(
                bottom: 16,
                left: 16,
                right: 80,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: FlightRecordingControls(
                      instructorId: 'mock_instructor',
                      studentId: 'mock_student',
                      aircraftId: 'mock_aircraft',
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const ConnectionStatusWidget(),
                ),
              ),

              // ⚠️ Aviso sem sinal (sempre visível)
              // 🔍 DEBUG SYNC
              Positioned(
                top: 100,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black87,
                  child: Consumer(builder: (context, ref, _) {
                    final conn = ref.watch(connectivityServiceProvider);
                    return Text(
                      "NET: ${conn.currentState.type}\nERR: ${ref.watch(flightRecordingProvider).error ?? "none"}\nINT: ${conn.currentState.hasInternet}\nSYNC: ${conn.canSync}",
                      style: const TextStyle(color: Colors.yellow, fontSize: 10),
                    );
                  }),
                ),
              ),
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
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _controlsVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: !_controlsVisible,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✨ Toggle Interpolação
              FloatingActionButton(
                heroTag: 'interpolation',
                onPressed: _handleToggleInterpolation,
                backgroundColor: settings.interpolationEnabled 
                    ? Colors.green 
                    : Colors.grey,
                child: Icon(
                  settings.interpolationEnabled 
                      ? Icons.auto_awesome 
                      : Icons.auto_awesome_outlined,
                ),
              ),
              const SizedBox(height: 8),

              // 🔄 Reconectar
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

              // ❌ Desconectar
              FloatingActionButton(
                heroTag: 'disconnect',
                onPressed: _controller.disconnect,
                backgroundColor: Colors.red,
                child: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSixPackPage(TelemetryData telemetry) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;

        if (isLandscape) {
          return Column(
            children: [
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
          return Column(
            children: [
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

  Widget _buildTelemetryPage(TelemetryData telemetry) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.grey.shade900,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                  ),
                ),
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
