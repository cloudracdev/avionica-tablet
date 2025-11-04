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
class FilterConstants {
  FilterConstants._(); // Prevent instantiation

  // ==========================================================================
  // EMA ALPHA VALUES (Smoothing Factors)
  // ==========================================================================

  /// Smoothing factor for airspeed (km/h)
  /// 
  /// 0.15 = moderate smoothing for stable display
  static const double alphaVelocidade = 0.15;

  /// Smoothing factor for altitude (meters)
  /// 
  /// 0.5 = more responsive - critical for flight safety
  static const double alphaAltitude = 0.5;

  /// Smoothing factor for heading (degrees)
  /// 
  /// 0.15 = moderate smoothing for compass stability
  static const double alphaHeading = 0.15;

  /// Smoothing factor for pitch (degrees)
  /// 
  /// 0.15 = moderate smoothing for horizon stability
  static const double alphaPitch = 0.15;

  /// Smoothing factor for roll (degrees)
  /// 
  /// 0.15 = moderate smoothing for horizon stability
  static const double alphaRoll = 0.15;

  /// Smoothing factor for variometer (m/s)
  /// 
  /// 0.3 = more responsive for vertical speed indication
  static const double alphaVario = 0.3;

  /// Smoothing factor for temperature (°C)
  /// 
  /// 0.1 = heavy smoothing - temperature changes slowly
  static const double alphaTemperatura = 0.1;

  /// Smoothing factor for pressure (Pa)
  /// 
  /// 0.3 = light smoothing for barometric data
  static const double alphaPressao = 0.3;

  /// Smoothing factor for GPS latitude
  /// 
  /// 0.1 = heavy smoothing for GPS position
  static const double alphaLat = 0.1;

  /// Smoothing factor for GPS longitude
  /// 
  /// 0.1 = heavy smoothing for GPS position
  static const double alphaLng = 0.1;

  /// Smoothing factor for X-axis acceleration (g)
  /// 
  /// 0.10 = light smoothing for turn coordinator ball
  static const double alphaAccelX = 0.10;

  /// Smoothing factor for Y-axis acceleration (g)
  /// 
  /// 0.10 = light smoothing for turn coordinator ball
  static const double alphaAccelY = 0.10;

  // ==========================================================================
  // DEAD ZONE THRESHOLDS
  // ==========================================================================

  /// Dead zone for airspeed (km/h)
  /// 
  /// Ignore changes smaller than 0.2 km/h
  static const double deadZoneVelocidade = 0.2;

  /// Dead zone for altitude (meters)
  /// 
  /// Ignore changes smaller than 0.5 meters (~1.6 feet)
  static const double deadZoneAltitude = 0.5;

  /// Dead zone for heading (degrees)
  /// 
  /// Ignore changes smaller than 0.5 degrees
  static const double deadZoneHeading = 0.5;

  /// Dead zone for pitch (degrees)
  /// 
  /// Ignore changes smaller than 0.3 degrees
  static const double deadZonePitch = 0.3;

  /// Dead zone for roll (degrees)
  /// 
  /// Ignore changes smaller than 0.3 degrees
  static const double deadZoneRoll = 0.3;

  /// Dead zone for variometer (m/s)
  /// 
  /// Ignore changes smaller than 0.02 m/s (~4 ft/min)
  static const double deadZoneVario = 0.02;

  /// Dead zone for temperature (°C)
  /// 
  /// Ignore changes smaller than 0.1°C
  static const double deadZoneTemperatura = 0.1;

  /// Dead zone for pressure (Pa)
  /// 
  /// Ignore changes smaller than 10 Pa (~0.1 hPa)
  static const double deadZonePressao = 10.0;

  /// Dead zone for GPS latitude
  /// 
  /// Ignore changes smaller than 0.00001 degrees (~1 meter)
  static const double deadZoneLat = 0.00001;

  /// Dead zone for GPS longitude
  /// 
  /// Ignore changes smaller than 0.00001 degrees (~1 meter)
  static const double deadZoneLng = 0.00001;

  /// Dead zone for X-axis acceleration (g)
  /// 
  /// No dead zone - respond to all movement for ball precision
  static const double deadZoneAccelX = 0.0;

  /// Dead zone for Y-axis acceleration (g)
  /// 
  /// No dead zone - respond to all movement for ball precision
  static const double deadZoneAccelY = 0.0;
}