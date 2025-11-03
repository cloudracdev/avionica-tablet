class CalibrationService {
  double _headingOffset = 0.0;
  double _pitchOffset = 0.0;
  double _rollOffset = 0.0;
  double _altitudeOffset = 0.0;

  void calibrateHeading(double realHeading, double currentHeading) {
    _headingOffset = realHeading - currentHeading;
  }

  void zeroPitch(double currentPitch) {
    _pitchOffset = 0 - currentPitch;
  }

  void zeroRoll(double currentRoll) {
    _rollOffset = 0 - currentRoll;
  }

  void zeroAltitude(double currentAltitude) {
    _altitudeOffset = 0 - currentAltitude;
  }

  double applyCalibratedHeading(double rawHeading) {
    double calibrated = rawHeading + _headingOffset;
    while (calibrated < 0) calibrated += 360;
    while (calibrated >= 360) calibrated -= 360;
    return calibrated;
  }

  double applyCalibratedPitch(double rawPitch) {
    return rawPitch + _pitchOffset;
  }

  double applyCalibratedRoll(double rawRoll) {
    return rawRoll + _rollOffset;
  }

  double applyCalibratedAltitude(double rawAltitude) {
    return rawAltitude + _altitudeOffset;
  }

  void resetAll() {
    _headingOffset = 0.0;
    _pitchOffset = 0.0;
    _rollOffset = 0.0;
    _altitudeOffset = 0.0;
  }
}
