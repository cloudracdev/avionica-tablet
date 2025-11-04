import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/instrument_constants.dart';
import '../core/constants/app_constants.dart';

/// Turn Coordinator instrument widget.
///
/// Displays rate of turn (airplane symbol) and slip/skid (inclinometer ball).
/// The airplane symbol tilts with roll, and the ball moves with lateral acceleration.
class CoordenadorWidget extends StatelessWidget {
  /// Roll angle in degrees
  final double roll;
  
  /// Rate of turn in degrees/second
  final double turnRate;
  
  /// X-axis acceleration in g-force
  final double accelX;
  
  /// Y-axis acceleration in g-force
  final double accelY;

  const CoordenadorWidget({
    super.key,
    required this.roll,
    this.turnRate = 0,
    this.accelX = 0,
    this.accelY = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(InstrumentConstants.instrumentMargin),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(
          color: Colors.teal,
          width: InstrumentConstants.instrumentBorderWidth,
        ),
        borderRadius: BorderRadius.circular(
          InstrumentConstants.instrumentBorderRadius,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: InstrumentConstants.instrumentPadding),
            child: Text(
              AppConstants.titleCoordenador,
              style: TextStyle(
                color: Colors.teal,
                fontSize: InstrumentConstants.instrumentTitleFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: InstrumentConstants.instrumentTitleLetterSpacing,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: EdgeInsets.all(InstrumentConstants.instrumentPadding),
                  child: CustomPaint(
                    painter: CoordenadorPainter(
                      roll: roll,
                      turnRate: turnRate,
                      accelX: accelX,
                      accelY: accelY,
                    ),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: InstrumentConstants.instrumentPadding),
            child: Text(
              'Roll: ${roll.toInt()}°',
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

/// Custom painter for the turn coordinator.
class CoordenadorPainter extends CustomPainter {
  final double roll;
  final double turnRate;
  final double accelX;
  final double accelY;

  CoordenadorPainter({
    required this.roll,
    required this.turnRate,
    required this.accelX,
    required this.accelY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background
    final bgPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = InstrumentConstants.instrumentBorderWidth;
    canvas.drawCircle(center, radius, borderPaint);

    // REFERENCE LINES (horizon and angles)
    final horizonPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Horizontal center line (0°/180°)
    final horizonWidth = radius * InstrumentConstants.coordenadorHorizonLineWidth;
    canvas.drawLine(
      Offset(center.dx - horizonWidth, center.dy),
      Offset(center.dx + horizonWidth, center.dy),
      horizonPaint,
    );

    // Diagonal reference lines (~30° and ~330°)
    final angle30 = InstrumentConstants.coordenadorDiagonalReferenceAngle * pi / 180;
    final innerPos = radius * InstrumentConstants.coordenadorDiagonalReferenceInnerPosition;
    final outerPos = radius * InstrumentConstants.coordenadorDiagonalReferenceOuterPosition;
    
    canvas.drawLine(
      Offset(center.dx - innerPos * cos(angle30), center.dy - innerPos * sin(angle30)),
      Offset(center.dx - outerPos * cos(angle30), center.dy - outerPos * sin(angle30)),
      horizonPaint,
    );
    
    canvas.drawLine(
      Offset(center.dx + innerPos * cos(angle30), center.dy - innerPos * sin(angle30)),
      Offset(center.dx + outerPos * cos(angle30), center.dy - outerPos * sin(angle30)),
      horizonPaint,
    );

    // L/R MARKS (Standard Rate Turn - vertical marks on sides)
    final markPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = InstrumentConstants.coordenadorStandardRateMarkStrokeWidth
      ..style = PaintingStyle.stroke;

    final markPos = radius * InstrumentConstants.coordenadorStandardRateMarkPosition;
    final markHeight = radius * InstrumentConstants.coordenadorStandardRateMarkWidth;

    // L mark (left)
    canvas.drawLine(
      Offset(center.dx - markPos, center.dy - markHeight),
      Offset(center.dx - markPos, center.dy + markHeight),
      markPaint,
    );

    // R mark (right)
    canvas.drawLine(
      Offset(center.dx + markPos, center.dy - markHeight),
      Offset(center.dx + markPos, center.dy + markHeight),
      markPaint,
    );

    // AIRPLANE SILHOUETTE (rear view)
    _drawAirplaneSilhouette(canvas, center, radius);

    // INCLINOMETER (Ball) - bottom section
    _drawInclinometer(canvas, center, radius);

    // L/R text (near border, lower position)
    final textOffset = radius * InstrumentConstants.coordenadorTextHorizontalOffset;
    final textVertical = center.dy + radius * InstrumentConstants.coordenadorTextVerticalOffset;
    
    _drawText(canvas, 'L', Offset(center.dx - textOffset, textVertical));
    _drawText(canvas, 'R', Offset(center.dx + textOffset, textVertical));
  }

  /// Draws the airplane silhouette (rear view).
  void _drawAirplaneSilhouette(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    
    // Rotate according to roll (matches horizon rotation)
    canvas.rotate(roll * pi / 180);

    final planePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = InstrumentConstants.coordenadorAirplaneStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Airplane dimensions
    final wingspan = radius * InstrumentConstants.coordenadorAirplaneWingspan;
    final fuselageHeight = radius * InstrumentConstants.coordenadorAirplaneFuselageHeight;
    final tailWidth = radius * InstrumentConstants.coordenadorAirplaneTailWidth;

    // WINGS (main horizontal line - highly visible)
    canvas.drawLine(
      Offset(-wingspan, 0),
      Offset(wingspan, 0),
      planePaint,
    );

    // FUSELAGE (vertical center line)
    canvas.drawLine(
      Offset(0, fuselageHeight / 2),
      Offset(0, -fuselageHeight),
      planePaint,
    );

    // HORIZONTAL STABILIZER (T-tail)
    canvas.drawLine(
      Offset(-tailWidth / 2, -fuselageHeight),
      Offset(tailWidth / 2, -fuselageHeight),
      planePaint,
    );

    // CENTER (reference point)
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final centerRadius = radius * InstrumentConstants.coordenadorAirplaneCenterRadius;
    canvas.drawCircle(Offset(0, 0), centerRadius, centerPaint);

    canvas.restore();
  }

  /// Draws the inclinometer (slip/skid ball).
  void _drawInclinometer(Canvas canvas, Offset center, double radius) {
    // Calculate ball lateral offset
    final rollRad = roll * pi / 180;
    final lateralAccel = accelY * cos(rollRad) + accelX * sin(rollRad);
    final maxOffset = radius * InstrumentConstants.coordenadorBallMaxOffset;
    final ballOffset = (lateralAccel / InstrumentConstants.coordenadorBallSensitivity)
        .clamp(-1.0, 1.0) * maxOffset;

    // Track (curved tube)
    final trackPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    final trackWidth = radius * InstrumentConstants.coordenadorTrackWidth;
    final trackHeight = radius * InstrumentConstants.coordenadorTrackHeight;
    final trackY = center.dy + radius * InstrumentConstants.coordenadorTrackVerticalPosition;

    final trackRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, trackY),
        width: trackWidth,
        height: trackHeight,
      ),
      Radius.circular(InstrumentConstants.coordenadorTrackCornerRadius),
    );
    canvas.drawRRect(trackRect, trackPaint);

    // Ball (black)
    final ballPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final ballRadius = radius * InstrumentConstants.coordenadorBallRadius;
    canvas.drawCircle(
      Offset(center.dx + ballOffset, trackY),
      ballRadius,
      ballPaint,
    );

    // Reference marks (coordination limits)
    final refPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = InstrumentConstants.coordenadorReferenceMarkStrokeWidth
      ..style = PaintingStyle.stroke;

    final refSpacing = radius * InstrumentConstants.coordenadorReferenceMarkSpacing;
    final refStart = center.dy + radius * InstrumentConstants.coordenadorReferenceMarkStart;
    final refEnd = center.dy + radius * InstrumentConstants.coordenadorReferenceMarkEnd;

    canvas.drawLine(
      Offset(center.dx - refSpacing, refStart),
      Offset(center.dx - refSpacing, refEnd),
      refPaint,
    );

    canvas.drawLine(
      Offset(center.dx + refSpacing, refStart),
      Offset(center.dx + refSpacing, refEnd),
      refPaint,
    );
  }

  /// Draws text at the specified position.
  void _drawText(Canvas canvas, String text, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: InstrumentConstants.coordenadorTextFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy),
    );
  }

  @override
  bool shouldRepaint(CoordenadorPainter oldDelegate) {
    return oldDelegate.roll != roll || 
           oldDelegate.turnRate != turnRate ||
           oldDelegate.accelX != accelX ||
           oldDelegate.accelY != accelY;
  }
}