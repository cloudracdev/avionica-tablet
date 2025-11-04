/// Physical dimensions and visual properties for flight instruments.
///
/// Defines sizes, scales, and appearance constants used across all instrument
/// widgets in the QFLY system.
class InstrumentConstants {
  InstrumentConstants._(); // Prevent instantiation

  // ==========================================================================
  // ARTIFICIAL HORIZON
  // ==========================================================================

  /// Pixels per degree of pitch movement
  /// 
  /// Higher value = more sensitive pitch display
  /// 3.0 pixels per degree provides good visual feedback
  static const double horizonPitchScale = 3.0;

  /// Relative radius of the horizon instrument (0.0 - 1.0)
  static const double horizonRadius = 1.0;

  /// Width of the horizon line in pixels
  static const double horizonLineWidth = 3.0;

  /// Size of pitch scale numbers
  static const double horizonPitchFontSize = 12.0;

  /// Interval between pitch scale marks (degrees)
  static const int horizonPitchInterval = 10;

  /// Wingspan of the airplane symbol (relative to radius)
  /// 
  /// 0.5 = 50% of instrument radius
  static const double horizonAirplaneWingspan = 0.5;

  /// Fuselage width of airplane symbol (relative to radius)
  static const double horizonAirplaneFuselageWidth = 0.06;

  /// Fuselage height of airplane symbol (relative to radius)
  static const double horizonAirplaneFuselageHeight = 0.18;

  /// Tail width of airplane symbol (relative to radius)
  static const double horizonAirplaneTailWidth = 0.18;

  /// Airplane stroke width
  static const double horizonAirplaneStrokeWidth = 4.0;

  /// Airplane center dot radius (relative to radius)
  static const double horizonAirplaneCenterRadius = 0.04;

  /// Major roll mark length (relative to radius)
  /// 
  /// Used for 0°, 30°, 60° marks
  static const double horizonRollMarkMajorLength = 0.85;

  /// Minor roll mark length (relative to radius)
  /// 
  /// Used for 10°, 20°, 45° marks
  static const double horizonRollMarkMinorLength = 0.90;

  /// Roll mark outer position (relative to radius)
  static const double horizonRollMarkOuterPosition = 0.95;

  /// Roll indicator triangle size
  static const double horizonRollTriangleSize = 6.0;

  /// Roll indicator triangle position (relative to radius)
  static const double horizonRollTrianglePosition = 0.80;

  // ==========================================================================
  // TURN COORDINATOR / COORDENADOR
  // ==========================================================================

  /// Sensitivity of the inclinometer ball (g-force to display ratio)
  /// 
  /// 1.0 = 1g lateral force = full deflection
  static const double coordenadorBallSensitivity = 1.0;

  /// Maximum offset for the inclinometer ball (relative to radius)
  /// 
  /// 0.3 = ball moves ±30% of instrument radius
  static const double coordenadorBallMaxOffset = 0.3;

  /// Inclinometer ball radius (relative to instrument radius)
  static const double coordenadorBallRadius = 0.08;

  /// Inclinometer track width (relative to radius)
  static const double coordenadorTrackWidth = 0.8;

  /// Inclinometer track height (relative to radius)
  static const double coordenadorTrackHeight = 0.15;

  /// Inclinometer track vertical position (relative to radius)
  static const double coordenadorTrackVerticalPosition = 0.55;

  /// Inclinometer track corner radius
  static const double coordenadorTrackCornerRadius = 10.0;

  /// Reference mark spacing from center (relative to radius)
  static const double coordenadorReferenceMarkSpacing = 0.15;

  /// Reference mark vertical start (relative to radius)
  static const double coordenadorReferenceMarkStart = 0.47;

  /// Reference mark vertical end (relative to radius)
  static const double coordenadorReferenceMarkEnd = 0.63;

  /// Reference mark stroke width
  static const double coordenadorReferenceMarkStrokeWidth = 2.0;

  /// Airplane symbol wingspan (relative to radius)
  static const double coordenadorAirplaneWingspan = 0.5;

  /// Airplane symbol fuselage width (relative to radius)
  static const double coordenadorAirplaneFuselageWidth = 0.06;

  /// Airplane symbol fuselage height (relative to radius)
  static const double coordenadorAirplaneFuselageHeight = 0.18;

  /// Airplane symbol tail width (relative to radius)
  static const double coordenadorAirplaneTailWidth = 0.18;

  /// Airplane symbol stroke width
  static const double coordenadorAirplaneStrokeWidth = 4.0;

  /// Airplane symbol center radius (relative to radius)
  static const double coordenadorAirplaneCenterRadius = 0.04;

  /// Horizon reference line width (relative to radius)
  static const double coordenadorHorizonLineWidth = 0.6;

  /// Diagonal reference line angle (degrees)
  static const double coordenadorDiagonalReferenceAngle = 30.0;

  /// Diagonal reference line inner position (relative to radius)
  static const double coordenadorDiagonalReferenceInnerPosition = 0.5;

  /// Diagonal reference line outer position (relative to radius)
  static const double coordenadorDiagonalReferenceOuterPosition = 0.6;

  /// Standard rate turn mark width (relative to radius)
  static const double coordenadorStandardRateMarkWidth = 0.08;

  /// Standard rate turn mark position (relative to radius)
  static const double coordenadorStandardRateMarkPosition = 0.65;

  /// Standard rate turn mark stroke width
  static const double coordenadorStandardRateMarkStrokeWidth = 3.0;

  /// L/R text position horizontal offset (relative to radius)
  static const double coordenadorTextHorizontalOffset = 0.78;

  /// L/R text position vertical offset (relative to radius)
  static const double coordenadorTextVerticalOffset = 0.12;

  /// L/R text font size
  static const double coordenadorTextFontSize = 16.0;

  // ==========================================================================
  // COMMON INSTRUMENT PROPERTIES
  // ==========================================================================

  /// Standard border width for instrument containers
  static const double instrumentBorderWidth = 2.0;

  /// Standard border radius for instrument containers
  static const double instrumentBorderRadius = 12.0;

  /// Standard margin around instrument containers
  static const double instrumentMargin = 4.0;

  /// Standard padding inside instrument containers
  static const double instrumentPadding = 4.0;

  /// Font size for instrument titles
  static const double instrumentTitleFontSize = 12.0;

  /// Font size for instrument value displays
  static const double instrumentValueFontSize = 10.0;

  /// Letter spacing for instrument titles
  static const double instrumentTitleLetterSpacing = 1.2;
}