import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}

class AuthService {
  final GoTrueClient _auth = SupabaseConfig.auth;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  User? get currentAuthUser => _auth.currentUser;

  Session? get currentSession => _auth.currentSession;

  bool get isAuthenticated => currentAuthUser != null;

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Falha no login. Verifique suas credenciais.');
      }

      return await _fetchUserProfile(response.user!.id);
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      throw AuthException('Erro inesperado: $e');
    }
  }

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String nome,
    String? telefone,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          'nome': nome,
          'telefone': telefone,
        },
      );

      if (response.user == null) {
        throw AuthException('Falha no cadastro. Tente novamente.');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      return await _fetchUserProfile(response.user!.id);
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      throw AuthException('Erro inesperado: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Erro ao sair: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } on AuthApiException catch (e) {
      throw AuthException(_mapAuthError(e.message));
    } catch (e) {
      throw AuthException('Erro ao enviar email: $e');
    }
  }

  Future<UserModel> _fetchUserProfile(String authId) async {
    try {
      final response = await SupabaseConfig.table('usuarios')
          .select()
          .eq('auth_id', authId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw AuthException('Erro ao carregar perfil: $e');
    }
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final user = currentAuthUser;
    if (user == null) return null;

    try {
      return await _fetchUserProfile(user.id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateLastAccess() async {
    final user = currentAuthUser;
    if (user == null) return;

    try {
      await SupabaseConfig.table('usuarios')
          .update({'ultimo_acesso': DateTime.now().toIso8601String()})
          .eq('auth_id', user.id);
    } catch (_) {}
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email ou senha incorretos';
    }
    if (message.contains('Email not confirmed')) {
      return 'Confirme seu email antes de entrar';
    }
    if (message.contains('User already registered')) {
      return 'Este email já está cadastrado';
    }
    if (message.contains('Password should be')) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }
    if (message.contains('Invalid email')) {
      return 'Email inválido';
    }
    return message;
  }
}