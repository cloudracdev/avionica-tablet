import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/telemetry_provider.dart';

class CalibrationScreen extends ConsumerStatefulWidget {
  const CalibrationScreen({super.key});

  @override
  ConsumerState<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends ConsumerState<CalibrationScreen> {
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _pitchController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _altitudeController = TextEditingController();

  @override
  void dispose() {
    _headingController.dispose();
    _pitchController.dispose();
    _rollController.dispose();
    _altitudeController.dispose();
    super.dispose();
  }

  void _applyCalibration() {
    final calibrationService = ref.read(calibrationServiceProvider);
    final telemetry = ref.read(telemetryProvider);

    // Heading
    if (_headingController.text.isNotEmpty) {
      double realHeading = double.tryParse(_headingController.text) ?? 0.0;
      calibrationService.calibrateHeading(realHeading, telemetry.heading);
    }

    // Pitch
    if (_pitchController.text.isNotEmpty) {
      double realPitch = double.tryParse(_pitchController.text) ?? 0.0;
      calibrationService.calibratePitch(realPitch, telemetry.pitch);
    }

    // Roll
    if (_rollController.text.isNotEmpty) {
      double realRoll = double.tryParse(_rollController.text) ?? 0.0;
      calibrationService.calibrateRoll(realRoll, telemetry.roll);
    }

    // Altitude
    if (_altitudeController.text.isNotEmpty) {
      double realAltitude = double.tryParse(_altitudeController.text) ?? 0.0;
      calibrationService.calibrateAltitude(realAltitude, telemetry.altitude);
    }

    _navigateToSixPack();
  }

  void _zeroPitch() {
    final calibrationService = ref.read(calibrationServiceProvider);
    final telemetry = ref.read(telemetryProvider);
    calibrationService.zeroPitch(telemetry.pitch);
    _pitchController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Pitch zerado'), duration: Duration(seconds: 1)),
    );
  }

  void _zeroRoll() {
    final calibrationService = ref.read(calibrationServiceProvider);
    final telemetry = ref.read(telemetryProvider);
    calibrationService.zeroRoll(telemetry.roll);
    _rollController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Roll zerado'), duration: Duration(seconds: 1)),
    );
  }

  void _zeroAltitude() {
    final calibrationService = ref.read(calibrationServiceProvider);
    final telemetry = ref.read(telemetryProvider);
    calibrationService.zeroAltitude(telemetry.altitude);
    _altitudeController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Altitude zerada'), duration: Duration(seconds: 1)),
    );
  }

  void _navigateToSixPack() {
    context.go('/sixpack');
  }

  Widget _buildValueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationRow({
    required String label,
    required String hint,
    required String suffix,
    required String currentValue,
    required TextEditingController controller,
    required VoidCallback onZero,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Atual: $currentValue',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    suffixText: suffix,
                    suffixStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey.shade800,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onZero,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('ZERAR'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.watch(telemetryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.tune, color: Colors.blue, size: 48),
              const SizedBox(height: 12),
              const Text(
                '⚙️ CALIBRAÇÃO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ajuste os instrumentos antes do voo',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),

              const SizedBox(height: 24),

              // Valores atuais
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      '📊 VALORES ATUAIS',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildValueRow('🧭 Bússola', '${telemetry.heading.toInt()}°'),
                    _buildValueRow('⬆️ Pitch', '${telemetry.pitch.toStringAsFixed(1)}°'),
                    _buildValueRow('↔️ Roll', '${telemetry.roll.toStringAsFixed(1)}°'),
                    _buildValueRow('📍 Altitude', '${telemetry.altitude.toStringAsFixed(0)}m'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '�� CALIBRAR INSTRUMENTOS',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Bússola
              _buildCalibrationRow(
                label: '🧭 Bússola (Heading)',
                hint: 'Valor real',
                suffix: '°',
                currentValue: '${telemetry.heading.toInt()}°',
                controller: _headingController,
                onZero: () {
                  final calibrationService = ref.read(calibrationServiceProvider);
                  calibrationService.calibrateHeading(0, telemetry.heading);
                  _headingController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Heading zerado'), duration: Duration(seconds: 1)),
                  );
                },
              ),

              // Pitch
              _buildCalibrationRow(
                label: '⬆️ Pitch',
                hint: 'Valor real',
                suffix: '°',
                currentValue: '${telemetry.pitch.toStringAsFixed(1)}°',
                controller: _pitchController,
                onZero: _zeroPitch,
              ),

              // Roll
              _buildCalibrationRow(
                label: '↔️ Roll',
                hint: 'Valor real',
                suffix: '°',
                currentValue: '${telemetry.roll.toStringAsFixed(1)}°',
                controller: _rollController,
                onZero: _zeroRoll,
              ),

              // Altitude
              _buildCalibrationRow(
                label: '📍 Altitude',
                hint: 'Elevação real',
                suffix: 'm',
                currentValue: '${telemetry.altitude.toStringAsFixed(0)}m',
                controller: _altitudeController,
                onZero: _zeroAltitude,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _navigateToSixPack,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'PULAR',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _applyCalibration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'APLICAR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
