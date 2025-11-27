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
  bool _zeroPitch = false;
  bool _zeroRoll = false;
  bool _zeroAltitude = false;

  @override
  void dispose() {
    _headingController.dispose();
    super.dispose();
  }

  void _applyCalibration() {
    final calibrationService = ref.read(calibrationServiceProvider);
    final telemetry = ref.read(telemetryProvider);

    if (_headingController.text.isNotEmpty) {
      double realHeading = double.tryParse(_headingController.text) ?? 0.0;
      calibrationService.calibrateHeading(realHeading, telemetry.heading);
    }

    if (_zeroPitch) {
      calibrationService.zeroPitch(telemetry.pitch);
    }

    if (_zeroRoll) {
      calibrationService.zeroRoll(telemetry.roll);
    }

    if (_zeroAltitude) {
      calibrationService.zeroAltitude(telemetry.altitude);
    }

    _navigateToSixPack();
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

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.watch(telemetryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.tune, color: Colors.blue, size: 60),
              const SizedBox(height: 16),
              const Text(
                '⚙️ CALIBRAÇÃO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ajuste os instrumentos antes do voo',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      '📊 VALORES ATUAIS',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildValueRow('🧭 Bússola', '${telemetry.heading.toInt()}°'),
                    _buildValueRow('⬆️ Pitch', '${telemetry.pitch.toStringAsFixed(1)}°'),
                    _buildValueRow('↔️ Roll', '${telemetry.roll.toStringAsFixed(1)}°'),
                    _buildValueRow('📍 Altitude', '${telemetry.altitude.toStringAsFixed(1)}m'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '🧭 CALIBRAR BÚSSOLA',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _headingController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Digite o heading real (ex: 180)',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  suffixText: '°',
                  suffixStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                '🔄 ZERAR INSTRUMENTOS',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              CheckboxListTile(
                title: Text(
                  'Zerar Pitch (${telemetry.pitch.toStringAsFixed(1)}°)',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: const Text(
                  'Define posição atual como 0°',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                value: _zeroPitch,
                onChanged: (value) => setState(() => _zeroPitch = value ?? false),
                activeColor: Colors.blue,
                tileColor: Colors.grey.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const SizedBox(height: 8),

              CheckboxListTile(
                title: Text(
                  'Zerar Roll (${telemetry.roll.toStringAsFixed(1)}°)',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: const Text(
                  'Define posição atual como 0°',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                value: _zeroRoll,
                onChanged: (value) => setState(() => _zeroRoll = value ?? false),
                activeColor: Colors.blue,
                tileColor: Colors.grey.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const SizedBox(height: 8),

              CheckboxListTile(
                title: Text(
                  'Zerar Altitude (${telemetry.altitude.toStringAsFixed(1)}m)',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: const Text(
                  'Define altitude atual como 0m (QFE)',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                value: _zeroAltitude,
                onChanged: (value) => setState(() => _zeroAltitude = value ?? false),
                activeColor: Colors.blue,
                tileColor: Colors.grey.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _navigateToSixPack,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'PULAR',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '✅ APLICAR E CONTINUAR',
                        style: TextStyle(
                          fontSize: 16,
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