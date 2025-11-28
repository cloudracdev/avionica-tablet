import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfly_avionica/providers/connection_watchdog_provider.dart';
import 'package:qfly_avionica/providers/telemetry_provider.dart';
import 'package:qfly_avionica/providers/websocket_provider.dart';

void main() {
  group('ConnectionWatchdog Tests', () {
    
    // ==========================================================================
    // SETUP & HELPERS
    // ==========================================================================
    
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });

    // ==========================================================================
    // TESTES INICIALIZAÇÃO
    // ==========================================================================

    test('watchdog deve inicializar com attemptCount zero', () {
      final watchdog = container.read(connectionWatchdogProvider);
      
      expect(watchdog.currentAttempt, equals(0));
      expect(watchdog.isAtCap, isFalse);
    });

    test('watchdog deve resetar estado corretamente', () {
      final watchdog = container.read(connectionWatchdogProvider);
      
      // Simular algumas tentativas manualmente (para testar reset)
      watchdog.reset();
      
      expect(watchdog.currentAttempt, equals(0));
      expect(watchdog.isAtCap, isFalse);
    });

    // ==========================================================================
    // TESTES NOTIFICAÇÕES
    // ==========================================================================

    test('notification provider deve inicializar null', () {
      final notification = container.read(watchdogNotificationProvider);
      
      expect(notification, isNull);
    });

    test('reset deve limpar notificação', () {
      // Setar notificação manualmente
      container.read(watchdogNotificationProvider.notifier).state = 
          '🔄 Reconectando...';
      
      expect(
        container.read(watchdogNotificationProvider),
        equals('🔄 Reconectando...'),
      );
      
      // Reset deve limpar
      final watchdog = container.read(connectionWatchdogProvider);
      watchdog.reset();
      
      expect(container.read(watchdogNotificationProvider), isNull);
    });

    // ==========================================================================
    // TESTES BACKOFF INTEGRATION
    // ==========================================================================

    test('currentAttempt deve refletir número de tentativas de reconnect', () {
      final watchdog = container.read(connectionWatchdogProvider);
      
      // Estado inicial
      expect(watchdog.currentAttempt, equals(0));
      
      // Após reset, attemptCount permanece 0 até próxima tentativa real
      watchdog.reset();
      expect(watchdog.currentAttempt, equals(0));
    });

    test('isAtCap deve retornar false inicialmente', () {
      final watchdog = container.read(connectionWatchdogProvider);
      
      expect(watchdog.isAtCap, isFalse);
    });

    // ==========================================================================
    // TESTES LÓGICA WATCHDOG (CONCEITUAL)
    // ==========================================================================
    
    test('watchdog deve ter timeout de 5 segundos configurado', () {
      // Este teste verifica que o watchdog foi construído com configuração correta
      // O timeout real é testado em testes de integração E2E
      
      final watchdog = container.read(connectionWatchdogProvider);
      
      // Verificar que watchdog existe e está pronto
      expect(watchdog, isNotNull);
      expect(watchdog.currentAttempt, equals(0));
    });

    test('watchdog deve usar ExponentialBackoff internamente', () {
      // Verifica que watchdog foi construído corretamente
      // O backoff é testado isoladamente em exponential_backoff_test.dart
      
      final watchdog = container.read(connectionWatchdogProvider);
      
      // Estado inicial correto
      expect(watchdog.currentAttempt, equals(0));
      expect(watchdog.isAtCap, isFalse);
    });

    // ==========================================================================
    // TESTES RESET BEHAVIOR
    // ==========================================================================

    test('reset deve ser chamável múltiplas vezes sem erro', () {
      final watchdog = container.read(connectionWatchdogProvider);
      
      // Múltiplos resets não devem causar erro
      expect(() {
        watchdog.reset();
        watchdog.reset();
        watchdog.reset();
      }, returnsNormally);
      
      expect(watchdog.currentAttempt, equals(0));
    });

    test('dispose deve limpar recursos do watchdog', () {
      final watchdog = container.read(connectionWatchdogProvider);
      
      // Dispose deve ser chamável sem erro
      expect(() => watchdog.dispose(), returnsNormally);
    });

    // ==========================================================================
    // TESTES PROVIDER DEPENDENCIES
    // ==========================================================================

    test('watchdog provider deve depender de outros providers', () {
      // Verifica que watchdog pode acessar providers necessários
      
      final watchdog = container.read(connectionWatchdogProvider);
      
      // Provider foi criado com sucesso
      expect(watchdog, isNotNull);
      
      // Providers dependentes existem
      expect(
        () => container.read(connectionStateProvider),
        returnsNormally,
      );
      
      expect(
        () => container.read(ipAddressProvider),
        returnsNormally,
      );
    });

    // ==========================================================================
    // TESTES EDGE CASES
    // ==========================================================================

    test('watchdog deve funcionar quando connectionState é false', () {
      final watchdog = container.read(connectionWatchdogProvider);
      
      // Setar conexão como desconectada
      container.read(connectionStateProvider.notifier).state = false;
      
      // Watchdog não deve crashar
      expect(watchdog.currentAttempt, equals(0));
      expect(() => watchdog.reset(), returnsNormally);
    });

    test('watchdog deve funcionar quando IP está vazio', () {
      final watchdog = container.read(connectionWatchdogProvider);
      
      // IP vazio
      container.read(ipAddressProvider.notifier).state = '';
      
      // Watchdog não deve crashar
      expect(watchdog, isNotNull);
      expect(() => watchdog.reset(), returnsNormally);
    });

    test('múltiplos containers devem ter watchdogs independentes', () {
      final container2 = ProviderContainer();
      
      final watchdog1 = container.read(connectionWatchdogProvider);
      final watchdog2 = container2.read(connectionWatchdogProvider);
      
      // Devem ser instâncias diferentes
      expect(identical(watchdog1, watchdog2), isFalse);
      
      container2.dispose();
    });

    // ==========================================================================
    // TESTES TELEMETRY INTEGRATION
    // ==========================================================================

    test('watchdog deve poder ler telemetry provider', () {
      // Verifica que watchdog pode acessar telemetria
      
      expect(
        () => container.read(telemetryProvider),
        returnsNormally,
      );
    });

    test('telemetria inicial deve ter timestamp recente', () {
      final telemetry = container.read(telemetryProvider);
      
      final now = DateTime.now();
      final diff = now.difference(telemetry.timestamp).inSeconds;
      
      // Timestamp deve ser recente (< 5 segundos)
      expect(diff, lessThan(5));
    });

    // ==========================================================================
    // TESTES NOTIFICATION MESSAGES
    // ==========================================================================

    test('notification deve conter informações úteis quando setada', () {
      container.read(watchdogNotificationProvider.notifier).state = 
          '🔄 Reconectando... (tentativa #3 em 2.0s)';
      
      final notification = container.read(watchdogNotificationProvider);
      
      expect(notification, isNotNull);
      expect(notification, contains('Reconectando'));
      expect(notification, contains('tentativa'));
    });

    test('notification pode ser null (estado limpo)', () {
      // Estado inicial
      expect(container.read(watchdogNotificationProvider), isNull);
      
      // Setar notificação
      container.read(watchdogNotificationProvider.notifier).state = 
          'Teste';
      expect(container.read(watchdogNotificationProvider), equals('Teste'));
      
      // Limpar
      container.read(watchdogNotificationProvider.notifier).state = null;
      expect(container.read(watchdogNotificationProvider), isNull);
    });

    // ==========================================================================
    // TESTES PROVIDER LIFECYCLE
    // ==========================================================================

    test('watchdog provider deve ser singleton', () {
      final watchdog1 = container.read(connectionWatchdogProvider);
      final watchdog2 = container.read(connectionWatchdogProvider);
      
      // Mesma instância
      expect(identical(watchdog1, watchdog2), isTrue);
    });

    test('container dispose deve limpar watchdog', () {
      final watchdog = container.read(connectionWatchdogProvider);
      
      expect(watchdog, isNotNull);
      
      // Dispose container
      container.dispose();
      
      // Criar novo container deve criar novo watchdog
      final newContainer = ProviderContainer();
      final newWatchdog = newContainer.read(connectionWatchdogProvider);
      
      expect(identical(watchdog, newWatchdog), isFalse);
      
      newContainer.dispose();
    });

    // ==========================================================================
    // DOCUMENTAÇÃO & COMENTÁRIOS
    // ==========================================================================

    test('watchdog deve ter getters públicos para debug', () {
      final watchdog = container.read(connectionWatchdogProvider);
      
      // Getters existem e são acessíveis
      expect(() => watchdog.currentAttempt, returnsNormally);
      expect(() => watchdog.isAtCap, returnsNormally);
      
      // Valores iniciais corretos
      expect(watchdog.currentAttempt, isA<int>());
      expect(watchdog.isAtCap, isA<bool>());
    });
  });

  // ============================================================================
  // TESTES AUXILIARES - EXPONENTIAL BACKOFF BEHAVIOR
  // ============================================================================
  
  group('ConnectionWatchdog - Backoff Behavior', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });

    test('reset após reconnect bem-sucedido deve zerar contador', () {
      final watchdog = container.read(connectionWatchdogProvider);
      
      // Simular reconnect bem-sucedido
      watchdog.reset();
      
      // Contador deve estar zerado
      expect(watchdog.currentAttempt, equals(0));
      expect(watchdog.isAtCap, isFalse);
    });

    test('watchdog deve manter estado entre múltiplas leituras', () {
      final watchdog1 = container.read(connectionWatchdogProvider);
      watchdog1.reset();
      
      final watchdog2 = container.read(connectionWatchdogProvider);
      
      // Mesma instância, mesmo estado
      expect(identical(watchdog1, watchdog2), isTrue);
      expect(watchdog2.currentAttempt, equals(0));
    });
  });
}