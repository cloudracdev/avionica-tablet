/// Service for calibrating flight instruments.
///
/// Stores offset values to correct sensor readings against known references.
/// Handles both linear values (pitch, roll, altitude) and circular values (heading).
class CalibrationService {
  double _headingOffset = 0.0;
  double _pitchOffset = 0.0;
  double _rollOffset = 0.0;
  double _altitudeOffset = 0.0;

  /// Calibrates heading against a known reference.
  ///
  /// Example: If compass shows 90° but actual heading is 95°, offset = 5°
  void calibrateHeading(double realHeading, double currentHeading) {
    _headingOffset = realHeading - currentHeading;
  }

  /// Calibrates pitch against a known reference.
  ///
  /// Example: If sensor shows 2° but actual pitch is 5°, offset = 3°
  void calibratePitch(double realPitch, double currentPitch) {
    _pitchOffset = realPitch - currentPitch;
  }

  /// Calibrates roll against a known reference.
  ///
  /// Example: If sensor shows -1° but actual roll is 0°, offset = 1°
  void calibrateRoll(double realRoll, double currentRoll) {
    _rollOffset = realRoll - currentRoll;
  }

  /// Calibrates altitude against a known reference.
  ///
  /// Example: If sensor shows 920m but airport elevation is 910m, offset = -10m
  void calibrateAltitude(double realAltitude, double currentAltitude) {
    _altitudeOffset = realAltitude - currentAltitude;
  }

  /// Zeros pitch to current position.
  ///
  /// Sets current pitch as the reference 0° level.
  void zeroPitch(double currentPitch) {
    _pitchOffset = 0 - currentPitch;
  }

  /// Zeros roll to current position.
  ///
  /// Sets current roll as the reference 0° level.
  void zeroRoll(double currentRoll) {
    _rollOffset = 0 - currentRoll;
  }

  /// Zeros altitude to current position.
  ///
  /// Sets current altitude as the reference 0m level (QFE).
  void zeroAltitude(double currentAltitude) {
    _altitudeOffset = 0 - currentAltitude;
  }

  /// Applies heading calibration with circular wrap-around.
  ///
  /// Ensures result stays within 0-360° range.
  double applyCalibratedHeading(double rawHeading) {
    double calibrated = rawHeading + _headingOffset;
    
    // Normalize to 0-360°
    while (calibrated < 0) {
      calibrated += 360;
    }
    while (calibrated >= 360) {
      calibrated -= 360;
    }
    
    return calibrated;
  }

  /// Applies pitch calibration offset.
  double applyCalibratedPitch(double rawPitch) {
    return rawPitch + _pitchOffset;
  }

  /// Applies roll calibration offset.
  double applyCalibratedRoll(double rawRoll) {
    return rawRoll + _rollOffset;
  }

  /// Applies altitude calibration offset.
  double applyCalibratedAltitude(double rawAltitude) {
    return rawAltitude + _altitudeOffset;
  }

  /// Resets all calibration offsets to zero.
  void resetAll() {
    _headingOffset = 0.0;
    _pitchOffset = 0.0;
    _rollOffset = 0.0;
    _altitudeOffset = 0.0;
  }

  /// Gets current heading offset.
  double get headingOffset => _headingOffset;

  /// Gets current pitch offset.
  double get pitchOffset => _pitchOffset;

  /// Gets current roll offset.
  double get rollOffset => _rollOffset;

  /// Gets current altitude offset.
  double get altitudeOffset => _altitudeOffset;
}
