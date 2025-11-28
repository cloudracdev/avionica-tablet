/// Constants for telemetry interpolation system.
class InterpolationConstants {
  InterpolationConstants._();

  // ============================================================================
  // GLOBAL SETTINGS
  // ============================================================================

  static const int targetFps = 60;
  static const double frameDurationMs = 1000.0 / targetFps;
  static const int staleTimeoutMs = 1000;
  static const int maxInterpolationTimeMs = 500;

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
  // 
  // Fórmula damping crítico: damping = 2 * sqrt(stiffness)
  // Usamos OVERDAMPED (damping > crítico) para zero oscilação
  // ============================================================================

  /// Spring stiffness for pitch
  static const double springStiffnessPitch = 15.0;
  /// Overdamped = sem bounce (crítico seria ~7.7)
  static const double springDampingPitch = 12.0;

  /// Spring stiffness for roll
  static const double springStiffnessRoll = 15.0;
  /// Overdamped = sem bounce
  static const double springDampingRoll = 12.0;

  /// Spring stiffness for variometer
  static const double springStiffnessVario = 10.0;
  /// Overdamped
  static const double springDampingVario = 10.0;

  /// Spring stiffness for gyro Z (turn rate)
  static const double springStiffnessGyroZ = 12.0;
  /// Overdamped
  static const double springDampingGyroZ = 10.0;

  /// Spring stiffness for accelerometer
  static const double springStiffnessAccel = 12.0;
  /// Overdamped
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
