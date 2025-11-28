/// Constants for telemetry interpolation system.
class InterpolationConstants {
  InterpolationConstants._();

  // ============================================================================
  // GLOBAL SETTINGS
  // ============================================================================

  static const int targetFps = 60;
  static const double frameDurationMs = 1000.0 / targetFps;
  
  /// Timeout para considerar dados "stale" (sem sinal)
  /// 3 segundos = ~9-12 pacotes perdidos consecutivos (tolerante a glitches)
  static const int staleTimeoutMs = 3000;
  
  /// Tempo máximo interpolando sem dados novos
  /// Após isso, congela no último valor (não extrapola)
  static const int maxInterpolationTimeMs = 2000;

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
  // MAX DELTA CLAMPS - Safety limits
  // ============================================================================

  static const double maxDeltaVelocidade = 100.0;
  static const double maxDeltaAltitude = 50.0;
  static const double maxDeltaHeading = 180.0;
  static const double maxDeltaPitch = 45.0;
  static const double maxDeltaRoll = 90.0;
  static const double maxDeltaVario = 20.0;
}
