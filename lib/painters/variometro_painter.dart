import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for the variometer (vertical speed indicator).
///
/// Renders the scale, needle, and visual indicators for climb/descent rate.
class VariometroPainter extends CustomPainter {
  /// Vertical speed scaled to -2 to +2 range (thousands of ft/min)
  final double varioScaled;

  /// Vertical speed in m/s (for color coding)
  final double varioMs;

  const VariometroPainter({
    required this.varioScaled,
    required this.varioMs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dark background
    final bgPaint = Paint()..color = const Color(0xFF0A0A0A);
    canvas.drawCircle(center, radius * 0.90, bgPaint);

    // Draw scale and numbers
    _drawScale(canvas, center, radius);

    // Center texts
    _drawCenterTexts(canvas, center, radius);

    // Up/Down indicators
    _drawUpDownTexts(canvas, center, radius);

    // Needle
    _drawNeedle(canvas, center, radius);

    // Center hub
    _drawCenterHub(canvas, center, radius);

    // Dynamic colored border (green/red/cyan)
    Color borderColor = varioMs > 0
        ? Colors.green
        : (varioMs < 0 ? Colors.red : Colors.cyan);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);
  }

  /// Draws scale marks and numbers.
  void _drawScale(Canvas canvas, Offset center, double radius) {
    // Scale positions based on real instrument
    // Zero at 9 o'clock (180°)
    // Climb: 0 → 0.5 → 1 → 1.5 → 2 (upper half clockwise)
    // Descent: 0 → 0.5 → 1 → 1.5 → 2 (lower half clockwise)

    final positions = [
      // Climb (from 9h clockwise to 3h via top)
      {'value': '0', 'angle': 180.0, 'isMajor': true}, // 9h (left)
      {'value': '', 'angle': 202.5, 'isMajor': false},
      {'value': '.5', 'angle': 225.0, 'isMajor': false}, // 10:30h
      {'value': '', 'angle': 247.5, 'isMajor': false},
      {'value': '1', 'angle': 270.0, 'isMajor': true}, // 12h (top)
      {'value': '', 'angle': 292.5, 'isMajor': false},
      {'value': '1.5', 'angle': 315.0, 'isMajor': false}, // 1:30h
      {'value': '', 'angle': 337.5, 'isMajor': false},
      {'value': '2', 'angle': 0.0, 'isMajor': true}, // 3h (right)

      // Descent (from 3h clockwise to 9h via bottom)
      {'value': '', 'angle': 22.5, 'isMajor': false},
      {'value': '1.5', 'angle': 45.0, 'isMajor': false}, // 4:30h
      {'value': '', 'angle': 67.5, 'isMajor': false},
      {'value': '1', 'angle': 90.0, 'isMajor': true}, // 6h (bottom)
      {'value': '', 'angle': 112.5, 'isMajor': false},
      {'value': '.5', 'angle': 135.0, 'isMajor': false}, // 7:30h
      {'value': '', 'angle': 157.5, 'isMajor': false},
    ];

    for (var pos in positions) {
      double angleDeg = pos['angle'] as double;
      double angleRad = angleDeg * math.pi / 180;
      bool isMajor = pos['isMajor'] as bool;
      String value = pos['value'] as String;

      // Draw mark line
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angleRad);

      final markPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = isMajor ? 2.5 : 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      double innerRadius = isMajor ? radius * 0.85 : radius * 0.90;
      canvas.drawLine(
        Offset(0, -innerRadius),
        Offset(0, -radius * 0.98),
        markPaint,
      );

      canvas.restore();

      // Draw number (only for major marks with value)
      if (value.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: value,
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
        double x = center.dx + textRadius * math.cos(angleRad);
        double y = center.dy + textRadius * math.sin(angleRad);

        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }
  }

  /// Draws center text labels.
  void _drawCenterTexts(Canvas canvas, Offset center, double radius) {
    _drawText(
      canvas,
      '1000 ft.',
      Offset(center.dx, center.dy - radius * 0.05),
      Colors.white,
      radius * 0.08,
      FontWeight.normal,
    );
    _drawText(
      canvas,
      'per min',
      Offset(center.dx, center.dy + radius * 0.08),
      Colors.white,
      radius * 0.08,
      FontWeight.normal,
    );
  }

  /// Draws up/down arrow indicators.
  void _drawUpDownTexts(Canvas canvas, Offset center, double radius) {
    // Up arrow
    final arrowUpPath = Path()
      ..moveTo(center.dx - radius * 0.68, center.dy - radius * 0.18)
      ..lineTo(center.dx - radius * 0.68, center.dy - radius * 0.10)
      ..moveTo(center.dx - radius * 0.68, center.dy - radius * 0.18)
      ..lineTo(center.dx - radius * 0.72, center.dy - radius * 0.14)
      ..moveTo(center.dx - radius * 0.68, center.dy - radius * 0.18)
      ..lineTo(center.dx - radius * 0.64, center.dy - radius * 0.14);

    canvas.drawPath(
      arrowUpPath,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    _drawText(
      canvas,
      'up',
      Offset(center.dx - radius * 0.55, center.dy - radius * 0.14),
      Colors.white,
      radius * 0.08,
      FontWeight.normal,
    );

    // Down arrow
    final arrowDownPath = Path()
      ..moveTo(center.dx - radius * 0.68, center.dy + radius * 0.18)
      ..lineTo(center.dx - radius * 0.68, center.dy + radius * 0.10)
      ..moveTo(center.dx - radius * 0.68, center.dy + radius * 0.18)
      ..lineTo(center.dx - radius * 0.72, center.dy + radius * 0.14)
      ..moveTo(center.dx - radius * 0.68, center.dy + radius * 0.18)
      ..lineTo(center.dx - radius * 0.64, center.dy + radius * 0.14);

    canvas.drawPath(
      arrowDownPath,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    _drawText(
      canvas,
      'dn',
      Offset(center.dx - radius * 0.55, center.dy + radius * 0.14),
      Colors.white,
      radius * 0.08,
      FontWeight.normal,
    );
  }

  /// Draws the indicator needle.
  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    double clampedValue = varioScaled.clamp(-2.0, 2.0);
    double needleAngle;

    if (clampedValue >= 0) {
      // Climb: clockwise from 180° to 360°/0° (passing through 270° top)
      needleAngle = 180 + (clampedValue * 90); // 180° to 360°
    } else {
      // Descent: counter-clockwise from 180° to 0° (passing through 90° bottom)
      needleAngle = 180 - (clampedValue.abs() * 90); // 180° to 0°
    }

    // Correction: subtract 270° because line points UP and we want LEFT at zero
    double needleRad = (needleAngle - 270) * math.pi / 180;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(needleRad);

    // White needle
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, radius * 0.08),
      Offset(0, -radius * 0.70),
      needlePaint,
    );

    // Yellow tip
    canvas.drawCircle(
      Offset(0, -radius * 0.70),
      radius * 0.03,
      Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  /// Draws center hub.
  void _drawCenterHub(Canvas canvas, Offset center, double radius) {
    // White hub
    canvas.drawCircle(
      center,
      radius * 0.05,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
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

  /// Helper to draw text.
  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    Color color,
    double fontSize,
    FontWeight weight,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(VariometroPainter oldDelegate) {
    return oldDelegate.varioScaled != varioScaled ||
        oldDelegate.varioMs != varioMs;
  }
}