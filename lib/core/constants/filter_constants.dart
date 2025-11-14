/// Filter constants for data smoothing algorithms.
///
/// Controls EMA (Exponential Moving Average) filters and dead zone thresholds
/// used to smooth sensor data from ESP32.
///
/// **EMA Formula:** S_t = α * Y_t + (1 - α) * S_{t-1}
/// - α (alpha): Smoothing factor (0.0 - 1.0)
///   - Higher α = more responsive (less smoothing)
///   - Lower α = more smoothing (less responsive)
///
/// **Dead Zone:** Minimum change threshold to register an update
/// - Prevents display jitter from sensor noise
/// - Values below threshold are ignored
///
/// ⚡ HIGH RESPONSIVENESS MODE - Quick instrument response
class FilterConstants {
  FilterConstants._(); // Prevent instantiation

  // ==========================================================================
  // EMA ALPHA VALUES (Smoothing Factors) - HIGH RESPONSIVENESS
  // ==========================================================================

  /// Smoothing factor for airspeed (km/h)
  /// 0.8 = Very responsive, minimal smoothing
  static const double alphaVelocidade = 0.8;

  /// Smoothing factor for altitude (meters)
  /// 0.7 = Responsive altitude changes
  static const double alphaAltitude = 0.7;

  /// Smoothing factor for heading (degrees)
  /// 0.9 = Very responsive direction changes
  static const double alphaHeading = 0.9;

  /// Smoothing factor for pitch (degrees)
  /// 0.9 = Immediate attitude response
  static const double alphaPitch = 0.9;

  /// Smoothing factor for roll (degrees)
  /// 0.9 = Immediate attitude response
  static const double alphaRoll = 0.9;

  /// Smoothing factor for variometer (m/s)
  /// 0.7 = Responsive vertical speed
  static const double alphaVario = 0.7;

  /// Smoothing factor for temperature (°C)
  /// 0.3 = Moderate smoothing (temperature changes slowly)
  static const double alphaTemperatura = 0.3;

  /// Smoothing factor for pressure (Pa)
  /// 0.5 = Moderate smoothing
  static const double alphaPressao = 0.5;

  /// Smoothing factor for GPS latitude
  /// 0.7 = Responsive position updates
  static const double alphaLat = 0.7;

  /// Smoothing factor for GPS longitude
  /// 0.7 = Responsive position updates
  static const double alphaLng = 0.7;

  /// Smoothing factor for X-axis acceleration (g)
  /// 0.8 = Very responsive
  static const double alphaAccelX = 0.8;

  /// Smoothing factor for Y-axis acceleration (g)
  /// 0.8 = Very responsive
  static const double alphaAccelY = 0.8;

  // ==========================================================================
  // DEAD ZONE THRESHOLDS - MINIMAL FILTERING
  // ==========================================================================

  /// Dead zone for airspeed (km/h)
  /// Ignore changes < 0.2 km/h
  static const double deadZoneVelocidade = 0.2;

  /// Dead zone for altitude (meters)
  /// Ignore changes < 0.2 meters
  static const double deadZoneAltitude = 0.2;

  /// Dead zone for heading (degrees)
  /// Ignore changes < 0.5 degrees
  static const double deadZoneHeading = 0.5;

  /// Dead zone for pitch (degrees)
  /// Ignore changes < 0.2 degrees
  static const double deadZonePitch = 0.2;

  /// Dead zone for roll (degrees)
  /// Ignore changes < 0.2 degrees
  static const double deadZoneRoll = 0.2;

  /// Dead zone for variometer (m/s)
  /// Ignore changes < 0.05 m/s
  static const double deadZoneVario = 0.05;

  /// Dead zone for temperature (°C)
  /// Ignore changes < 0.5°C
  static const double deadZoneTemperatura = 0.5;

  /// Dead zone for pressure (Pa)
  /// Ignore changes < 20 Pa
  static const double deadZonePressao = 20.0;

  /// Dead zone for GPS latitude
  /// Ignore changes < 0.00001 degrees (~1 meter)
  static const double deadZoneLat = 0.00001;

  /// Dead zone for GPS longitude
  /// Ignore changes < 0.00001 degrees (~1 meter)
  static const double deadZoneLng = 0.00001;

  /// Dead zone for X-axis acceleration (g)
  /// Ignore changes < 0.02g
  static const double deadZoneAccelX = 0.02;

  /// Dead zone for Y-axis acceleration (g)
  /// Ignore changes < 0.02g
  static const double deadZoneAccelY = 0.02;
}