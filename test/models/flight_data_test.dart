import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/models/flight_data.dart';

void main() {
  group('FlightData Model Tests', () {
    
    test('factory zero deve criar dados zerados', () {
      final data = FlightData.zero();
      
      expect(data.velocidade, equals(0.0));
      expect(data.altitude, equals(0.0));
      expect(data.heading, equals(0.0));
      expect(data.pitch, equals(0.0));
      expect(data.roll, equals(0.0));
      expect(data.vario, equals(0.0));
    });

    test('fromMap deve converter Map corretamente', () {
      final map = {
        'velocidade': 120.0,
        'altitude': 1500.0,
        'heading': 270.0,
        'pitch': 5.0,
        'roll': -3.0,
        'vario': 2.5,
        'temperatura': 15.0,
        'pressao': 101325.0,
        'lat': -25.4284,
        'lng': -49.2733,
        'lsm_gz': 0.5,
        'acel_x': 0.1,
        'acel_y': -0.05,
      };
      
      final data = FlightData.fromMap(map);
      
      expect(data.velocidade, equals(120.0));
      expect(data.altitude, equals(1500.0));
      expect(data.heading, equals(270.0));
      expect(data.gyroZ, equals(0.5));
      expect(data.accelX, equals(0.1));
    });

    test('toMap deve converter para Map corretamente', () {
      final data = FlightData(
        velocidade: 120.0,
        altitude: 1500.0,
        heading: 270.0,
        pitch: 5.0,
        roll: -3.0,
        vario: 2.5,
        temperatura: 15.0,
        pressao: 101325.0,
        lat: -25.4284,
        lng: -49.2733,
        gyroZ: 0.5,
        accelX: 0.1,
        accelY: -0.05,
        timestamp: DateTime.now(),
      );
      
      final map = data.toMap();
      
      expect(map['velocidade'], equals(120.0));
      expect(map['altitude'], equals(1500.0));
      expect(map['lsm_gz'], equals(0.5));
    });

    test('copyWith deve criar cópia com valores alterados', () {
      final original = FlightData.zero();
      
      final modified = original.copyWith(
        velocidade: 150.0,
        altitude: 2000.0,
      );
      
      expect(modified.velocidade, equals(150.0));
      expect(modified.altitude, equals(2000.0));
      expect(modified.heading, equals(0.0)); // Não modificado
    });

    test('equality operator deve funcionar corretamente', () {
      final data1 = FlightData(
        velocidade: 120.0,
        altitude: 1500.0,
        heading: 270.0,
        pitch: 5.0,
        roll: -3.0,
        vario: 2.5,
        temperatura: 15.0,
        pressao: 101325.0,
        lat: -25.4284,
        lng: -49.2733,
        gyroZ: 0.5,
        accelX: 0.1,
        accelY: -0.05,
        timestamp: DateTime.now(),
      );
      
      final data2 = FlightData(
        velocidade: 120.0,
        altitude: 1500.0,
        heading: 270.0,
        pitch: 5.0,
        roll: -3.0,
        vario: 2.5,
        temperatura: 15.0,
        pressao: 101325.0,
        lat: -25.4284,
        lng: -49.2733,
        gyroZ: 0.5,
        accelX: 0.1,
        accelY: -0.05,
        timestamp: DateTime.now(),
      );
      
      expect(data1 == data2, isTrue);
    });

    test('fromMap com valores faltando deve usar defaults', () {
      final map = {
        'velocidade': 120.0,
        // altitude ausente
      };
      
      final data = FlightData.fromMap(map);
      
      expect(data.velocidade, equals(120.0));
      expect(data.altitude, equals(0.0)); // Default
    });
  });
}