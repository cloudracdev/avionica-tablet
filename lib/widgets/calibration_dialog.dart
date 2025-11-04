import 'package:flutter/material.dart';
import '../services/calibration/calibration_service.dart';

/// Calibration dialog for instrument offsets.
///
/// Allows calibrating compass heading and zeroing pitch, roll, and altitude readings.
class CalibrationDialog extends StatefulWidget {
  final CalibrationService calibrationService;
  final double currentHeading;
  final double currentPitch;
  final double currentRoll;
  final double currentAltitude;

  const CalibrationDialog({
    super.key,
    required this.calibrationService,
    required this.currentHeading,
    required this.currentPitch,
    required this.currentRoll,
    required this.currentAltitude,
  });

  @override
  State<CalibrationDialog> createState() => _CalibrationDialogState();
}

class _CalibrationDialogState extends State<CalibrationDialog> {
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
    // Calibrate compass if value entered
    if (_headingController.text.isNotEmpty) {
      double realHeading = double.tryParse(_headingController.text) ?? 0.0;
      widget.calibrationService.calibrateHeading(
        realHeading,
        widget.currentHeading,
      );
    }

    // Zero pitch if checked
    if (_zeroPitch) {
      widget.calibrationService.zeroPitch(widget.currentPitch);
    }

    // Zero roll if checked
    if (_zeroRoll) {
      widget.calibrationService.zeroRoll(widget.currentRoll);
    }

    // Zero altitude if checked
    if (_zeroAltitude) {
      widget.calibrationService.zeroAltitude(widget.currentAltitude);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              const Text(
                '⚙️ CALIBRAÇÃO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Compass input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🧭 Bússola Real:',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _headingController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Ex: 180',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      suffixText: '°',
                      suffixStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Atual: ${widget.currentHeading.toInt()}°',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: Colors.grey, height: 1),
              const SizedBox(height: 12),

              // Zero checkboxes
              const Text(
                '🔄 Zerar:',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              CheckboxListTile(
                title: Text(
                  'Pitch (${widget.currentPitch.toInt()}°)',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                value: _zeroPitch,
                onChanged: (value) => setState(() => _zeroPitch = value ?? false),
                activeColor: Colors.blue,
                checkColor: Colors.white,
                tileColor: Colors.grey.shade800,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(height: 6),

              CheckboxListTile(
                title: Text(
                  'Roll (${widget.currentRoll.toInt()}°)',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                value: _zeroRoll,
                onChanged: (value) => setState(() => _zeroRoll = value ?? false),
                activeColor: Colors.blue,
                checkColor: Colors.white,
                tileColor: Colors.grey.shade800,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(height: 6),

              CheckboxListTile(
                title: Text(
                  'Altitude (${widget.currentAltitude.toStringAsFixed(1)}m)',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                value: _zeroAltitude,
                onChanged: (value) => setState(() => _zeroAltitude = value ?? false),
                activeColor: Colors.blue,
                checkColor: Colors.white,
                tileColor: Colors.grey.shade800,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyCalibration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Aplicar',
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