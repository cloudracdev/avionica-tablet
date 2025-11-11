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
/// ⚠️ **SMOOTHING DISABLED** - All filters bypassed for raw data testing
class FilterConstants {
  FilterConstants._(); // Prevent instantiation

  // ==========================================================================
  // EMA ALPHA VALUES (Smoothing Factors) - ALL SET TO 1.0 (NO SMOOTHING)
  // ==========================================================================

  /// Smoothing factor for airspeed (km/h)
  /// 
  /// 1.0 = NO smoothing - raw values pass through
  static const double alphaVelocidade = 1.0;

  /// Smoothing factor for altitude (meters)
  /// 
  /// 1.0 = NO smoothing - raw values pass through
  static const double alphaAltitude = 1.0;

  /// Smoothing factor for heading (degrees)
  /// 
  /// 1.0 = NO smoothing - raw values pass through
  static const double alphaHeading = 1.0;

  /// Smoothing factor for pitch (degrees)
  /// 
  /// 1.0 = NO smoothing - raw values pass through
  static const double alphaPitch = 1.0;

  /// Smoothing factor for roll (degrees)
  /// 
  /// 1.0 = NO smoothing - raw values pass through
  static const double alphaRoll = 1.0;

  /// Smoothing factor for variometer (m/s)
  /// 
  /// 1.0 = NO smoothing - raw values pass through
  static const double alphaVario = 1.0;

  /// Smoothing factor for temperature (°C)
  /// 
  /// 1.0 = NO smoothing - raw values pass through
  static const double alphaTemperatura = 1.0;

  /// Smoothing factor for pressure (Pa)
  /// 
  /// 1.0 = NO smoothing - raw values pass through
  static const double alphaPressao = 1.0;

  /// Smoothing factor for GPS latitude
  /// 
  /// 1.0 = NO smoothing - raw values pass through
  static const double alphaLat = 1.0;

  /// Smoothing factor for GPS longitude
  /// 
  /// 1.0 = NO smoothing - raw values pass through
  static const double alphaLng = 1.0;

  /// Smoothing factor for X-axis acceleration (g)
  /// 
  /// 1.0 = NO smoothing - raw values pass through
  static const double alphaAccelX = 1.0;

  /// Smoothing factor for Y-axis acceleration (g)
  /// 
  /// 1.0 = NO smoothing - raw values pass through
  static const double alphaAccelY = 1.0;

  // ==========================================================================
  // DEAD ZONE THRESHOLDS - ALL SET TO 0.0 (NO THRESHOLD)
  // ==========================================================================

  /// Dead zone for airspeed (km/h)
  /// 
  /// 0.0 = No dead zone - all changes register
  static const double deadZoneVelocidade = 0.0;

  /// Dead zone for altitude (meters)
  /// 
  /// 0.0 = No dead zone - all changes register
  static const double deadZoneAltitude = 0.0;

  /// Dead zone for heading (degrees)
  /// 
  /// 0.0 = No dead zone - all changes register
  static const double deadZoneHeading = 0.0;

  /// Dead zone for pitch (degrees)
  /// 
  /// 0.0 = No dead zone - all changes register
  static const double deadZonePitch = 0.0;

  /// Dead zone for roll (degrees)
  /// 
  /// 0.0 = No dead zone - all changes register
  static const double deadZoneRoll = 0.0;

  /// Dead zone for variometer (m/s)
  /// 
  /// 0.0 = No dead zone - all changes register
  static const double deadZoneVario = 0.0;

  /// Dead zone for temperature (°C)
  /// 
  /// 0.0 = No dead zone - all changes register
  static const double deadZoneTemperatura = 0.0;

  /// Dead zone for pressure (Pa)
  /// 
  /// 0.0 = No dead zone - all changes register
  static const double deadZonePressao = 0.0;

  /// Dead zone for GPS latitude
  /// 
  /// 0.0 = No dead zone - all changes register
  static const double deadZoneLat = 0.0;

  /// Dead zone for GPS longitude
  /// 
  /// 0.0 = No dead zone - all changes register
  static const double deadZoneLng = 0.0;

  /// Dead zone for X-axis acceleration (g)
  /// 
  /// 0.0 = No dead zone - all changes register
  static const double deadZoneAccelX = 0.0;

  /// Dead zone for Y-axis acceleration (g)
  /// 
  /// 0.0 = No dead zone - all changes register
  static const double deadZoneAccelY = 0.0;
}