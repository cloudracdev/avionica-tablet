/// 📊 Model: Dados de telemetria processados
/// 
/// Representa todos os dados de voo após suavização e calibração
class TelemetryData {
  // 🛩️ Instrumentos principais
  final double velocidade;      // km/h
  final double altitude;        // metros
  final double heading;         // 0-360°
  final double pitch;           // graus
  final double roll;            // graus
  final double vario;           // m/s
  
  // 🌡️ Ambiente
  final double temperatura;     // °C
  final double pressao;         // Pa
  
  // 🗺️ GPS
  final double lat;
  final double lng;
  
  // 🎮 Coordenador de curva
  final double gyroZ;           // °/s
  final double accelX;          // g
  final double accelY;          // g
  
  // ⏱️ Timestamp
  final DateTime timestamp;

  const TelemetryData({
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
  });

  /// 🏭 Factory: Cria estado inicial (zeros)
  factory TelemetryData.initial() {
    return TelemetryData(
      velocidade: 0,
      altitude: 0,
      heading: 0,
      pitch: 0,
      roll: 0,
      vario: 0,
      temperatura: 0,
      pressao: 101325, // 1013.25 hPa (padrão ao nível do mar)
      lat: 0,
      lng: 0,
      gyroZ: 0,
      accelX: 0,
      accelY: 0,
      timestamp: DateTime.now(),
    );
  }

  /// 📋 CopyWith para atualizações imutáveis
  TelemetryData copyWith({
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
  }) {
    return TelemetryData(
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
    );
  }
}