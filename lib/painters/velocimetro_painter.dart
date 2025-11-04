import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter for the airspeed indicator.
///
/// Renders the scale with colored arcs (green, yellow, red),
/// scale marks, numbers, and needle indicating current airspeed.
class VelocimetroPainter extends CustomPainter {
  /// Airspeed in knots
  final double velocidadeKnots;

  /// Airspeed in km/h (for reference)
  final double velocidadeKmh;

  const VelocimetroPainter({
    required this.velocidadeKnots,
    required this.velocidadeKmh,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dark background
    final bgPaint = Paint()..color = const Color(0xFF0A0A0A);
    canvas.drawCircle(center, radius * 0.90, bgPaint);

    // Draw colored arcs and white line (FIRST - underneath)
    _drawColoredArcs(canvas, center, radius);
    _drawWhiteLine(canvas, center, radius);

    // Draw scale marks (ON TOP of colors)
    _drawScaleMarks(canvas, center, radius);

    // Draw numbers
    _drawNumbers(canvas, center, radius);

    // Draw needle
    _drawNeedle(canvas, center, radius);

    // Green border
    final borderPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  /// Converts knots to angle degrees.
  double _knotsToAngle(double knots) {
    if (knots <= 0) {
      return 0;
    } else if (knots <= 40) {
      return knots * 0.4;
    } else if (knots <= 240) {
      return 16 + (knots - 40) * 1.64;
    } else {
      return 344;
    }
  }

  /// Converts angle to radians for positioning (numbers).
  double _angleToRadiansForPosition(double degrees) {
    return (degrees - 90) * pi / 180;
  }

  /// Converts angle to radians for rotation (needle and lines).
  double _angleToRadiansForRotation(double degrees) {
    return degrees * pi / 180;
  }

  /// Draws colored arc zones (green, yellow, red).
  void _drawColoredArcs(Canvas canvas, Offset center, double radius) {
    // Green arc: 60 → 150 knots
    double greenStart = _knotsToAngle(60);
    double greenEnd = _knotsToAngle(150);
    double greenStartRad = _angleToRadiansForPosition(greenStart);
    double greenSweep = (greenEnd - greenStart) * pi / 180;

    final greenPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.12
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.94),
      greenStartRad,
      greenSweep,
      false,
      greenPaint,
    );

    // Yellow arc: 150 → 200 knots
    double yellowStart = _knotsToAngle(150);
    double yellowEnd = _knotsToAngle(200);
    double yellowStartRad = _angleToRadiansForPosition(yellowStart);
    double yellowSweep = (yellowEnd - yellowStart) * pi / 180;

    final yellowPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.12
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.94),
      yellowStartRad,
      yellowSweep,
      false,
      yellowPaint,
    );

    // Red arc: 200 → 220 knots
    double redStart = _knotsToAngle(200);
    double redEnd = _knotsToAngle(220);
    double redStartRad = _angleToRadiansForPosition(redStart);
    double redSweep = (redEnd - redStart) * pi / 180;

    final redPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.12
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.94),
      redStartRad,
      redSweep,
      false,
      redPaint,
    );
  }

  /// Draws white inner line (50-90 knots zone).
  void _drawWhiteLine(Canvas canvas, Offset center, double radius) {
    double lineStart = _knotsToAngle(50);
    double lineEnd = _knotsToAngle(90);
    double lineStartRad = _angleToRadiansForPosition(lineStart);
    double lineSweep = (lineEnd - lineStart) * pi / 180;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.88),
      lineStartRad,
      lineSweep,
      false,
      whitePaint,
    );
  }

  /// Draws scale marks (large and small).
  void _drawScaleMarks(Canvas canvas, Offset center, double radius) {
    // Large marks: at numbers (40, 60, 80...240)
    final mainMarks = [40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240];

    for (final knots in mainMarks) {
      double angle = _knotsToAngle(knots.toDouble());
      double radian = _angleToRadiansForRotation(angle);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(radian);

      final markPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(0, -radius * 0.88),
        Offset(0, -radius * 1.00),
        markPaint,
      );

      canvas.restore();
    }

    // Small marks: between numbers (50, 70, 90...230)
    final smallMarks = [50, 70, 90, 110, 130, 150, 170, 190, 210, 230];

    for (final knots in smallMarks) {
      double angle = _knotsToAngle(knots.toDouble());
      double radian = _angleToRadiansForRotation(angle);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(radian);

      final markPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(0, -radius * 0.92),
        Offset(0, -radius * 1.00),
        markPaint,
      );

      canvas.restore();
    }
  }

  /// Draws scale numbers.
  void _drawNumbers(Canvas canvas, Offset center, double radius) {
    final numbers = [40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240];

    for (final knots in numbers) {
      double angle = _knotsToAngle(knots.toDouble());
      double radian = _angleToRadiansForPosition(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: knots.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      double textRadius = radius * 0.70;
      double x = center.dx + textRadius * cos(radian);
      double y = center.dy + textRadius * sin(radian);

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  /// Draws the airspeed indicator needle.
  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    double clampedKnots = velocidadeKnots.clamp(0.0, 240.0);
    double angle = _knotsToAngle(clampedKnots);
    double radian = _angleToRadiansForRotation(angle);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(radian);

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, radius * 0.10),
      Offset(0, -radius * 0.85),
      needlePaint,
    );

    canvas.restore();

    // Center pivot
    canvas.drawCircle(
      center,
      radius * 0.05,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center,
      radius * 0.05,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(VelocimetroPainter oldDelegate) {
    return oldDelegate.velocidadeKnots != velocidadeKnots ||
        oldDelegate.velocidadeKmh != velocidadeKmh;
  }
}