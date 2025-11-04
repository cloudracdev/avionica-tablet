// ✅ CORRETO (2 níveis)
import '../../core/constants/filter_constants.dart';

/// Service for smoothing sensor data using EMA filters and dead zones.
///
/// Applies Exponential Moving Average (EMA) filtering combined with dead zone
/// thresholds to reduce sensor noise while maintaining responsiveness.
class SmoothingService {
  // Smoothed values
  double _smoothVelocidade = 0;
  double _smoothAltitude = 0;
  double _smoothHeading = 0;
  double _smoothPitch = 0;
  double _smoothRoll = 0;
  double _smoothVario = 0;
  double _smoothTemperatura = 0;
  double _smoothPressao = 0;
  double _smoothLat = 0;
  double _smoothLng = 0;
  double _smoothAccelX = 0;
  double _smoothAccelY = 0;

  // First reading flag (don't smooth initial value)
  bool _firstReading = true;

  /// Applies EMA filter with dead zone.
  ///
  /// Returns [currentSmooth] if change is below [deadZone] threshold.
  /// Otherwise applies EMA: S_t = α * Y_t + (1 - α) * S_{t-1}
  double _smooth(double newValue, double currentSmooth, double alpha, double deadZone) {
    // Dead zone: ignore small variations
    if ((newValue - currentSmooth).abs() < deadZone) {
      return currentSmooth;
    }
    
    // EMA: exponential smoothing
    return alpha * newValue + (1 - alpha) * currentSmooth;
  }

  /// Applies circular smoothing for heading (0-360°).
  ///
  /// Handles wrap-around at 0°/360° boundary correctly.
  double _smoothCircular(double newValue, double currentSmooth, double alpha, double deadZone) {
    // Normalize to 0-360
    while (newValue < 0) newValue += 360;
    while (newValue >= 360) newValue -= 360;
    while (currentSmooth < 0) currentSmooth += 360;
    while (currentSmooth >= 360) currentSmooth -= 360;

    // Calculate difference considering circular nature
    double diff = newValue - currentSmooth;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    // Dead zone
    if (diff.abs() < deadZone) {
      return currentSmooth;
    }

    // Circular EMA
    double result = currentSmooth + alpha * diff;
    
    // Normalize result
    while (result < 0) result += 360;
    while (result >= 360) result -= 360;
    
    return result;
  }

  /// Smooths all six-pack instrument data.
  ///
  /// On first call, returns raw data without smoothing.
  /// Subsequent calls apply EMA filtering with dead zones.
  Map<String, double> smoothData(Map<String, double> rawData) {
    // First reading: use raw values directly
    if (_firstReading) {
      _smoothVelocidade = rawData['velocidade'] ?? 0;
      _smoothAltitude = rawData['altitude'] ?? 0;
      _smoothHeading = rawData['heading'] ?? 0;
      _smoothPitch = rawData['pitch'] ?? 0;
      _smoothRoll = rawData['roll'] ?? 0;
      _smoothVario = rawData['vario'] ?? 0;
      _smoothTemperatura = rawData['temperatura'] ?? 0;
      _smoothPressao = rawData['pressao'] ?? 0;
      _smoothLat = rawData['lat'] ?? 0;
      _smoothLng = rawData['lng'] ?? 0;
      _smoothAccelX = rawData['acel_x'] ?? 0;
      _smoothAccelY = rawData['acel_y'] ?? 0;
      _firstReading = false;
      return rawData;
    }

    // Apply filters using centralized constants
    _smoothVelocidade = _smooth(
      rawData['velocidade'] ?? _smoothVelocidade,
      _smoothVelocidade,
      FilterConstants.alphaVelocidade,
      FilterConstants.deadZoneVelocidade,
    );

    _smoothAltitude = _smooth(
      rawData['altitude'] ?? _smoothAltitude,
      _smoothAltitude,
      FilterConstants.alphaAltitude,
      FilterConstants.deadZoneAltitude,
    );

    _smoothHeading = _smoothCircular(
      rawData['heading'] ?? _smoothHeading,
      _smoothHeading,
      FilterConstants.alphaHeading,
      FilterConstants.deadZoneHeading,
    );

    _smoothPitch = _smooth(
      rawData['pitch'] ?? _smoothPitch,
      _smoothPitch,
      FilterConstants.alphaPitch,
      FilterConstants.deadZonePitch,
    );

    _smoothRoll = _smooth(
      rawData['roll'] ?? _smoothRoll,
      _smoothRoll,
      FilterConstants.alphaRoll,
      FilterConstants.deadZoneRoll,
    );

    _smoothVario = _smooth(
      rawData['vario'] ?? _smoothVario,
      _smoothVario,
      FilterConstants.alphaVario,
      FilterConstants.deadZoneVario,
    );

    _smoothTemperatura = _smooth(
      rawData['temperatura'] ?? _smoothTemperatura,
      _smoothTemperatura,
      FilterConstants.alphaTemperatura,
      FilterConstants.deadZoneTemperatura,
    );

    _smoothPressao = _smooth(
      rawData['pressao'] ?? _smoothPressao,
      _smoothPressao,
      FilterConstants.alphaPressao,
      FilterConstants.deadZonePressao,
    );

    _smoothLat = _smooth(
      rawData['lat'] ?? _smoothLat,
      _smoothLat,
      FilterConstants.alphaLat,
      FilterConstants.deadZoneLat,
    );

    _smoothLng = _smooth(
      rawData['lng'] ?? _smoothLng,
      _smoothLng,
      FilterConstants.alphaLng,
      FilterConstants.deadZoneLng,
    );

    _smoothAccelX = _smooth(
      rawData['acel_x'] ?? _smoothAccelX,
      _smoothAccelX,
      FilterConstants.alphaAccelX,
      FilterConstants.deadZoneAccelX,
    );

    _smoothAccelY = _smooth(
      rawData['acel_y'] ?? _smoothAccelY,
      _smoothAccelY,
      FilterConstants.alphaAccelY,
      FilterConstants.deadZoneAccelY,
    );

    // Return smoothed data
    return {
      'velocidade': _smoothVelocidade,
      'altitude': _smoothAltitude,
      'heading': _smoothHeading,
      'pitch': _smoothPitch,
      'roll': _smoothRoll,
      'vario': _smoothVario,
      'temperatura': _smoothTemperatura,
      'pressao': _smoothPressao,
      'lat': _smoothLat,
      'lng': _smoothLng,
      'acel_x': _smoothAccelX,
      'acel_y': _smoothAccelY,
    };
  }

  /// Resets the filter to initial state.
  ///
  /// Next call to [smoothData] will not apply smoothing.
  void reset() {
    _firstReading = true;
  }
}