/// 📊 Model: Estatísticas do voo
/// 
/// Armazena valores máximos, mínimos e duração do voo
class FlightStats {
  // ⏱️ Tempo
  final DateTime startTime;
  final Duration duration;
  
  // 🚀 Velocidade
  final double velocidadeMax;
  
  // 🏔️ Altitude
  final double altitudeMax;
  
  // ✈️ Atitude
  final double pitchMax;
  final double pitchMin;
  final double rollMax;
  final double rollMin;
  
  // 📈 Variômetro
  final double varioMax;
  final double varioMin;
  
  // 🌡️ Temperatura
  final double temperaturaMax;
  final double temperaturaMin;

  const FlightStats({
    required this.startTime,
    required this.duration,
    required this.velocidadeMax,
    required this.altitudeMax,
    required this.pitchMax,
    required this.pitchMin,
    required this.rollMax,
    required this.rollMin,
    required this.varioMax,
    required this.varioMin,
    required this.temperaturaMax,
    required this.temperaturaMin,
  });

  /// 🏭 Factory: Estado inicial
  factory FlightStats.initial() {
    final now = DateTime.now();
    return FlightStats(
      startTime: now,
      duration: Duration.zero,
      velocidadeMax: 0,
      altitudeMax: 0,
      pitchMax: 0,
      pitchMin: 0,
      rollMax: 0,
      rollMin: 0,
      varioMax: 0,
      varioMin: 0,
      temperaturaMax: -999,
      temperaturaMin: 999,
    );
  }

  /// 📋 CopyWith para atualizações
  FlightStats copyWith({
    DateTime? startTime,
    Duration? duration,
    double? velocidadeMax,
    double? altitudeMax,
    double? pitchMax,
    double? pitchMin,
    double? rollMax,
    double? rollMin,
    double? varioMax,
    double? varioMin,
    double? temperaturaMax,
    double? temperaturaMin,
  }) {
    return FlightStats(
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      velocidadeMax: velocidadeMax ?? this.velocidadeMax,
      altitudeMax: altitudeMax ?? this.altitudeMax,
      pitchMax: pitchMax ?? this.pitchMax,
      pitchMin: pitchMin ?? this.pitchMin,
      rollMax: rollMax ?? this.rollMax,
      rollMin: rollMin ?? this.rollMin,
      varioMax: varioMax ?? this.varioMax,
      varioMin: varioMin ?? this.varioMin,
      temperaturaMax: temperaturaMax ?? this.temperaturaMax,
      temperaturaMin: temperaturaMin ?? this.temperaturaMin,
    );
  }

  /// 🔄 Reset (novo voo)
  FlightStats reset() {
    return FlightStats.initial();
  }
}