import 'dart:math';

/// 🔄 Exponential Backoff - Padrão AWS/Google/Kubernetes
/// 
/// Calcula delays crescentes entre tentativas de reconexão:
/// - Inicial: 1s
/// - Multiplicador: 1.3x
/// - Cap: 30s
/// - Jitter: ±20% (evita thundering herd)
/// - Tentativas: infinitas
class ExponentialBackoff {
  final double _initialDelaySeconds;
  final double _multiplier;
  final double _maxDelaySeconds;
  final double _jitterPercent;
  
  int _attemptCount = 0;
  final Random _random = Random();

  ExponentialBackoff({
    double initialDelaySeconds = 1.0,
    double multiplier = 1.3,
    double maxDelaySeconds = 30.0,
    double jitterPercent = 0.2,
  })  : _initialDelaySeconds = initialDelaySeconds,
        _multiplier = multiplier,
        _maxDelaySeconds = maxDelaySeconds,
        _jitterPercent = jitterPercent;

  /// 🎲 Calcula próximo delay com jitter
  Duration getNextDelay() {
    _attemptCount++;
    
    // Calcula delay base exponencial
    double baseDelay = _initialDelaySeconds * pow(_multiplier, _attemptCount - 1);
    
    // Aplica cap
    baseDelay = min(baseDelay, _maxDelaySeconds);
    
    // Aplica jitter (±20%)
    double jitter = baseDelay * _jitterPercent * (2 * _random.nextDouble() - 1);
    double finalDelay = baseDelay + jitter;
    
    // Garante mínimo de 0.5s
    finalDelay = max(finalDelay, 0.5);
    
    return Duration(milliseconds: (finalDelay * 1000).round());
  }

  /// ♻️ Reseta contador (quando reconexão é bem-sucedida)
  void reset() {
    _attemptCount = 0;
  }

  /// 📊 Getters
  int get attemptCount => _attemptCount;
  
  bool get hasReachedCap {
    double baseDelay = _initialDelaySeconds * pow(_multiplier, _attemptCount - 1);
    return baseDelay >= _maxDelaySeconds;
  }
}