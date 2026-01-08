/// 📦 TELEMETRY POINT ENTITY
///
/// Representa 1 linha da tabela telemetry_points no SQLite
///
/// Responsabilidades:
/// - Conversão Map ↔ Object
/// - Conversão TelemetryData → Entity
/// - Validações de dados
/// - Immutable model

import '../../../models/telemetry_data.dart';

class TelemetryPointEntity {
  // 🔑 Identificação
  final int? id;
  final String flightSessionId;
  final int timestamp;

  // �� GPS
  final double lat;
  final double lng;
  final double? gpsAltitude;
  final double? gpsSpeed;
  final double? gpsHeading;
  final int? gpsSatellites;
  final double? gpsHdop;

  // 📏 Barômetro
  final double? baroAltitude;
  final double? baroPressure;
  final double? baroTemperature;

  // 🧭 Compass/Magnetometer
  final double? magHeading;
  final double? magX;
  final double? magY;
  final double? magZ;

  // 📐 Acelerômetro
  final double? accelX;
  final double? accelY;
  final double? accelZ;

  // 🔄 Giroscópio
  final double? gyroX;
  final double? gyroY;
  final double? gyroZ;

  // 🎯 IMU
  final double? imuPitch;
  final double? imuRoll;
  final double? imuYaw;

  // 📊 Dados Calculados
  final double? velocity;
  final double? altitude;
  final double? heading;
  final double? verticalSpeed;

  // 🔧 Quality Indicators
  final String dataQuality;
  final String? sensorStatus;
  final String? rawJson;

  const TelemetryPointEntity({
    this.id,
    required this.flightSessionId,
    required this.timestamp,
    required this.lat,
    required this.lng,
    this.gpsAltitude,
    this.gpsSpeed,
    this.gpsHeading,
    this.gpsSatellites,
    this.gpsHdop,
    this.baroAltitude,
    this.baroPressure,
    this.baroTemperature,
    this.magHeading,
    this.magX,
    this.magY,
    this.magZ,
    this.accelX,
    this.accelY,
    this.accelZ,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    this.imuPitch,
    this.imuRoll,
    this.imuYaw,
    this.velocity,
    this.altitude,
    this.heading,
    this.verticalSpeed,
    this.dataQuality = 'valid',
    this.sensorStatus,
    this.rawJson,
  });

  factory TelemetryPointEntity.fromTelemetryData(
    TelemetryData data,
    String flightSessionId,
  ) {
    return TelemetryPointEntity(
      flightSessionId: flightSessionId,
      timestamp: data.timestamp.millisecondsSinceEpoch,
      lat: data.lat,
      lng: data.lng,
      gpsSpeed: data.velocidade,
      gpsHeading: data.heading,
      baroAltitude: data.altitude,
      baroPressure: data.pressao,
      baroTemperature: data.temperatura,
      magHeading: data.heading,
      accelX: data.accelX,
      accelY: data.accelY,
      gyroZ: data.gyroZ,
      imuPitch: data.pitch,
      imuRoll: data.roll,
      velocity: data.velocidade,
      altitude: data.altitude,
      heading: data.heading,
      verticalSpeed: data.vario,
      dataQuality: data.gpsValid ? 'valid' : 'fallback',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flight_session_id': flightSessionId,
      'timestamp': timestamp,
      'lat': lat,
      'lng': lng,
      'gps_altitude': gpsAltitude,
      'gps_speed': gpsSpeed,
      'gps_heading': gpsHeading,
      'gps_satellites': gpsSatellites,
      'gps_hdop': gpsHdop,
      'baro_altitude': baroAltitude,
      'baro_pressure': baroPressure,
      'baro_temperature': baroTemperature,
      'mag_heading': magHeading,
      'mag_x': magX,
      'mag_y': magY,
      'mag_z': magZ,
      'accel_x': accelX,
      'accel_y': accelY,
      'accel_z': accelZ,
      'gyro_x': gyroX,
      'gyro_y': gyroY,
      'gyro_z': gyroZ,
      'imu_pitch': imuPitch,
      'imu_roll': imuRoll,
      'imu_yaw': imuYaw,
      'velocity': velocity,
      'altitude': altitude,
      'heading': heading,
      'vertical_speed': verticalSpeed,
      'data_quality': dataQuality,
      'sensor_status': sensorStatus,
      'raw_json': rawJson,
    };
  }

  factory TelemetryPointEntity.fromMap(Map<String, dynamic> map) {
    return TelemetryPointEntity(
      id: map['id'] as int?,
      flightSessionId: map['flight_session_id'] as String,
      timestamp: map['timestamp'] as int,
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      gpsAltitude: (map['gps_altitude'] as num?)?.toDouble(),
      gpsSpeed: (map['gps_speed'] as num?)?.toDouble(),
      gpsHeading: (map['gps_heading'] as num?)?.toDouble(),
      gpsSatellites: map['gps_satellites'] as int?,
      gpsHdop: (map['gps_hdop'] as num?)?.toDouble(),
      baroAltitude: (map['baro_altitude'] as num?)?.toDouble(),
      baroPressure: (map['baro_pressure'] as num?)?.toDouble(),
      baroTemperature: (map['baro_temperature'] as num?)?.toDouble(),
      magHeading: (map['mag_heading'] as num?)?.toDouble(),
      magX: (map['mag_x'] as num?)?.toDouble(),
      magY: (map['mag_y'] as num?)?.toDouble(),
      magZ: (map['mag_z'] as num?)?.toDouble(),
      accelX: (map['accel_x'] as num?)?.toDouble(),
      accelY: (map['accel_y'] as num?)?.toDouble(),
      accelZ: (map['accel_z'] as num?)?.toDouble(),
      gyroX: (map['gyro_x'] as num?)?.toDouble(),
      gyroY: (map['gyro_y'] as num?)?.toDouble(),
      gyroZ: (map['gyro_z'] as num?)?.toDouble(),
      imuPitch: (map['imu_pitch'] as num?)?.toDouble(),
      imuRoll: (map['imu_roll'] as num?)?.toDouble(),
      imuYaw: (map['imu_yaw'] as num?)?.toDouble(),
      velocity: (map['velocity'] as num?)?.toDouble(),
      altitude: (map['altitude'] as num?)?.toDouble(),
      heading: (map['heading'] as num?)?.toDouble(),
      verticalSpeed: (map['vertical_speed'] as num?)?.toDouble(),
      dataQuality: map['data_quality'] as String? ?? 'valid',
      sensorStatus: map['sensor_status'] as String?,
      rawJson: map['raw_json'] as String?,
    );
  }

  TelemetryData toTelemetryData() {
    return TelemetryData(
      velocidade: velocity ?? 0.0,
      altitude: altitude ?? 0.0,
      heading: heading ?? 0.0,
      pitch: imuPitch ?? 0.0,
      roll: imuRoll ?? 0.0,
      vario: verticalSpeed ?? 0.0,
      temperatura: baroTemperature ?? 0.0,
      pressao: baroPressure ?? 101325.0,
      lat: lat,
      lng: lng,
      gyroZ: gyroZ ?? 0.0,
      accelX: accelX ?? 0.0,
      accelY: accelY ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      gpsValid: dataQuality == 'valid',
    );
  }

  bool isValid() => validate().isEmpty;

  List<String> validate() {
    final errors = <String>[];
    if (flightSessionId.isEmpty) errors.add('flightSessionId não pode ser vazio');
    if (timestamp <= 0) errors.add('timestamp deve ser maior que zero');
    if (lat < -90 || lat > 90) errors.add('lat deve estar entre -90 e 90');
    if (lng < -180 || lng > 180) errors.add('lng deve estar entre -180 e 180');
    final validQualities = ['valid', 'interpolated', 'fallback', 'invalid'];
    if (!validQualities.contains(dataQuality)) errors.add('dataQuality inválido: $dataQuality');
    return errors;
  }

  TelemetryPointEntity copyWith({
    int? id,
    String? flightSessionId,
    int? timestamp,
    double? lat,
    double? lng,
    double? gpsAltitude,
    double? gpsSpeed,
    double? gpsHeading,
    int? gpsSatellites,
    double? gpsHdop,
    double? baroAltitude,
    double? baroPressure,
    double? baroTemperature,
    double? magHeading,
    double? magX,
    double? magY,
    double? magZ,
    double? accelX,
    double? accelY,
    double? accelZ,
    double? gyroX,
    double? gyroY,
    double? gyroZ,
    double? imuPitch,
    double? imuRoll,
    double? imuYaw,
    double? velocity,
    double? altitude,
    double? heading,
    double? verticalSpeed,
    String? dataQuality,
    String? sensorStatus,
    String? rawJson,
  }) {
    return TelemetryPointEntity(
      id: id ?? this.id,
      flightSessionId: flightSessionId ?? this.flightSessionId,
      timestamp: timestamp ?? this.timestamp,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      gpsAltitude: gpsAltitude ?? this.gpsAltitude,
      gpsSpeed: gpsSpeed ?? this.gpsSpeed,
      gpsHeading: gpsHeading ?? this.gpsHeading,
      gpsSatellites: gpsSatellites ?? this.gpsSatellites,
      gpsHdop: gpsHdop ?? this.gpsHdop,
      baroAltitude: baroAltitude ?? this.baroAltitude,
      baroPressure: baroPressure ?? this.baroPressure,
      baroTemperature: baroTemperature ?? this.baroTemperature,
      magHeading: magHeading ?? this.magHeading,
      magX: magX ?? this.magX,
      magY: magY ?? this.magY,
      magZ: magZ ?? this.magZ,
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      accelZ: accelZ ?? this.accelZ,
      gyroX: gyroX ?? this.gyroX,
      gyroY: gyroY ?? this.gyroY,
      gyroZ: gyroZ ?? this.gyroZ,
      imuPitch: imuPitch ?? this.imuPitch,
      imuRoll: imuRoll ?? this.imuRoll,
      imuYaw: imuYaw ?? this.imuYaw,
      velocity: velocity ?? this.velocity,
      altitude: altitude ?? this.altitude,
      heading: heading ?? this.heading,
      verticalSpeed: verticalSpeed ?? this.verticalSpeed,
      dataQuality: dataQuality ?? this.dataQuality,
      sensorStatus: sensorStatus ?? this.sensorStatus,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  @override
  String toString() => 'TelemetryPointEntity(id: $id, flight: $flightSessionId, ts: $timestamp, lat: ${lat.toStringAsFixed(6)}, lng: ${lng.toStringAsFixed(6)}, quality: $dataQuality)';

  @override
  bool operator ==(Object other) => identical(this, other) || other is TelemetryPointEntity && other.id == id && other.flightSessionId == flightSessionId && other.timestamp == timestamp;

  @override
  int get hashCode => Object.hash(id, flightSessionId, timestamp);
}
