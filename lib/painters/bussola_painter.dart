import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter for the compass/heading indicator.
///
/// Renders a rotating compass rose with cardinal directions
/// and a fixed airplane symbol indicating current heading.
class BussolaPainter extends CustomPainter {
  /// Magnetic heading in degrees (0-360)
  final double heading;

  const BussolaPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background
    final bgPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw rotating compass rose with markings
    _drawCompassRose(canvas, center, radius);

    // Draw fixed airplane in center (lubber line)
    _drawAirplane(canvas, center, radius);

    // Border
    final borderPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  /// Draws the rotating compass rose with marks and labels.
  void _drawCompassRose(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Rotate disk OPPOSITE to heading (heading increases = disk rotates counter-clockwise)
    canvas.rotate(-heading * pi / 180);

    // Draw markings and numbers
    for (int angle = 0; angle < 360; angle += 10) {
      canvas.save();
      canvas.rotate(angle * pi / 180);

      final isCardinal = angle % 90 == 0;
      final isMajor = angle % 30 == 0;

      // Mark line
      final markPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = isCardinal ? 2.5 : (isMajor ? 1.5 : 1)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final outerRadius = radius * 0.85;
      final innerRadius = isCardinal
          ? radius * 0.68
          : (isMajor ? radius * 0.74 : radius * 0.78);

      canvas.drawLine(
        Offset(0, -outerRadius),
        Offset(0, -innerRadius),
        markPaint,
      );

      // Text (only cardinals and multiples of 30)
      if (isMajor) {
        String label;
        if (angle == 0) {
          label = 'N';
        } else if (angle == 90) {
          label = 'E';
        } else if (angle == 180) {
          label = 'S';
        } else if (angle == 270) {
          label = 'O';
        } else {
          label = (angle ~/ 10).toString();
        }

        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isCardinal ? 14 : 10,
              fontWeight: isCardinal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        canvas.save();
        canvas.translate(0, -radius * 0.56);
        canvas.rotate(-angle * pi / 180); // Counter-rotate text
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.restore();
      }

      canvas.restore();
    }

    canvas.restore();
  }

  /// Draws the fixed airplane symbol (lubber line indicator).
  void _drawAirplane(Canvas canvas, Offset center, double radius) {
    final planePaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top lubber line - fixed heading indicator
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.9),
      Offset(center.dx, center.dy - radius * 0.6),
      Paint()
        ..color = Colors.yellow
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Airplane wings (small, in center)
    canvas.drawLine(
      Offset(center.dx - radius * 0.15, center.dy),
      Offset(center.dx + radius * 0.15, center.dy),
      planePaint,
    );

    // Fuselage
    canvas.drawLine(
      Offset(center.dx, center.dy + radius * 0.08),
      Offset(center.dx, center.dy - radius * 0.12),
      planePaint,
    );

    // Nose (triangle)
    final nosePath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.12)
      ..lineTo(center.dx - radius * 0.04, center.dy - radius * 0.06)
      ..lineTo(center.dx + radius * 0.04, center.dy - radius * 0.06)
      ..close();

    canvas.drawPath(
      nosePath,
      Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(BussolaPainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}