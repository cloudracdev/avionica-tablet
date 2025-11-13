import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/services/data_processing/smoothing_service.dart';

void main() {
  group('SmoothingService Tests', () {
    
    test('deve retornar dados válidos', () {
      final service = SmoothingService();
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
      final service = SmoothingService();
      
      service.smoothData({'altitude': 1000.0});
      service.reset();
      
      final result = service.smoothData({'altitude': 2000.0});
      
      expect(result['altitude'], equals(2000.0));
    });
  });
}