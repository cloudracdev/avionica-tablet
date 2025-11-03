import 'dart:math';

class SmoothingService {
  // Valores suavizados atuais
  double _smoothVelocidade = 0;
  double _smoothAltitude = 0;
  double _smoothHeading = 0;
  double _smoothPitch = 0;
  double _smoothRoll = 0;
  double _smoothVario = 0;
  double _smoothTemperatura = 0;
  double _smoothPressao = 0;
  double _smoothLat = 0;
  double _smoothLng = 0;
  double _smoothAccelX = 0;
  double _smoothAccelY = 0;

  // Primeira leitura (não suavizar no início)
  bool _firstReading = true;

  // Aplicar filtro EMA + Dead Zone
  double _smooth(double newValue, double currentSmooth, double alpha, double deadZone) {
    // Dead zone: ignorar variações pequenas
    if ((newValue - currentSmooth).abs() < deadZone) {
      return currentSmooth;
    }
    
    // EMA: suavização exponencial
    return alpha * newValue + (1 - alpha) * currentSmooth;
  }

  // Suavização circular para heading (0-360°)
  double _smoothCircular(double newValue, double currentSmooth, double alpha, double deadZone) {
    // Normalizar valores para 0-360
    while (newValue < 0) newValue += 360;
    while (newValue >= 360) newValue -= 360;
    while (currentSmooth < 0) currentSmooth += 360;
    while (currentSmooth >= 360) currentSmooth -= 360;

    // Calcular diferença considerando a natureza circular
    double diff = newValue - currentSmooth;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    // Dead zone
    if (diff.abs() < deadZone) {
      return currentSmooth;
    }

    // EMA circular
    double result = currentSmooth + alpha * diff;
    
    // Normalizar resultado
    while (result < 0) result += 360;
    while (result >= 360) result -= 360;
    
    return result;
  }

  // Suavizar todos os dados do six-pack
  Map<String, double> smoothData(Map<String, double> rawData) {
    // Na primeira leitura, usar valores diretos
    if (_firstReading) {
      _smoothVelocidade = rawData['velocidade'] ?? 0;
      _smoothAltitude = rawData['altitude'] ?? 0;
      _smoothHeading = rawData['heading'] ?? 0;
      _smoothPitch = rawData['pitch'] ?? 0;
      _smoothRoll = rawData['roll'] ?? 0;
      _smoothVario = rawData['vario'] ?? 0;
      _smoothTemperatura = rawData['temperatura'] ?? 0;
      _smoothPressao = rawData['pressao'] ?? 0;
      _smoothLat = rawData['lat'] ?? 0;
      _smoothLng = rawData['lng'] ?? 0;
      _smoothAccelX = rawData['acel_x'] ?? 0;
      _smoothAccelY = rawData['acel_y'] ?? 0;
      _firstReading = false;
      return rawData;
    }

    // Aplicar filtros com parâmetros específicos para cada dado
    _smoothVelocidade = _smooth(
      rawData['velocidade'] ?? _smoothVelocidade,
      _smoothVelocidade,
      0.15,  // alpha: responsividade
      0.2    // deadZone: ignorar variações < 0.2 km/h
    );

    _smoothAltitude = _smooth(
      rawData['altitude'] ?? _smoothAltitude,
      _smoothAltitude,
      0.5,   // alpha: mais responsivo (importante para voo)
      0.1    // deadZone: ignorar < 0.5m
    );

    _smoothHeading = _smoothCircular(
      rawData['heading'] ?? _smoothHeading,
      _smoothHeading,
      0.15,  // alpha
      0.5    // deadZone: ignorar < 0.5°
    );

    _smoothPitch = _smooth(
      rawData['pitch'] ?? _smoothPitch,
      _smoothPitch,
      0.15,  // alpha
      0.3    // deadZone: ignorar < 0.3°
    );

    _smoothRoll = _smooth(
      rawData['roll'] ?? _smoothRoll,
      _smoothRoll,
      0.15,  // alpha
      0.3    // deadZone: ignorar < 0.3°
    );

    _smoothVario = _smooth(
      rawData['vario'] ?? _smoothVario,
      _smoothVario,
      0.3,   // alpha: mais responsivo (era 0.2) ✅
      0.02   // deadZone: aceita > 0.02 m/s = ~4 ft/min (era 0.1) ✅
    );

    _smoothTemperatura = _smooth(
      rawData['temperatura'] ?? _smoothTemperatura,
      _smoothTemperatura,
      0.1,  // alpha: muito suave (temperatura muda devagar)
      0.1    // deadZone: ignorar < 0.3°C
    );

    _smoothPressao = _smooth(
      rawData['pressao'] ?? _smoothPressao,
      _smoothPressao,
      0.3,   // alpha: suave
      10     // deadZone: ignorar < 50 Pa (~0.5 hPa)
    );

    _smoothLat = _smooth(
      rawData['lat'] ?? _smoothLat,
      _smoothLat,
      0.1,     // alpha: muito suave (GPS)
      0.00001  // deadZone: ~1 metro
    );

    _smoothLng = _smooth(
      rawData['lng'] ?? _smoothLng,
      _smoothLng,
      0.1,     // alpha: muito suave (GPS)
      0.00001  // deadZone: ~1 metro
    );

    _smoothAccelX = _smooth(
      rawData['acel_x'] ?? _smoothAccelX,
      _smoothAccelX,
      0.10,  // alpha: suave para bolinha não tremer
      0.0    // deadZone: sem dead zone, responde a tudo
    );

    _smoothAccelY = _smooth(
      rawData['acel_y'] ?? _smoothAccelY,
      _smoothAccelY,
      0.10,  // alpha: suave para bolinha não tremer
      0.0    // deadZone: sem dead zone, responde a tudo
    );

    // Retornar dados suavizados
    return {
      'velocidade': _smoothVelocidade,
      'altitude': _smoothAltitude,
      'heading': _smoothHeading,
      'pitch': _smoothPitch,
      'roll': _smoothRoll,
      'vario': _smoothVario,
      'temperatura': _smoothTemperatura,
      'pressao': _smoothPressao,
      'lat': _smoothLat,
      'lng': _smoothLng,
      'acel_x': _smoothAccelX,
      'acel_y': _smoothAccelY,
    };
  }

  // Resetar filtro
  void reset() {
    _firstReading = true;
  }
}