import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/providers/auth_provider.dart';
import 'package:qfly_avionica/models/user_model.dart';

void main() {
  group('AuthState', () {
    test('estado inicial tem valores corretos', () {
      const state = AuthState();

      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
    });

    test('isAuthenticated retorna true quando authenticated', () {
      const state = AuthState(status: AuthStatus.authenticated);
      expect(state.isAuthenticated, true);
    });

    test('isLoading retorna true quando loading', () {
      const state = AuthState(status: AuthStatus.loading);
      expect(state.isLoading, true);
    });

    test('copyWith mantém valores não alterados', () {
      const original = AuthState(
        status: AuthStatus.authenticated,
        errorMessage: 'erro',
      );

      final copied = original.copyWith(status: AuthStatus.loading);

      expect(copied.status, AuthStatus.loading);
      expect(copied.errorMessage, isNull);
    });

    test('isAdmin/isGestor/isInstrutor/isAluno sem user retorna false', () {
      const state = AuthState();

      expect(state.isAdmin, false);
      expect(state.isGestor, false);
      expect(state.isInstrutor, false);
      expect(state.isAluno, false);
    });

    test('isInstrutor com user instrutor retorna true', () {
      final user = UserModel(
        id: '1',
        authId: '2',
        nome: 'Teste',
        email: 'teste@test.com',
        perfil: UserRole.instrutor,
      );

      final state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

      expect(state.isInstrutor, true);
      expect(state.isAdmin, false);
    });
  });

  group('AuthStatus', () {
    test('todos os status existem', () {
      expect(AuthStatus.values, contains(AuthStatus.initial));
      expect(AuthStatus.values, contains(AuthStatus.loading));
      expect(AuthStatus.values, contains(AuthStatus.authenticated));
      expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
      expect(AuthStatus.values, contains(AuthStatus.error));
    });
  });
}