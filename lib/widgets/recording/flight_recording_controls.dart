/// 🎬 FLIGHT RECORDING CONTROLS
/// 
/// Widget com botões INICIAR/FINALIZAR gravação
/// Mostra status: tempo, pontos salvos

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/flight_recording_provider.dart';

class FlightRecordingControls extends ConsumerWidget {
  final String instructorId;
  final String? studentId;
  final String aircraftId;

  const FlightRecordingControls({
    super.key,
    required this.instructorId,
    this.studentId,
    required this.aircraftId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(flightRecordingProvider);

    if (state.isRecording) {
      return _RecordingActive(state: state);
    } else {
      return _RecordingInactive(
        instructorId: instructorId,
        studentId: studentId,
        aircraftId: aircraftId,
      );
    }
  }
}

/// 🟢 Botão INICIAR (quando não está gravando)
class _RecordingInactive extends ConsumerWidget {
  final String instructorId;
  final String? studentId;
  final String aircraftId;

  const _RecordingInactive({
    required this.instructorId,
    this.studentId,
    required this.aircraftId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          ref.read(flightRecordingProvider.notifier).startRecording(
            instructorId: instructorId,
            studentId: studentId,
            aircraftId: aircraftId,
          );
        },
        icon: const Icon(Icons.fiber_manual_record, color: Colors.white),
        label: const Text('INICIAR GRAVAÇÃO'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

/// 🔴 Status + Botão FINALIZAR (quando está gravando)
class _RecordingActive extends ConsumerWidget {
  final RecordingState state;

  const _RecordingActive({required this.state});

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador REC piscando
          const _BlinkingRec(),
          const SizedBox(width: 12),
          
          // Tempo
          Text(
            _formatDuration(state.duration),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          
          // Pontos salvos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${state.pointsRecorded} pts',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Botão FINALIZAR
          ElevatedButton.icon(
            onPressed: () => _showStopDialog(context, ref),
            icon: const Icon(Icons.stop, color: Colors.white),
            label: const Text('FINALIZAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showStopDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar Voo?'),
        content: Text(
          'Duração: ${_formatDuration(state.duration)}\n'
          'Pontos salvos: ${state.pointsRecorded}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(flightRecordingProvider.notifier).stopRecording();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('FINALIZAR'),
          ),
        ],
      ),
    );
  }
}

/// 🔴 Indicador REC piscando
class _BlinkingRec extends StatefulWidget {
  const _BlinkingRec();

  @override
  State<_BlinkingRec> createState() => _BlinkingRecState();
}

class _BlinkingRecState extends State<_BlinkingRec>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withValues(alpha: 0.5 + _controller.value * 0.5),
        ),
      ),
    );
  }
}
