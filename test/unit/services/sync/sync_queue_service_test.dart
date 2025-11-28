import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/services/sync/sync_queue_service.dart';
import 'package:qfly_avionica/services/sync/connectivity_service.dart';
import 'package:qfly_avionica/services/sync/i_sync_remote_service.dart';
import 'package:qfly_avionica/data/repositories/flight_session_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Inicializar FFI para testes
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SyncQueueService', () {
    late SyncQueueService syncService;
    late ConnectivityService connectivity;
    late MockSyncRemoteService remoteService;
    late FlightSessionRepository repository;

    setUp(() async {
      connectivity = ConnectivityService();
      remoteService = MockSyncRemoteService(simulatedDelayMs: 10);
      repository = FlightSessionRepository();

      syncService = SyncQueueService(
        repository: repository,
        remoteService: remoteService,
        connectivity: connectivity,
      );
    });

    tearDown(() async {
      syncService.dispose();
      connectivity.dispose();
    });

    group('Estado Inicial', () {
      test('deve iniciar com status idle', () {
        expect(syncService.status, SyncQueueStatus.idle);
      });
    });

    group('SyncQueueConfig', () {
      test('deve usar configurações padrão', () {
        const config = SyncQueueConfig();

        expect(config.maxRetries, 5);
        expect(config.syncOnlyOnWifi, isTrue);
      });

      test('deve aceitar configurações customizadas', () {
        const config = SyncQueueConfig(
          maxRetries: 10,
          syncOnlyOnWifi: false,
        );

        expect(config.maxRetries, 10);
        expect(config.syncOnlyOnWifi, isFalse);
      });
    });

    group('Conectividade', () {
      test('não deve processar sem WiFi quando syncOnlyOnWifi = true', () async {
        connectivity.simulateDisconnect();

        await syncService.processQueue();

        expect(syncService.status, SyncQueueStatus.idle);
      });

      test('não deve processar com 4G quando syncOnlyOnWifi = true', () async {
        connectivity.simulateMobileConnected();

        await syncService.processQueue();

        expect(syncService.status, SyncQueueStatus.idle);
      });
    });

    group('Stream de Status', () {
      test('deve emitir mudanças de status', () async {
        final statuses = <SyncQueueStatus>[];
        final subscription = syncService.onStatusChanged.listen(statuses.add);

        connectivity.simulateWifiConnected();
        await syncService.processQueue();

        await Future.delayed(const Duration(milliseconds: 100));
        await subscription.cancel();

        expect(statuses, contains(SyncQueueStatus.syncing));
        expect(statuses, contains(SyncQueueStatus.idle));
      });
    });

    group('SyncProgress', () {
      test('deve calcular percentage corretamente', () {
        const progress1 = SyncProgress(
          total: 10,
          completed: 5,
          status: SyncProgressStatus.uploading,
        );
        expect(progress1.percentage, 0.5);

        const progress2 = SyncProgress(
          total: 0,
          completed: 0,
          status: SyncProgressStatus.completed,
        );
        expect(progress2.percentage, 0.0);
      });

      test('toString deve retornar formato correto', () {
        const progress = SyncProgress(
          total: 10,
          completed: 3,
          status: SyncProgressStatus.uploading,
        );

        expect(progress.toString(), 'SyncProgress(3/10 - SyncProgressStatus.uploading)');
      });
    });

    group('Pause/Resume', () {
      test('pause deve mudar status para paused', () {
        syncService.pause();

        expect(syncService.status, SyncQueueStatus.paused);
      });
    });
  });

  group('SyncProgressStatus', () {
    test('deve ter todos os valores esperados', () {
      expect(SyncProgressStatus.values, contains(SyncProgressStatus.starting));
      expect(SyncProgressStatus.values, contains(SyncProgressStatus.uploading));
      expect(SyncProgressStatus.values, contains(SyncProgressStatus.completed));
      expect(SyncProgressStatus.values, contains(SyncProgressStatus.paused));
      expect(SyncProgressStatus.values, contains(SyncProgressStatus.error));
    });
  });
}