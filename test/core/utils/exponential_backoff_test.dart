import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/core/utils/exponential_backoff.dart';

void main() {
  group('ExponentialBackoff Tests', () {
    late ExponentialBackoff backoff;

    setUp(() {
      backoff = ExponentialBackoff(
        initialDelaySeconds: 1.0,
        multiplier: 1.3,
        maxDelaySeconds: 30.0,
        jitterPercent: 0.0, // Sem jitter para testes determinísticos
      );
    });

    // ==========================================================================
    // TESTES BÁSICOS - DELAYS CRESCENTES
    // ==========================================================================

    test('primeira tentativa deve retornar delay inicial (1s)', () {
      final delay = backoff.getNextDelay();
      
      expect(delay.inMilliseconds, closeTo(1000, 50)); // 1s ±50ms
      expect(backoff.attemptCount, equals(1));
    });

    test('segunda tentativa deve aumentar delay (1.3s)', () {
      backoff.getNextDelay(); // Primeira
      
      final delay = backoff.getNextDelay(); // Segunda
      
      // 1.0 * 1.3 = 1.3s
      expect(delay.inMilliseconds, closeTo(1300, 50));
      expect(backoff.attemptCount, equals(2));
    });

    test('terceira tentativa deve continuar aumentando (1.69s)', () {
      backoff.getNextDelay(); // 1ª
      backoff.getNextDelay(); // 2ª
      
      final delay = backoff.getNextDelay(); // 3ª
      
      // 1.0 * 1.3^2 = 1.69s
      expect(delay.inMilliseconds, closeTo(1690, 50));
      expect(backoff.attemptCount, equals(3));
    });

    test('múltiplas tentativas devem escalar exponencialmente', () {
      final delays = <int>[];
      
      for (int i = 0; i < 5; i++) {
        delays.add(backoff.getNextDelay().inMilliseconds);
      }
      
      // Cada delay deve ser maior que o anterior (antes do cap)
      for (int i = 1; i < delays.length; i++) {
        expect(delays[i], greaterThan(delays[i - 1]));
      }
    });

    // ==========================================================================
    // TESTES CAP (LIMITE MÁXIMO)
    // ==========================================================================

    test('delay deve atingir cap de 30s', () {
      // Fazer muitas tentativas até atingir cap
      for (int i = 0; i < 20; i++) {
        backoff.getNextDelay();
      }
      
      final delay = backoff.getNextDelay();
      
      // Deve estar no cap (30s)
      expect(delay.inSeconds, closeTo(30, 1));
    });

    test('hasReachedCap deve retornar true quando atingir cap', () {
      expect(backoff.hasReachedCap, isFalse);
      
      // Fazer tentativas até cap
      for (int i = 0; i < 15; i++) {
        backoff.getNextDelay();
      }
      
      expect(backoff.hasReachedCap, isTrue);
    });

    test('delay não deve ultrapassar cap mesmo com muitas tentativas', () {
      // 30 tentativas (muito além do cap)
      for (int i = 0; i < 30; i++) {
        final delay = backoff.getNextDelay();
        
        // Nunca deve ultrapassar 30s
        expect(delay.inSeconds, lessThanOrEqualTo(30));
      }
    });

    // ==========================================================================
    // TESTES RESET
    // ==========================================================================

    test('reset deve zerar attemptCount', () {
      backoff.getNextDelay();
      backoff.getNextDelay();
      backoff.getNextDelay();
      
      expect(backoff.attemptCount, equals(3));
      
      backoff.reset();
      
      expect(backoff.attemptCount, equals(0));
    });

    test('após reset, próxima tentativa deve ser delay inicial', () {
      // Fazer várias tentativas
      for (int i = 0; i < 5; i++) {
        backoff.getNextDelay();
      }
      
      backoff.reset();
      
      final delay = backoff.getNextDelay();
      
      // Deve voltar para 1s
      expect(delay.inMilliseconds, closeTo(1000, 50));
      expect(backoff.attemptCount, equals(1));
    });

    test('reset deve desmarcar hasReachedCap', () {
      // Atingir cap
      for (int i = 0; i < 15; i++) {
        backoff.getNextDelay();
      }
      
      expect(backoff.hasReachedCap, isTrue);
      
      backoff.reset();
      
      expect(backoff.hasReachedCap, isFalse);
    });

    // ==========================================================================
    // TESTES COM JITTER
    // ==========================================================================

    test('com jitter, delays devem variar (não determinísticos)', () {
      final backoffWithJitter = ExponentialBackoff(
        initialDelaySeconds: 10.0,
        multiplier: 1.3,
        maxDelaySeconds: 30.0,
        jitterPercent: 0.2, // ±20%
      );
      
      final delays = <int>[];
      
      // Pegar várias tentativas da mesma "rodada"
      for (int i = 0; i < 5; i++) {
        backoffWithJitter.reset();
        delays.add(backoffWithJitter.getNextDelay().inMilliseconds);
      }
      
      // Delays devem ser próximos de 10s mas não idênticos
      for (final delay in delays) {
        expect(delay, inInclusiveRange(8000, 12000)); // 10s ±20%
      }
      
      // Pelo menos 2 valores devem ser diferentes (probabilidade 99.9%)
      final uniqueDelays = delays.toSet();
      expect(uniqueDelays.length, greaterThan(1));
    });

    // ==========================================================================
    // TESTES CONFIGURAÇÕES CUSTOMIZADAS
    // ==========================================================================

    test('custom initial delay deve funcionar', () {
      final customBackoff = ExponentialBackoff(
        initialDelaySeconds: 5.0,
        multiplier: 1.3,
        maxDelaySeconds: 30.0,
        jitterPercent: 0.0,
      );
      
      final delay = customBackoff.getNextDelay();
      
      expect(delay.inMilliseconds, closeTo(5000, 50));
    });

    test('custom multiplier deve funcionar', () {
      final customBackoff = ExponentialBackoff(
        initialDelaySeconds: 1.0,
        multiplier: 2.0, // Dobra a cada tentativa
        maxDelaySeconds: 30.0,
        jitterPercent: 0.0,
      );
      
      final delay1 = customBackoff.getNextDelay(); // 1s
      final delay2 = customBackoff.getNextDelay(); // 2s
      final delay3 = customBackoff.getNextDelay(); // 4s
      
      expect(delay1.inMilliseconds, closeTo(1000, 50));
      expect(delay2.inMilliseconds, closeTo(2000, 50));
      expect(delay3.inMilliseconds, closeTo(4000, 50));
    });

    test('custom max delay deve funcionar', () {
      final customBackoff = ExponentialBackoff(
        initialDelaySeconds: 1.0,
        multiplier: 2.0,
        maxDelaySeconds: 5.0, // Cap baixo
        jitterPercent: 0.0,
      );
      
      // Fazer muitas tentativas
      for (int i = 0; i < 10; i++) {
        final delay = customBackoff.getNextDelay();
        
        // Nunca deve ultrapassar 5s
        expect(delay.inSeconds, lessThanOrEqualTo(5));
      }
    });

    // ==========================================================================
    // EDGE CASES
    // ==========================================================================

    test('delay mínimo deve ser 0.5s mesmo com valores pequenos', () {
      final tinyBackoff = ExponentialBackoff(
        initialDelaySeconds: 0.1,
        multiplier: 1.0,
        maxDelaySeconds: 1.0,
        jitterPercent: 0.0,
      );
      
      final delay = tinyBackoff.getNextDelay();
      
      // Deve respeitar mínimo de 0.5s
      expect(delay.inMilliseconds, greaterThanOrEqualTo(500));
    });

    test('attemptCount deve incrementar corretamente', () {
      expect(backoff.attemptCount, equals(0));
      
      backoff.getNextDelay();
      expect(backoff.attemptCount, equals(1));
      
      backoff.getNextDelay();
      expect(backoff.attemptCount, equals(2));
      
      backoff.getNextDelay();
      expect(backoff.attemptCount, equals(3));
    });

    // ==========================================================================
    // TESTES SEQUÊNCIA REALISTA
    // ==========================================================================

    test('sequência realista de reconnect (AWS-style)', () {
      // Simular padrão AWS: 1s, 1.3s, 1.69s, 2.2s...
      final expectedDelaysMs = [1000, 1300, 1690, 2197, 2856];
      
      for (int i = 0; i < expectedDelaysMs.length; i++) {
        final delay = backoff.getNextDelay();
        
        expect(
          delay.inMilliseconds,
          closeTo(expectedDelaysMs[i], 100),
          reason: 'Tentativa ${i + 1}',
        );
      }
    });
  });
}