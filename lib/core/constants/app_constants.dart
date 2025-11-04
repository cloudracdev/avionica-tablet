/// General application constants for QFLY Flight Instruction System.
///
/// Contains app-wide configuration values, strings, and settings.
class AppConstants {
  AppConstants._(); // Prevent instantiation

  // ==========================================================================
  // APPLICATION INFO
  // ==========================================================================

  /// Application name displayed in UI
  static const String appName = 'QFLY - Sistema de Instrução';

  /// Application emoji/icon
  static const String appEmoji = '✈️';

  /// Application version
  static const String appVersion = '2.0.0';

  // ==========================================================================
  // WEBSOCKET CONFIGURATION
  // ==========================================================================

  /// Default ESP32 WebSocket URL
  /// 
  /// Connect to ESP32 Access Point at this address
  static const String defaultWebSocketUrl = 'ws://192.168.4.1:81';

  /// WebSocket reconnection delay (milliseconds)
  /// 
  /// Time to wait before attempting reconnection
  static const int reconnectionDelay = 3000;

  /// WebSocket connection timeout (milliseconds)
  static const int connectionTimeout = 5000;

  /// Maximum reconnection attempts before giving up
  static const int maxReconnectionAttempts = 10;

  // ==========================================================================
  // DATA UPDATE RATES
  // ==========================================================================

  /// Target update rate for instrument data (Hz)
  /// 
  /// 30 Hz provides smooth instrument animation
  static const int instrumentUpdateRate = 30;

  /// Telemetry data transmission rate (Hz)
  /// 
  /// 10 Hz sufficient for logging and recording
  static const int telemetryUpdateRate = 10;

  // ==========================================================================
  // PHYSICAL LIMITS
  // ==========================================================================

  /// Maximum pitch angle (degrees)
  static const double maxPitch = 90.0;

  /// Minimum pitch angle (degrees)
  static const double minPitch = -90.0;

  /// Maximum roll angle (degrees)
  static const double maxRoll = 180.0;

  /// Minimum roll angle (degrees)
  static const double minRoll = -180.0;

  /// Maximum altitude for display (meters)
  static const double maxAltitude = 10000.0;

  /// Minimum altitude for display (meters)
  static const double minAltitude = -500.0;

  /// Maximum airspeed for display (km/h)
  static const double maxAirspeed = 300.0;

  /// Maximum vertical speed for display (m/s)
  static const double maxVerticalSpeed = 15.0;

  /// Minimum vertical speed for display (m/s)
  static const double minVerticalSpeed = -15.0;

  // ==========================================================================
  // UI STRINGS - CONNECTION
  // ==========================================================================

  static const String connectingMessage = '🔄 Conectando ao ESP32...';
  static const String connectedMessage = '✅ Conectado com sucesso!';
  static const String disconnectedMessage = '❌ Desconectado do ESP32';
  static const String connectionErrorMessage = '⚠️ Erro de conexão';
  static const String reconnectingMessage = '🔄 Reconectando...';

  // ==========================================================================
  // UI STRINGS - CALIBRATION
  // ==========================================================================

  static const String calibratingMessage = '⚙️ Calibrando instrumentos...';
  static const String calibrationCompleteMessage = '✅ Calibração completa!';
  static const String calibrationResetMessage = '🔄 Calibração resetada';

  // ==========================================================================
  // UI STRINGS - INSTRUMENT TITLES
  // ==========================================================================

  static const String titleHorizonArtificial = 'HORIZONTE ARTIFICIAL';
  static const String titleCoordenador = 'COORDENADOR';
  static const String titleAltimetro = 'ALTÍMETRO';
  static const String titleVelocimetro = 'VELOCÍMETRO';
  static const String titleBussola = 'BÚSSOLA';
  static const String titleVariometro = 'VARIÔMETRO';

  // ==========================================================================
  // DEFAULT VALUES (when no sensor data available)
  // ==========================================================================

  /// Default altitude when no sensor data (meters)
  static const double defaultAltitude = 0.0;

  /// Default airspeed when no sensor data (km/h)
  static const double defaultAirspeed = 0.0;

  /// Default heading when no sensor data (degrees)
  static const double defaultHeading = 0.0;

  /// Default pitch when no sensor data (degrees)
  static const double defaultPitch = 0.0;

  /// Default roll when no sensor data (degrees)
  static const double defaultRoll = 0.0;

  /// Default vertical speed when no sensor data (m/s)
  static const double defaultVerticalSpeed = 0.0;

  /// Default temperature when no sensor data (°C)
  static const double defaultTemperature = 15.0;

  /// Default pressure when no sensor data (Pa)
  static const double defaultPressure = 101325.0;

  // ==========================================================================
  // PERFORMANCE SETTINGS
  // ==========================================================================

  /// Enable performance monitoring (debug builds only)
  static const bool enablePerformanceMonitoring = false;

  /// Target frame rate (FPS)
  static const int targetFrameRate = 60;

  /// Enable debug mode (shows additional info)
  static const bool debugMode = false;

  /// Enable verbose logging
  static const bool verboseLogging = false;
}