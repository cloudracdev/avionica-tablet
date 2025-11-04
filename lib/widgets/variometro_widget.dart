import 'package:flutter/material.dart';
import '../painters/variometro_painter.dart';

/// Variometer instrument widget.
///
/// Displays vertical speed (climb/descent rate) in m/s and ft/min.
/// Dynamic border color: green (climb), red (descent), cyan (level).
class VariometroWidget extends StatelessWidget {
  /// Vertical speed in m/s
  final double vario;

  const VariometroWidget({
    super.key,
    required this.vario,
  });

  @override
  Widget build(BuildContext context) {
    // Convert m/s to ft/min (1 m/s = 196.85 ft/min)
    double varioFtPerMin = vario * 196.85;
    double varioScaled = varioFtPerMin / 1000.0; // Scale to -2 to +2

    // Dynamic border color
    Color borderColor = vario > 0
        ? Colors.green
        : (vario < 0 ? Colors.red : Colors.cyan);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'VARIÔMETRO',
              style: TextStyle(
                color: borderColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Instrument (uses separate Painter)
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CustomPaint(
                    painter: VariometroPainter(
                      varioScaled: varioScaled,
                      varioMs: vario,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Numeric values
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${vario >= 0 ? '+' : ''}${vario.toStringAsFixed(1)} m/s | '
              '${varioFtPerMin >= 0 ? '+' : ''}${varioFtPerMin.toStringAsFixed(0)} ft/min',
              style: TextStyle(
                color: vario >= 0 ? Colors.green : Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}