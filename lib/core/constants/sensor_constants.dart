/// 📊 CONSTANTS: Constantes de validação de sensores
class SensorConstants {
  // 🌍 GPS: Threshold de precisão mínima (7 casas decimais)
  /// GPS com menos de 7 casas decimais é considerado inválido
  /// Exemplo: 0.0000001 → abs(0.0000001 * 10^7) = 1 < 1000 → INVÁLIDO
  static const int gpsMinPrecision = 1000;
  
  /// Multiplicador para verificar precisão (10^7 para 7 casas decimais)
  static const int gpsPrecisionMultiplier = 10000000;
  
  // 🔧 Pode adicionar outros ranges aqui no futuro
  // static const double altitudeMin = -500.0;
  // static const double altitudeMax = 10000.0;
}