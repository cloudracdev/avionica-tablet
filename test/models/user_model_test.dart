import 'package:flutter_test/flutter_test.dart';
import 'package:qfly_avionica/models/user_model.dart';

void main() {
  group('UserModel', () {
    final validJson = {
      'id': '123e4567-e89b-12d3-a456-426614174000',
      'auth_id': '987fcdeb-51a2-3bc4-d567-890123456789',
      'aeroclube_id': 'abc12345-6789-0def-ghij-klmnopqrstuv',
      'nome': 'João Instrutor',
      'email': 'joao@aeroclube.com',
      'telefone': '41999999999',
      'cpf': '12345678900',
      'data_nascimento': '1985-05-15',
      'perfil': 'instrutor',
      'canac': '123456',
      'cma_validade': '2025-12-31',
      'cht_validade': '2026-06-30',
      'curso_atual': 'PP',
      'fase_atual': 3,
      'horas_voadas': 150.5,
      'horas_previstas': 200.0,
      'avatar_url': 'https://example.com/avatar.jpg',
      'ativo': true,
      'primeiro_acesso': false,
      'ultimo_acesso': '2025-11-27T10:30:00Z',
    };

    test('fromJson cria UserModel corretamente', () {
      final user = UserModel.fromJson(validJson);

      expect(user.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(user.nome, 'João Instrutor');
      expect(user.email, 'joao@aeroclube.com');
      expect(user.perfil, UserRole.instrutor);
      expect(user.horasVoadas, 150.5);
      expect(user.ativo, true);
    });

    test('fromJson parseia perfil corretamente', () {
      expect(UserModel.fromJson({...validJson, 'perfil': 'admin'}).perfil, UserRole.admin);
      expect(UserModel.fromJson({...validJson, 'perfil': 'gestor'}).perfil, UserRole.gestor);
      expect(UserModel.fromJson({...validJson, 'perfil': 'instrutor'}).perfil, UserRole.instrutor);
      expect(UserModel.fromJson({...validJson, 'perfil': 'aluno'}).perfil, UserRole.aluno);
    });

    test('fromJson perfil inválido retorna aluno', () {
      final user = UserModel.fromJson({...validJson, 'perfil': 'invalido'});
      expect(user.perfil, UserRole.aluno);
    });

    test('fromJson com campos null não quebra', () {
      final minimalJson = {
        'id': '123',
        'auth_id': '456',
        'nome': 'Teste',
        'email': 'teste@test.com',
        'perfil': 'aluno',
      };

      final user = UserModel.fromJson(minimalJson);

      expect(user.telefone, isNull);
      expect(user.cpf, isNull);
      expect(user.horasVoadas, isNull);
      expect(user.ativo, true);
    });

    test('toJson retorna Map correto', () {
      final user = UserModel.fromJson(validJson);
      final json = user.toJson();

      expect(json['nome'], 'João Instrutor');
      expect(json['email'], 'joao@aeroclube.com');
      expect(json['perfil'], 'instrutor');
    });

    test('isAdmin/isGestor/isInstrutor/isAluno funcionam', () {
      expect(UserModel.fromJson({...validJson, 'perfil': 'admin'}).isAdmin, true);
      expect(UserModel.fromJson({...validJson, 'perfil': 'gestor'}).isGestor, true);
      expect(UserModel.fromJson({...validJson, 'perfil': 'instrutor'}).isInstrutor, true);
      expect(UserModel.fromJson({...validJson, 'perfil': 'aluno'}).isAluno, true);
    });

    test('copyWith cria cópia com alterações', () {
      final user = UserModel.fromJson(validJson);
      final updated = user.copyWith(nome: 'Novo Nome', horasVoadas: 200.0);

      expect(updated.nome, 'Novo Nome');
      expect(updated.horasVoadas, 200.0);
      expect(updated.email, user.email);
    });
  });
}