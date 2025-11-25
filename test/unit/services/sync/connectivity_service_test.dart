import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/services/sync/connectivity_service.dart';

void main() {
  group('ConnectivityService', () {
    late ConnectivityService service;

    setUp(() {
      service = ConnectivityService();
    });

    tearDown(() {
      service.dispose();
    });

    group('Estado Inicial', () {
      test('deve iniciar desconectado', () {
        expect(service.isConnected, isFalse);
        expect(service.canSync, isFalse);
        expect(service.currentState.type, ConnectivityType.none);
      });
    });

    group('Initialize', () {
      test('deve conectar WiFi após initialize', () async {
        await service.initialize();

        expect(service.isConnected, isTrue);
        expect(service.canSync, isTrue);
        expect(service.currentState.type, ConnectivityType.wifi);
      });
    });

    group('Simulações', () {
      test('simulateDisconnect deve desconectar', () async {
        await service.initialize();
        expect(service.isConnected, isTrue);

        service.simulateDisconnect();

        expect(service.isConnected, isFalse);
        expect(service.canSync, isFalse);
        expect(service.currentState.type, ConnectivityType.none);
      });

      test('simulateWifiConnected deve conectar WiFi', () {
        service.simulateWifiConnected();

        expect(service.isConnected, isTrue);
        expect(service.canSync, isTrue);
        expect(service.currentState.type, ConnectivityType.wifi);
      });

      test('simulateMobileConnected deve conectar mas NÃO permitir sync', () {
        service.simulateMobileConnected();

        expect(service.isConnected, isTrue);
        expect(service.canSync, isFalse); // 4G não permite sync!
        expect(service.currentState.type, ConnectivityType.mobile);
      });
    });

    group('Stream de Mudanças', () {
      test('deve emitir eventos quando estado muda', () async {
        final states = <ConnectivityState>[];
        final subscription = service.onConnectivityChanged.listen(states.add);

        service.simulateWifiConnected();
        service.simulateDisconnect();
        service.simulateMobileConnected();

        await Future.delayed(const Duration(milliseconds: 50));
        await subscription.cancel();

        expect(states.length, 3);
        expect(states[0].type, ConnectivityType.wifi);
        expect(states[1].type, ConnectivityType.none);
        expect(states[2].type, ConnectivityType.mobile);
      });
    });

    group('canSync Logic', () {
      test('canSync deve ser true APENAS para WiFi', () {
        // None
        service.simulateDisconnect();
        expect(service.canSync, isFalse);

        // Mobile
        service.simulateMobileConnected();
        expect(service.canSync, isFalse);

        // WiFi
        service.simulateWifiConnected();
        expect(service.canSync, isTrue);
      });
    });
  });
}