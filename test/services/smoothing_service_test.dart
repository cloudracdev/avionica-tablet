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
    // NOVOS TESTES - EMA ALGORITHM (ALPHA RESPONSIVO)
    // ==========================================================================

    test('primeira leitura deve retornar valor bruto (sem suavização)', () {
      final result = service.smoothData({
        'velocidade': 150.0,
        'altitude': 1500.0,
        'heading': 180.0,
      });
      
      // Primeira leitura = valor bruto
      expect(result['velocidade'], equals(150.0));
      expect(result['altitude'], equals(1500.0));
      expect(result['heading'], equals(180.0));
    });

    test('segunda leitura deve aplicar EMA - velocidade (alpha=0.8)', () {
      // t0: 100 km/h
      service.smoothData({'velocidade': 100.0});
      
      // t1: 200 km/h
      final result = service.smoothData({'velocidade': 200.0});
      
      // EMA: 0.8 * 200 + 0.2 * 100 = 160 + 20 = 180
      expect(result['velocidade'], closeTo(180.0, 0.1));
    });

    test('segunda leitura deve aplicar EMA - altitude (alpha=0.7)', () {
      // t0: 1000m
      service.smoothData({'altitude': 1000.0});
      
      // t1: 2000m
      final result = service.smoothData({'altitude': 2000.0});
      
      // EMA: 0.7 * 2000 + 0.3 * 1000 = 1400 + 300 = 1700
      expect(result['altitude'], closeTo(1700.0, 0.1));
    });

    test('terceira leitura deve continuar suavizando progressivamente', () {
      service.smoothData({'velocidade': 100.0}); // t0: 100
      service.smoothData({'velocidade': 200.0}); // t1: 180
      final result = service.smoothData({'velocidade': 100.0}); // t2: ?
      
      // t2 = 0.8 * 100 + 0.2 * 180 = 80 + 36 = 116
      expect(result['velocidade'], closeTo(116.0, 0.5));
    });

    // ==========================================================================
    // DEAD ZONE TESTS (VALORES AJUSTADOS)
    // ==========================================================================

    test('dead zone deve ignorar mudanças pequenas - altitude', () {
      service.smoothData({'altitude': 1000.0});
      
      // Mudança de 0.15m (< 0.2m dead zone)
      final result = service.smoothData({'altitude': 1000.15});
      
      // Deve manter valor anterior
      expect(result['altitude'], equals(1000.0));
    });

    test('dead zone deve aceitar mudanças grandes - altitude', () {
      service.smoothData({'altitude': 1000.0});
      
      // Mudança de 10m (> 0.2m dead zone)
      final result = service.smoothData({'altitude': 1010.0});
      
      // Deve aplicar EMA: 0.7 * 1010 + 0.3 * 1000 = 1007
      expect(result['altitude'], closeTo(1007.0, 0.1));
    });

    test('dead zone deve ignorar mudanças pequenas - velocidade', () {
      service.smoothData({'velocidade': 120.0});
      
      // Mudança de 0.15 km/h (< 0.2 km/h dead zone)
      final result = service.smoothData({'velocidade': 120.15});
      
      // Deve manter valor anterior
      expect(result['velocidade'], equals(120.0));
    });

    test('dead zone deve aceitar mudanças grandes - velocidade', () {
      service.smoothData({'velocidade': 120.0});
      
      // Mudança de 20 km/h (> 0.2 km/h dead zone)
      final result = service.smoothData({'velocidade': 140.0});
      
      // Deve aplicar EMA: 0.8 * 140 + 0.2 * 120 = 112 + 24 = 136
      expect(result['velocidade'], closeTo(136.0, 0.1));
    });

    // ==========================================================================
    // CIRCULAR SMOOTHING (HEADING - ALPHA=0.9)
    // ==========================================================================

    test('heading circular - mudança normal 90° → 120°', () {
      service.smoothData({'heading': 90.0});
      
      final result = service.smoothData({'heading': 120.0});
      
      // EMA: 0.9 * 120 + 0.1 * 90 = 108 + 9 = 117
      expect(result['heading'], closeTo(117.0, 0.5));
    });

    test('heading circular - wrap around 350° → 10°', () {
      service.smoothData({'heading': 350.0});
      
      final result = service.smoothData({'heading': 10.0});
      
      // Diferença circular: 10 - 350 = -340, mas deve ser +20
      // EMA circular: 350 + 0.9 * 20 = 368 → normaliza para 8
      expect(result['heading'], closeTo(8.0, 1.0));
    });

    test('heading circular - wrap around 10° → 350°', () {
      service.smoothData({'heading': 10.0});
      
      final result = service.smoothData({'heading': 350.0});
      
      // Diferença circular: 350 - 10 = 340, mas deve ser -20
      // EMA circular: 10 + 0.9 * (-20) = -8 → normaliza para 352
      expect(result['heading'], closeTo(352.0, 1.0));
    });

    test('heading dead zone - ignora mudanças < 0.5°', () {
      service.smoothData({'heading': 180.0});
      
      // Mudança de 0.3° (< 0.5° dead zone)
      final result = service.smoothData({'heading': 180.3});
      
      // Deve manter valor anterior
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
      
      // Cada campo usa seu próprio alpha
      expect(result['velocidade'], closeTo(180.0, 0.1)); // alpha=0.8
      expect(result['altitude'], closeTo(1700.0, 0.1));  // alpha=0.7
      expect(result['heading'], closeTo(171.0, 1.0));    // alpha=0.9 circular
      expect(result['pitch'], closeTo(9.5, 0.1));        // alpha=0.9
      expect(result['roll'], closeTo(2.4, 0.1));         // alpha=0.9
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
      
      expect(result['velocidade'], closeTo(144.0, 0.5)); // Atualizado
      expect(result['altitude'], equals(1500.0));        // Mantido
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
      
      // Após reset, primeira leitura = valor bruto
      expect(result['altitude'], equals(5000.0));
    });

    test('após reset, segunda leitura deve aplicar EMA novamente', () {
      service.smoothData({'velocidade': 100.0});
      service.smoothData({'velocidade': 200.0});
      
      service.reset();
      
      service.smoothData({'velocidade': 50.0}); // Nova primeira
      final result = service.smoothData({'velocidade': 150.0}); // Nova segunda
      
      // EMA: 0.8 * 150 + 0.2 * 50 = 120 + 10 = 130
      expect(result['velocidade'], closeTo(130.0, 0.1));
    });

    // ==========================================================================
    // EDGE CASES
    // ==========================================================================

    test('valores zero devem ser processados normalmente', () {
      service.smoothData({'velocidade': 100.0});
      
      final result = service.smoothData({'velocidade': 0.0});
      
      // EMA: 0.8 * 0 + 0.2 * 100 = 20
      expect(result['velocidade'], closeTo(20.0, 0.1));
    });

    test('valores negativos devem ser processados (pitch/roll)', () {
      service.smoothData({'pitch': 5.0});
      
      final result = service.smoothData({'pitch': -5.0});
      
      // EMA: 0.9 * (-5) + 0.1 * 5 = -4.5 + 0.5 = -4.0
      expect(result['pitch'], closeTo(-4.0, 0.1));
    });

    test('heading em 0° deve ser tratado corretamente', () {
      service.smoothData({'heading': 0.0});
      
      final result = service.smoothData({'heading': 10.0});
      
      // EMA circular: 0 + 0.9 * 10 = 9
      expect(result['heading'], closeTo(9.0, 0.5));
    });

    test('heading em 360° deve normalizar para 0°', () {
      service.smoothData({'heading': 360.0});
      
      final result = service.smoothData({'heading': 370.0});
      
      // 360 e 370 normalizam para 0 e 10
      expect(result['heading'], greaterThanOrEqualTo(0.0));
      expect(result['heading'], lessThan(360.0));
    });
  });
}