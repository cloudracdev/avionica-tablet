import 'package:flutter/material.dart';
import '../core/constants/instrument_constants.dart';
import '../core/constants/app_constants.dart';
import '../painters/artificial_horizon_painter.dart';

/// Artificial Horizon instrument widget.
///
/// Displays aircraft pitch and roll attitude relative to the horizon.
/// The horizon line tilts with roll, and moves vertically with pitch.
///
/// This widget is responsible only for layout and structure.
/// All rendering logic is in [HorizonPainter].
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

          // Instrument (uses separate Painter)
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: EdgeInsets.all(InstrumentConstants.instrumentPadding),
                  child: CustomPaint(
                    painter: HorizonPainter(pitch: pitch, roll: roll),
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