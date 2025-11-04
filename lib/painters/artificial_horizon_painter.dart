import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/instrument_constants.dart';

/// Custom painter for the artificial horizon instrument.
///
/// Renders the sky, ground, horizon line, pitch scales, roll marks,
/// and fixed airplane symbol. The entire horizon rotates and translates
/// based on aircraft attitude.
class HorizonPainter extends CustomPainter {
  /// Pitch angle in degrees (-90 to +90)
  final double pitch;

  /// Roll angle in degrees (0 to 360)
  final double roll;

  const HorizonPainter({
    required this.pitch,
    required this.roll,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Clip circular (round instrument border)
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    // Save canvas state
    canvas.save();

    // Move origin to center
    canvas.translate(center.dx, center.dy);

    // Rotate with roll (convert to radians)
    canvas.rotate(-roll * pi / 180);

    // Translate vertically with pitch
    double pitchOffset = pitch * InstrumentConstants.horizonPitchScale;
    canvas.translate(0, pitchOffset);

    // Draw sky and ground
    _drawSkyAndGround(canvas, radius);

    // Draw horizon line
    _drawHorizonLine(canvas, radius);

    // Draw pitch scales
    _drawPitchScales(canvas, radius);

    // Restore canvas
    canvas.restore();

    // Draw fixed airplane symbol in center (doesn't rotate)
    _drawAirplane(canvas, center, radius);

    // Draw circular border
    _drawBorder(canvas, center, radius);

    // Draw roll marks at top
    _drawRollMarks(canvas, center, radius);
  }

  /// Draws sky (blue) and ground (brown) sections.
  void _drawSkyAndGround(Canvas canvas, double radius) {
    // Sky (blue)
    final skyPaint = Paint()..color = const Color(0xFF0077BE);
    canvas.drawRect(
      Rect.fromLTWH(-radius * 2, -radius * 2, radius * 4, radius * 2),
      skyPaint,
    );

    // Ground (brown)
    final groundPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRect(
      Rect.fromLTWH(-radius * 2, 0, radius * 4, radius * 2),
      groundPaint,
    );
  }

  /// Draws the horizon line (thick white).
  void _drawHorizonLine(Canvas canvas, double radius) {
    final horizonPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = InstrumentConstants.horizonLineWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(-radius * 1.5, 0),
      Offset(radius * 1.5, 0),
      horizonPaint,
    );
  }

  /// Draws pitch scale marks and numbers.
  void _drawPitchScales(Canvas canvas, double radius) {
    final scalePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Pitch lines every 10 degrees
    for (int angle = -90; angle <= 90; angle += InstrumentConstants.horizonPitchInterval) {
      if (angle == 0) continue; // Skip horizon line

      double y = -angle * InstrumentConstants.horizonPitchScale;
      double lineWidth = (angle % 20 == 0) ? 40.0 : 25.0;

      // Draw line
      canvas.drawLine(
        Offset(-lineWidth, y),
        Offset(lineWidth, y),
        scalePaint,
      );

      // Draw numbers (multiples of 10 only)
      if (angle.abs() >= 10) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: angle.abs().toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: InstrumentConstants.horizonPitchFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Numbers on both sides
        textPainter.paint(canvas, Offset(-lineWidth - 20, y - 6));
        textPainter.paint(canvas, Offset(lineWidth + 8, y - 6));
      }
    }
  }

  /// Draws the fixed airplane symbol (doesn't rotate with horizon).
  void _drawAirplane(Canvas canvas, Offset center, double radius) {
    final planePaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = InstrumentConstants.horizonAirplaneStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final wingspan = radius * InstrumentConstants.horizonAirplaneWingspan;

    // Airplane wings (horizontal)
    canvas.drawLine(
      Offset(center.dx - wingspan, center.dy),
      Offset(center.dx - 15, center.dy),
      planePaint,
    );
    canvas.drawLine(
      Offset(center.dx + 15, center.dy),
      Offset(center.dx + wingspan, center.dy),
      planePaint,
    );

    // Airplane center (circle)
    canvas.drawCircle(
      center,
      radius * InstrumentConstants.horizonAirplaneCenterRadius,
      Paint()..color = Colors.yellow,
    );

    // Airplane nose (small triangle)
    final nosePath = Path()
      ..moveTo(center.dx, center.dy - 10)
      ..lineTo(center.dx - 4, center.dy - 2)
      ..lineTo(center.dx + 4, center.dy - 2)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = Colors.yellow);
  }

  /// Draws the circular border.
  void _drawBorder(Canvas canvas, Offset center, double radius) {
    final borderPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, borderPaint);
  }

  /// Draws roll angle marks around the top of the instrument.
  void _drawRollMarks(Canvas canvas, Offset center, double radius) {
    final markPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Roll marks: 0°, 10°, 20°, 30°, 45°, 60°
    final angles = [0, 10, 20, 30, 45, 60];

    for (final angle in angles) {
      for (final side in [-1, 1]) {
        final actualAngle = angle * side;
        final radian = (actualAngle - 90) * pi / 180; // -90 to start at top

        final outerX = center.dx +
            radius * InstrumentConstants.horizonRollMarkOuterPosition * cos(radian);
        final outerY = center.dy +
            radius * InstrumentConstants.horizonRollMarkOuterPosition * sin(radian);

        // Longer marks for 0°, 30°, 60°
        final length = (angle == 0 || angle == 30 || angle == 60)
            ? InstrumentConstants.horizonRollMarkMajorLength
            : InstrumentConstants.horizonRollMarkMinorLength;

        final innerX = center.dx + radius * length * cos(radian);
        final innerY = center.dy + radius * length * sin(radian);

        canvas.drawLine(
          Offset(outerX, outerY),
          Offset(innerX, innerY),
          markPaint,
        );
      }
    }

    // Triangle indicator at top (current roll mark)
    final triangleSize = InstrumentConstants.horizonRollTriangleSize;
    final trianglePos = radius * InstrumentConstants.horizonRollTrianglePosition;

    final trianglePath = Path()
      ..moveTo(center.dx, center.dy - trianglePos)
      ..lineTo(center.dx - triangleSize, center.dy - radius * 0.92)
      ..lineTo(center.dx + triangleSize, center.dy - radius * 0.92)
      ..close();

    canvas.drawPath(trianglePath, Paint()..color = Colors.yellow);
  }

  @override
  bool shouldRepaint(HorizonPainter oldDelegate) {
    return oldDelegate.pitch != pitch || oldDelegate.roll != roll;
  }
}