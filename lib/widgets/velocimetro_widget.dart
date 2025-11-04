import 'package:flutter/material.dart';
import '../painters/velocimetro_painter.dart';

/// Airspeed indicator widget.
///
/// Displays airspeed in knots and km/h with colored arc zones.
class VelocimetroWidget extends StatelessWidget {
  /// Airspeed in km/h
  final double velocidade;

  const VelocimetroWidget({
    super.key,
    required this.velocidade,
  });

  @override
  Widget build(BuildContext context) {
    // Convert km/h to knots (1 knot = 1.852 km/h)
    double velocidadeKnots = velocidade / 1.852;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'VELOCIDADE',
              style: TextStyle(
                color: Colors.green,
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
                    painter: VelocimetroPainter(
                      velocidadeKnots: velocidadeKnots,
                      velocidadeKmh: velocidade,
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
              '${velocidadeKnots.toStringAsFixed(1)} nós | '
              '${velocidade.toStringAsFixed(1)} km/h',
              style: const TextStyle(
                color: Colors.grey,
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