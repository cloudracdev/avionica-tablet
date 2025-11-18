/// Immutable data model representing all flight instrument data.
///
/// This model contains all sensor readings from the ESP32 and serves as
/// the single source of truth for flight data throughout the application.
///
/// Replaces the old Map<String, double> approach with type-safe properties.
class FlightData {
  /// Airspeed in km/h
  final double velocidade;

  /// Altitude in meters (AGL or MSL depending on calibration).
  final double altitude;

  /// Magnetic heading in degrees (0-360)
  final double heading;

  /// Pitch angle in degrees (-90 to +90)
  final double pitch;

  /// Roll angle in degrees (-180 to +180)
  final double roll;

  /// Vertical speed in m/s (positive = climbing)
  final double vario;

  /// Temperature in Celsius
  final double temperatura;

  /// Barometric pressure in Pascals
  final double pressao;

  /// GPS latitude in degrees
  final double lat;

  /// GPS longitude in degrees
  final double lng;

  /// Z-axis gyroscope in °/s (turn rate)
  final double gyroZ;

  /// X-axis acceleration in g-force
  final double accelX;

  /// Y-axis acceleration in g-force
  final double accelY;

  /// Timestamp when this data was captured
  final DateTime timestamp;

  /// GPS validity flag (true = valid signal, false = invalid/no signal)
  /// 
  /// GPS is considered invalid if coordinates have less than 7 decimal places
  /// precision (e.g., 0.0, 0.0 or 0.0000001, 0.0000001)
  final bool gpsValid;

  /// Creates a new FlightData instance.
  const FlightData({
    required this.velocidade,
    required this.altitude,
    required this.heading,
    required this.pitch,
    required this.roll,
    required this.vario,
    required this.temperatura,
    required this.pressao,
    required this.lat,
    required this.lng,
    required this.gyroZ,
    required this.accelX,
    required this.accelY,
    required this.timestamp,
    this.gpsValid = true, // Default: assume GPS is valid
  });

  /// Creates FlightData with all values set to zero.
  ///
  /// Useful for initialization or when no sensor data is available.
  factory FlightData.zero() {
    return FlightData(
      velocidade: 0.0,
      altitude: 0.0,
      heading: 0.0,
      pitch: 0.0,
      roll: 0.0,
      vario: 0.0,
      temperatura: 0.0,
      pressao: 0.0,
      lat: 0.0,
      lng: 0.0,
      gyroZ: 0.0,
      accelX: 0.0,
      accelY: 0.0,
      timestamp: DateTime.now(),
      gpsValid: false, // Zero data = invalid GPS
    );
  }

  /// Creates FlightData from a Map (for backward compatibility).
  ///
  /// Expected format from ESP32 WebSocket or smoothing service:
  /// ```dart
  /// {
  ///   'velocidade': 120.5,
  ///   'altitude': 1500.0,
  ///   'heading': 270.0,
  ///   'pitch': 5.0,
  ///   'roll': -3.0,
  ///   'vario': 2.5,
  ///   'temperatura': 15.0,
  ///   'pressao': 101325.0,
  ///   'lat': -25.4284,
  ///   'lng': -49.2733,
  ///   'lsm_gz': 0.0,
  ///   'acel_x': 0.1,
  ///   'acel_y': -0.05,
  /// }
  /// ```
  factory FlightData.fromMap(Map<String, double> map) {
    return FlightData(
      velocidade: map['velocidade'] ?? 0.0,
      altitude: map['altitude'] ?? 0.0,
      heading: map['heading'] ?? 0.0,
      pitch: map['pitch'] ?? 0.0,
      roll: map['roll'] ?? 0.0,
      vario: map['vario'] ?? 0.0,
      temperatura: map['temperatura'] ?? 0.0,
      pressao: map['pressao'] ?? 0.0,
      lat: map['lat'] ?? 0.0,
      lng: map['lng'] ?? 0.0,
      gyroZ: map['lsm_gz'] ?? 0.0,
      accelX: map['acel_x'] ?? 0.0,
      accelY: map['acel_y'] ?? 0.0,
      timestamp: DateTime.now(),
      gpsValid: true, // Will be validated in repository
    );
  }

  /// Converts this FlightData to a Map (for backward compatibility).
  Map<String, double> toMap() {
    return {
      'velocidade': velocidade,
      'altitude': altitude,
      'heading': heading,
      'pitch': pitch,
      'roll': roll,
      'vario': vario,
      'temperatura': temperatura,
      'pressao': pressao,
      'lat': lat,
      'lng': lng,
      'lsm_gz': gyroZ,
      'acel_x': accelX,
      'acel_y': accelY,
    };
  }

  /// Creates a copy of this FlightData with specified fields replaced.
  ///
  /// Enables immutable updates while preserving other values.
  FlightData copyWith({
    double? velocidade,
    double? altitude,
    double? heading,
    double? pitch,
    double? roll,
    double? vario,
    double? temperatura,
    double? pressao,
    double? lat,
    double? lng,
    double? gyroZ,
    double? accelX,
    double? accelY,
    DateTime? timestamp,
    bool? gpsValid,
  }) {
    return FlightData(
      velocidade: velocidade ?? this.velocidade,
      altitude: altitude ?? this.altitude,
      heading: heading ?? this.heading,
      pitch: pitch ?? this.pitch,
      roll: roll ?? this.roll,
      vario: vario ?? this.vario,
      temperatura: temperatura ?? this.temperatura,
      pressao: pressao ?? this.pressao,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      gyroZ: gyroZ ?? this.gyroZ,
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      timestamp: timestamp ?? this.timestamp,
      gpsValid: gpsValid ?? this.gpsValid,
    );
  }

  @override
  String toString() {
    return 'FlightData('
        'velocidade: ${velocidade.toStringAsFixed(1)} km/h, '
        'altitude: ${altitude.toStringAsFixed(1)} m, '
        'heading: ${heading.toStringAsFixed(0)}°, '
        'pitch: ${pitch.toStringAsFixed(1)}°, '
        'roll: ${roll.toStringAsFixed(1)}°, '
        'vario: ${vario.toStringAsFixed(2)} m/s, '
        'gpsValid: $gpsValid'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlightData &&
        other.velocidade == velocidade &&
        other.altitude == altitude &&
        other.heading == heading &&
        other.pitch == pitch &&
        other.roll == roll &&
        other.vario == vario &&
        other.temperatura == temperatura &&
        other.pressao == pressao &&
        other.lat == lat &&
        other.lng == lng &&
        other.gyroZ == gyroZ &&
        other.accelX == accelX &&
        other.accelY == accelY &&
        other.gpsValid == gpsValid;
  }

  @override
  int get hashCode {
    return Object.hash(
      velocidade,
      altitude,
      heading,
      pitch,
      roll,
      vario,
      temperatura,
      pressao,
      lat,
      lng,
      gyroZ,
      accelX,
      accelY,
      gpsValid,
    );
  }
}