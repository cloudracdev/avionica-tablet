import 'package:flutter/material.dart';
import '../core/constants/instrument_constants.dart';
import '../core/constants/app_constants.dart';
import '../painters/coordenador_painter.dart';

/// Turn Coordinator instrument widget.
///
/// Displays rate of turn (airplane symbol) and slip/skid (inclinometer ball).
/// The airplane symbol tilts with roll, and the ball moves with lateral acceleration.
///
/// This widget is responsible only for layout and structure.
/// All rendering logic is in [CoordenadorPainter].
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