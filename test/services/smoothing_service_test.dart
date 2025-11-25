import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/services/data_processing/smoothing_service.dart';

void main() {
  group('SmoothingService - Testes Expandidos', () {
    late SmoothingService service;

    setUp(() {
      service = SmoothingService();
    });

    // ==========================================================================
    // TESTES EXISTENTES (mantidos)
    // ==========================================================================
    
    test('deve retornar dados válidos', () {
      final rawData = {
        'altitude': 1000.0,
        'velocidade': 120.0,
        'heading': 270.0,
      };
      
      final result = service.smoothData(rawData);
      
      expect(result['altitude'], isNotNull);
      expect(result['velocidade'], isNotNull);
      expect(result['heading'], isNotNull);
    });

    test('reset deve permitir nova primeira leitura', () {
      service.smoothData({'altitude': 1000.0});
      service.reset();
      
      final result = service.smoothData({'altitude': 2000.0});
      
      expect(result['altitude'], equals(2000.0));
    });

    // ==========================================================================
    // NOVOS TESTES - EMA ALGORITHM (ALPHAS REAIS)
    // ==========================================================================

    test('primeira leitura deve retornar valor bruto (sem suavização)', () {
      final result = service.smoothData({
        'velocidade': 150.0,
        'altitude': 1500.0,
        'heading': 180.0,
      });
      
      expect(result['velocidade'], equals(150.0));
      expect(result['altitude'], equals(1500.0));
      expect(result['heading'], equals(180.0));
    });

    test('segunda leitura deve aplicar EMA - velocidade (alpha=0.4)', () {
      service.smoothData({'velocidade': 100.0});
      final result = service.smoothData({'velocidade': 200.0});
      
      // EMA: 0.4 * 200 + 0.6 * 100 = 80 + 60 = 140
      expect(result['velocidade'], closeTo(140.0, 0.1));
    });

    test('segunda leitura deve aplicar EMA - altitude (alpha=0.3)', () {
      service.smoothData({'altitude': 1000.0});
      final result = service.smoothData({'altitude': 2000.0});
      
      // EMA: 0.3 * 2000 + 0.7 * 1000 = 600 + 700 = 1300
      expect(result['altitude'], closeTo(1300.0, 0.1));
    });

    test('terceira leitura deve continuar suavizando progressivamente', () {
      service.smoothData({'velocidade': 100.0});
      service.smoothData({'velocidade': 200.0}); // t1: 140
      final result = service.smoothData({'velocidade': 100.0});
      
      // t2 = 0.4 * 100 + 0.6 * 140 = 40 + 84 = 124
      expect(result['velocidade'], closeTo(124.0, 0.5));
    });

    // ==========================================================================
    // DEAD ZONE TESTS (VALORES REAIS: 0.5)
    // ==========================================================================

    test('dead zone deve ignorar mudanças pequenas - altitude', () {
      service.smoothData({'altitude': 1000.0});
      
      // Mudança de 0.3m (< 0.5m dead zone)
      final result = service.smoothData({'altitude': 1000.3});
      
      expect(result['altitude'], equals(1000.0));
    });

    test('dead zone deve aceitar mudanças grandes - altitude', () {
      service.smoothData({'altitude': 1000.0});
      
      // Mudança de 10m (> 0.5m dead zone)
      final result = service.smoothData({'altitude': 1010.0});
      
      // EMA: 0.3 * 1010 + 0.7 * 1000 = 303 + 700 = 1003
      expect(result['altitude'], closeTo(1003.0, 0.1));
    });

    test('dead zone deve ignorar mudanças pequenas - velocidade', () {
      service.smoothData({'velocidade': 120.0});
      
      // Mudança de 0.3 km/h (< 0.5 km/h dead zone)
      final result = service.smoothData({'velocidade': 120.3});
      
      expect(result['velocidade'], equals(120.0));
    });

    test('dead zone deve aceitar mudanças grandes - velocidade', () {
      service.smoothData({'velocidade': 120.0});
      
      // Mudança de 20 km/h (> 0.5 km/h dead zone)
      final result = service.smoothData({'velocidade': 140.0});
      
      // EMA: 0.4 * 140 + 0.6 * 120 = 56 + 72 = 128
      expect(result['velocidade'], closeTo(128.0, 0.1));
    });

    // ==========================================================================
    // CIRCULAR SMOOTHING (HEADING - ALPHA=0.5)
    // ==========================================================================

    test('heading circular - mudança normal 90° → 120°', () {
      service.smoothData({'heading': 90.0});
      final result = service.smoothData({'heading': 120.0});
      
      // EMA circular: 90 + 0.5 * 30 = 105
      expect(result['heading'], closeTo(105.0, 0.5));
    });

    test('heading circular - wrap around 350° → 10°', () {
      service.smoothData({'heading': 350.0});
      final result = service.smoothData({'heading': 10.0});
      
      // Diferença circular: +20°
      // EMA: 350 + 0.5 * 20 = 360 → normaliza para 0
      expect(result['heading'], closeTo(0.0, 1.0));
    });

    test('heading circular - wrap around 10° → 350°', () {
      service.smoothData({'heading': 10.0});
      final result = service.smoothData({'heading': 350.0});
      
      // Diferença circular: -20°
      // EMA: 10 + 0.5 * (-20) = 0
      expect(result['heading'], closeTo(0.0, 1.0));
    });

    test('heading dead zone - ignora mudanças < 1.0°', () {
      service.smoothData({'heading': 180.0});
      
      // Mudança de 0.5° (< 1.0° dead zone)
      final result = service.smoothData({'heading': 180.5});
      
      expect(result['heading'], equals(180.0));
    });

    // ==========================================================================
    // MÚLTIPLOS CAMPOS INDEPENDENTES
    // ==========================================================================

    test('múltiplos campos devem ser suavizados independentemente', () {
      service.smoothData({
        'velocidade': 100.0,
        'altitude': 1000.0,
        'heading': 90.0,
        'pitch': 5.0,
        'roll': -3.0,
      });
      
      final result = service.smoothData({
        'velocidade': 200.0,
        'altitude': 2000.0,
        'heading': 180.0,
        'pitch': 10.0,
        'roll': 3.0,
      });
      
      // Cada campo usa seu próprio alpha REAL
      expect(result['velocidade'], closeTo(140.0, 0.1)); // alpha=0.4
      expect(result['altitude'], closeTo(1300.0, 0.1));  // alpha=0.3
      expect(result['heading'], closeTo(135.0, 1.0));    // alpha=0.5 circular
      expect(result['pitch'], closeTo(8.0, 0.1));        // alpha=0.6
      expect(result['roll'], closeTo(0.6, 0.1));         // alpha=0.6
    });

    test('campos ausentes devem manter valor anterior', () {
      service.smoothData({
        'velocidade': 120.0,
        'altitude': 1500.0,
      });
      
      final result = service.smoothData({
        'velocidade': 150.0,
        // altitude ausente
      });
      
      // EMA: 0.4 * 150 + 0.6 * 120 = 60 + 72 = 132
      expect(result['velocidade'], closeTo(132.0, 0.5));
      expect(result['altitude'], equals(1500.0));
    });

    // ==========================================================================
    // RESET TESTS
    // ==========================================================================

    test('reset deve limpar histórico e reiniciar suavização', () {
      service.smoothData({'altitude': 1000.0});
      service.smoothData({'altitude': 1100.0});
      service.smoothData({'altitude': 1200.0});
      
      service.reset();
      
      final result = service.smoothData({'altitude': 5000.0});
      
      expect(result['altitude'], equals(5000.0));
    });

    test('após reset, segunda leitura deve aplicar EMA novamente', () {
      service.smoothData({'velocidade': 100.0});
      service.smoothData({'velocidade': 200.0});
      
      service.reset();
      
      service.smoothData({'velocidade': 50.0});
      final result = service.smoothData({'velocidade': 150.0});
      
      // EMA: 0.4 * 150 + 0.6 * 50 = 60 + 30 = 90
      expect(result['velocidade'], closeTo(90.0, 0.1));
    });

    // ==========================================================================
    // EDGE CASES
    // ==========================================================================

    test('valores zero devem ser processados normalmente', () {
      service.smoothData({'velocidade': 100.0});
      final result = service.smoothData({'velocidade': 0.0});
      
      // EMA: 0.4 * 0 + 0.6 * 100 = 60
      expect(result['velocidade'], closeTo(60.0, 0.1));
    });

    test('valores negativos devem ser processados (pitch/roll)', () {
      service.smoothData({'pitch': 5.0});
      final result = service.smoothData({'pitch': -5.0});
      
      // EMA: 0.6 * (-5) + 0.4 * 5 = -3 + 2 = -1
      expect(result['pitch'], closeTo(-1.0, 0.1));
    });

    test('heading em 0° deve ser tratado corretamente', () {
      service.smoothData({'heading': 0.0});
      final result = service.smoothData({'heading': 10.0});
      
      // EMA circular: 0 + 0.5 * 10 = 5
      expect(result['heading'], closeTo(5.0, 0.5));
    });

    test('heading em 360° deve normalizar para 0°', () {
      service.smoothData({'heading': 360.0});
      final result = service.smoothData({'heading': 370.0});
      
      expect(result['heading'], greaterThanOrEqualTo(0.0));
      expect(result['heading'], lessThan(360.0));
    });
  });
}