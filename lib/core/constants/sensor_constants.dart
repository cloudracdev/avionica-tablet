/// 📊 CONSTANTS: Constantes de validação de sensores
/// 
/// Define ranges aceitáveis para TODOS os sensores da aeronave
class SensorConstants {
  // 🌍 GPS: Threshold de precisão mínima (7 casas decimais)
  /// GPS com menos de 7 casas decimais é considerado inválido
  /// Exemplo: 0.0000001 → abs(0.0000001 * 10^7) = 1 < 1000 → INVÁLIDO
  static const int gpsMinPrecision = 1000;
  
  /// Multiplicador para verificar precisão (10^7 para 7 casas decimais)
  static const int gpsPrecisionMultiplier = 10000000;
  
  // 🚀 Velocidade (km/h)
  static const double velocidadeMin = 0.0;
  static const double velocidadeMax = 500.0;
  
  // 📏 Altitude (metros)
  static const double altitudeMin = -500.0;   // Mar Morto
  static const double altitudeMax = 10000.0;  // Aviação geral máxima
  
  // 🧭 Heading (graus)
  static const double headingMin = 0.0;
  static const double headingMax = 360.0;
  
  // 📐 Pitch (graus)
  static const double pitchMin = -90.0;
  static const double pitchMax = 90.0;
  
  // 🔄 Roll (graus)
  static const double rollMin = -180.0;
  static const double rollMax = 180.0;
  
  // 📊 Variômetro (m/s)
  static const double varioMin = -30.0;   // Descida máxima
  static const double varioMax = 30.0;    // Subida máxima
  
  // 🌡️ Temperatura (°C)
  static const double temperaturaMin = -50.0;  // Altitude extrema
  static const double temperaturaMax = 60.0;   // Solo extremo
  
  // 🌪️ Pressão (Pa - Pascais)
  static const double pressaoMin = 50000.0;   // ~5.500m altitude
  static const double pressaoMax = 110000.0;  // Nível do mar + margem
  
  // 🎮 Giroscópio Z (°/s)
  static const double gyroZMin = -360.0;
  static const double gyroZMax = 360.0;
  
  // 📈📉 Acelerômetro (g-force)
  static const double accelMin = -5.0;   // Manobras extremas
  static const double accelMax = 5.0;    // Manobras extremas
}