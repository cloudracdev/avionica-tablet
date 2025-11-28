/// Constants for telemetry interpolation system.
class InterpolationConstants {
  InterpolationConstants._();

  // ============================================================================
  // GLOBAL SETTINGS
  // ============================================================================

  static const int targetFps = 60;
  static const double frameDurationMs = 1000.0 / targetFps;

  /// Timeout para considerar dados "stale" (sem sinal)
  /// 3 segundos = ~9-12 pacotes perdidos consecutivos
  static const int staleTimeoutMs = 3000;

  /// Tempo máximo interpolando sem dados novos
  static const int maxInterpolationTimeMs = 2000;

  /// 🛡️ Max deltaTime em segundos (evita explosão após background)
  /// 100ms = tolerante a jank, mas não explode
  static const double maxDeltaTimeSeconds = 0.1;

  // ============================================================================
  // LINEAR INTERPOLATION (lerp) - Simple values
  // ============================================================================

  static const double lerpSpeedVelocidade = 0.15;
  static const double lerpSpeedAltitude = 0.12;
  static const double lerpSpeedTemperatura = 0.05;
  static const double lerpSpeedPressao = 0.08;
  static const double lerpSpeedGps = 0.10;

  // ============================================================================
  // SPRING INTERPOLATION - CRITICALLY DAMPED (sem bounce)
  // ============================================================================

  static const double springStiffnessPitch = 15.0;
  static const double springDampingPitch = 12.0;

  static const double springStiffnessRoll = 15.0;
  static const double springDampingRoll = 12.0;

  static const double springStiffnessVario = 10.0;
  static const double springDampingVario = 10.0;

  static const double springStiffnessGyroZ = 12.0;
  static const double springDampingGyroZ = 10.0;

  static const double springStiffnessAccel = 12.0;
  static const double springDampingAccel = 10.0;

  // ============================================================================
  // CIRCULAR INTERPOLATION - Heading (0-360°)
  // ============================================================================

  static const double lerpSpeedHeading = 0.12;

  // ============================================================================
  // 🛡️ PHYSICAL VALUE RANGES - Safety clamps
  // ============================================================================

  // Velocidade (knots)
  static const double minVelocidade = 0.0;
  static const double maxVelocidade = 500.0;

  // Altitude (metros)
  static const double minAltitude = -500.0;
  static const double maxAltitude = 15000.0;

  // Pitch (graus)
  static const double minPitch = -90.0;
  static const double maxPitch = 90.0;

  // Roll (graus)
  static const double minRoll = -180.0;
  static const double maxRoll = 180.0;

  // Variômetro (m/s)
  static const double minVario = -50.0;
  static const double maxVario = 50.0;

  // Temperatura (°C)
  static const double minTemperatura = -60.0;
  static const double maxTemperatura = 60.0;

  // Pressão (Pascals)
  static const double minPressao = 50000.0;
  static const double maxPressao = 110000.0;

  // Gyro Z (°/s)
  static const double minGyroZ = -360.0;
  static const double maxGyroZ = 360.0;

  // Aceleração (g)
  static const double minAccel = -10.0;
  static const double maxAccel = 10.0;

  // ============================================================================
  // MAX DELTA CLAMPS - Per-frame safety limits (legacy, kept for reference)
  // ============================================================================

  static const double maxDeltaVelocidade = 100.0;
  static const double maxDeltaAltitude = 50.0;
  static const double maxDeltaHeading = 180.0;
  static const double maxDeltaPitch = 45.0;
  static const double maxDeltaRoll = 90.0;
  static const double maxDeltaVario = 20.0;
}
