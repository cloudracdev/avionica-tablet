import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/instrument_constants.dart';
import '../core/constants/app_constants.dart';

/// Artificial Horizon instrument widget.
///
/// Displays aircraft pitch and roll attitude relative to the horizon.
/// The horizon line tilts with roll, and moves vertically with pitch.
class ArtificialHorizon extends StatelessWidget {
  /// Pitch angle in degrees (-90 to +90)
  final double pitch;
  
  /// Roll angle in degrees (0 to 360)
  final double roll;

  const ArtificialHorizon({
    super.key,
    required this.pitch,
    required this.roll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(InstrumentConstants.instrumentMargin),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(
          color: Colors.blue,
          width: InstrumentConstants.instrumentBorderWidth,
        ),
        borderRadius: BorderRadius.circular(
          InstrumentConstants.instrumentBorderRadius,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Padding(
            padding: EdgeInsets.only(top: InstrumentConstants.instrumentPadding),
            child: Text(
              AppConstants.titleHorizonArtificial,
              style: TextStyle(
                color: Colors.blue,
                fontSize: InstrumentConstants.instrumentTitleFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: InstrumentConstants.instrumentTitleLetterSpacing,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Instrument (CustomPaint)
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: EdgeInsets.all(InstrumentConstants.instrumentPadding),
                  child: CustomPaint(
                    painter: HorizonPainter(pitch: pitch, roll: roll),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),

          // Numeric values
          Padding(
            padding: EdgeInsets.only(bottom: InstrumentConstants.instrumentPadding),
            child: Text(
              'P:${pitch.toInt()}° R:${roll.toInt()}°',
              style: TextStyle(
                color: Colors.white,
                fontSize: InstrumentConstants.instrumentValueFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the artificial horizon.
class HorizonPainter extends CustomPainter {
  final double pitch;
  final double roll;

  HorizonPainter({required this.pitch, required this.roll});

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

    // Draw SKY (blue)
    final skyPaint = Paint()..color = const Color(0xFF0077BE);
    canvas.drawRect(
      Rect.fromLTWH(-radius * 2, -radius * 2, radius * 4, radius * 2),
      skyPaint,
    );

    // Draw GROUND (brown)
    final groundPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRect(
      Rect.fromLTWH(-radius * 2, 0, radius * 4, radius * 2),
      groundPaint,
    );

    // Draw HORIZON LINE (thick white)
    final horizonPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = InstrumentConstants.horizonLineWidth
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(-radius * 1.5, 0),
      Offset(radius * 1.5, 0),
      horizonPaint,
    );

    // Draw PITCH SCALES
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

    // Restore canvas
    canvas.restore();

    // Draw FIXED AIRPLANE symbol in center (doesn't rotate)
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

    // Draw CIRCULAR BORDER
    final borderPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, borderPaint);

    // Draw ROLL MARKS at top
    _drawRollMarks(canvas, center, radius);
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