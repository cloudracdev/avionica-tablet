import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/services/auth/auth_service.dart';

void main() {
  group('AuthException', () {
    test('cria exception com mensagem', () {
      final exception = AuthException('Erro de teste');

      expect(exception.message, 'Erro de teste');
      expect(exception.toString(), 'Erro de teste');
    });

    test('mensagens diferentes são armazenadas corretamente', () {
      final e1 = AuthException('Email ou senha incorretos');
      final e2 = AuthException('Confirme seu email antes de entrar');

      expect(e1.message, 'Email ou senha incorretos');
      expect(e2.message, 'Confirme seu email antes de entrar');
    });

    test('exception é do tipo Exception', () {
      final exception = AuthException('Teste');
      expect(exception, isA<Exception>());
    });
  });
}