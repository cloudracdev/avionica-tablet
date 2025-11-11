import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter for the altimeter.
///
/// Renders three pointers (100ft, 1000ft, 10000ft), scale marks,
/// numbers, and Kollsman window showing current QNH setting.
class AltimetroPainter extends CustomPainter {
  /// Altitude in feet
  final double altitudeFeet;

  /// Altitude in meters (for reference)
  final double altitudeMeters;

  /// QNH setting in inHg
  final double qnhInHg;

  const AltimetroPainter({
    required this.altitudeFeet,
    required this.altitudeMeters,
    required this.qnhInHg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dark background
    final bgPaint = Paint()..color = const Color(0xFF0A0A0A);
    canvas.drawCircle(center, radius * 0.90, bgPaint);

    // Draw scale (numbers and marks)
    _drawScale(canvas, center, radius);

    // Draw 3 pointers (order: 10k, 1k, 100 - smallest to largest)
    _drawPointer10000(canvas, center, radius);
    _drawPointer1000(canvas, center, radius);
    _drawPointer100(canvas, center, radius);

    // Draw Kollsman window
    _drawKollsmanWindow(canvas, center, radius);

    // Center hub
    _drawCenterHub(canvas, center, radius);

    // Orange border
    final borderPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  /// Draws scale with numbers 0-9 and tick marks.
  void _drawScale(Canvas canvas, Offset center, double radius) {
    for (int i = 0; i < 10; i++) {
      double angle = (i * 36.0 - 90) * pi / 180; // -90 to start at top

      // Number
      final textPainter = TextPainter(
        text: TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      double textRadius = radius * 0.70;
      double x = center.dx + textRadius * cos(angle);
      double y = center.dy + textRadius * sin(angle);

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );

      // Main mark line (thicker)
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle + pi / 2); // Adjust to be perpendicular

      final mainMarkPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(0, -radius * 0.85),
        Offset(0, -radius * 1.00),
        mainMarkPaint,
      );

      canvas.restore();

      // 4 small lines between each number (except after 9)
      if (i < 9) {
        for (int j = 1; j <= 4; j++) {
          double smallAngle = ((i * 36.0) + (j * 7.2) - 90) * pi / 180;

          canvas.save();
          canvas.translate(center.dx, center.dy);
          canvas.rotate(smallAngle + pi / 2);

          final smallMarkPaint = Paint()
            ..color = Colors.white
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

          canvas.drawLine(
            Offset(0, -radius * 0.92),
            Offset(0, -radius * 1.00),
            smallMarkPaint,
          );

          canvas.restore();
        }
      }
    }
  }

  /// Draws 100 feet pointer (medium/thin).
  /// 1 full rotation = 1000 feet
  void _drawPointer100(Canvas canvas, Offset center, double radius) {
    double feet100 = altitudeFeet % 1000;
    double angle = (feet100 / 1000) * 360;
    double radian = angle * pi / 180;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(radian);

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, radius * 0.08),
      Offset(0, -radius * 0.65),
      needlePaint,
    );

    canvas.restore();
  }

  /// Draws 1000 feet pointer (short/thick).
  /// 1 full rotation = 10,000 feet
  void _drawPointer1000(Canvas canvas, Offset center, double radius) {
    double feet1000 = (altitudeFeet % 10000) / 1000;
    double angle = (feet1000 / 10) * 360;
    double radian = angle * pi / 180;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(radian);

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, radius * 0.08),
      Offset(0, -radius * 0.40),
      needlePaint,
    );

    // Triangle tip
    final trianglePath = Path()
      ..moveTo(0, -radius * 0.40)
      ..lineTo(-radius * 0.03, -radius * 0.33)
      ..lineTo(radius * 0.03, -radius * 0.33)
      ..close();

    canvas.drawPath(
      trianglePath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  /// Draws 10,000 feet pointer (triangular).
  /// 1 full rotation = 100,000 feet
  void _drawPointer10000(Canvas canvas, Offset center, double radius) {
    double feet10000 = (altitudeFeet % 100000) / 10000;
    double angle = (feet10000 / 10) * 360;
    double radian = angle * pi / 180;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(radian);

    // Thin long needle (stem)
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, radius * 0.08),
      Offset(0, -radius * 0.75),
      needlePaint,
    );

    // Triangle at tip
    final trianglePath = Path()
      ..moveTo(0, -radius * 0.75)
      ..lineTo(-radius * 0.035, -radius * 0.68)
      ..lineTo(radius * 0.035, -radius * 0.68)
      ..close();

    canvas.drawPath(
      trianglePath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  /// Draws Kollsman window showing QNH setting.
  void _drawKollsmanWindow(Canvas canvas, Offset center, double radius) {
    final windowRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + radius * 0.30),
      width: radius * 0.50,
      height: radius * 0.18,
    );

    // Window background
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, const Radius.circular(4)),
      Paint()..color = Colors.black,
    );

    // Window border
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, const Radius.circular(4)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // QNH text
    final textPainter = TextPainter(
      text: TextSpan(
        text: qnhInHg.toStringAsFixed(2),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.10,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        windowRect.center.dx - textPainter.width / 2,
        windowRect.center.dy - textPainter.height / 2,
      ),
    );
  }

  /// Draws center hub.
  void _drawCenterHub(Canvas canvas, Offset center, double radius) {
    // White hub
    canvas.drawCircle(
      center,
      radius * 0.05,
      Paint()..color = Colors.white,
    );

    // Black border
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
  bool shouldRepaint(AltimetroPainter oldDelegate) {
    return oldDelegate.altitudeFeet != altitudeFeet ||
        oldDelegate.altitudeMeters != altitudeMeters ||
        oldDelegate.qnhInHg != qnhInHg;
  }
}