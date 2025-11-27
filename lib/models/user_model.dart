enum UserRole { admin, gestor, instrutor, aluno }

class UserModel {
  final String id;
  final String authId;
  final String? aeroclubeId;
  final String nome;
  final String email;
  final String? telefone;
  final String? cpf;
  final DateTime? dataNascimento;
  final UserRole perfil;
  final String? canac;
  final DateTime? cmaValidade;
  final DateTime? chtValidade;
  final String? cursoAtual;
  final int? faseAtual;
  final double? horasVoadas;
  final double? horasPrevistas;
  final String? avatarUrl;
  final bool ativo;
  final bool primeiroAcesso;
  final DateTime? ultimoAcesso;

  UserModel({
    required this.id,
    required this.authId,
    this.aeroclubeId,
    required this.nome,
    required this.email,
    this.telefone,
    this.cpf,
    this.dataNascimento,
    required this.perfil,
    this.canac,
    this.cmaValidade,
    this.chtValidade,
    this.cursoAtual,
    this.faseAtual,
    this.horasVoadas,
    this.horasPrevistas,
    this.avatarUrl,
    this.ativo = true,
    this.primeiroAcesso = true,
    this.ultimoAcesso,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      authId: json['auth_id'] as String,
      aeroclubeId: json['aeroclube_id'] as String?,
      nome: json['nome'] as String,
      email: json['email'] as String,
      telefone: json['telefone'] as String?,
      cpf: json['cpf'] as String?,
      dataNascimento: json['data_nascimento'] != null
          ? DateTime.parse(json['data_nascimento'] as String)
          : null,
      perfil: _parseRole(json['perfil'] as String?),
      canac: json['canac'] as String?,
      cmaValidade: json['cma_validade'] != null
          ? DateTime.parse(json['cma_validade'] as String)
          : null,
      chtValidade: json['cht_validade'] != null
          ? DateTime.parse(json['cht_validade'] as String)
          : null,
      cursoAtual: json['curso_atual'] as String?,
      faseAtual: json['fase_atual'] as int?,
      horasVoadas: (json['horas_voadas'] as num?)?.toDouble(),
      horasPrevistas: (json['horas_previstas'] as num?)?.toDouble(),
      avatarUrl: json['avatar_url'] as String?,
      ativo: json['ativo'] as bool? ?? true,
      primeiroAcesso: json['primeiro_acesso'] as bool? ?? true,
      ultimoAcesso: json['ultimo_acesso'] != null
          ? DateTime.parse(json['ultimo_acesso'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_id': authId,
      'aeroclube_id': aeroclubeId,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'data_nascimento': dataNascimento?.toIso8601String().split('T').first,
      'perfil': perfil.name,
      'canac': canac,
      'cma_validade': cmaValidade?.toIso8601String().split('T').first,
      'cht_validade': chtValidade?.toIso8601String().split('T').first,
      'curso_atual': cursoAtual,
      'fase_atual': faseAtual,
      'horas_voadas': horasVoadas,
      'horas_previstas': horasPrevistas,
      'avatar_url': avatarUrl,
      'ativo': ativo,
      'primeiro_acesso': primeiroAcesso,
      'ultimo_acesso': ultimoAcesso?.toIso8601String(),
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'gestor':
        return UserRole.gestor;
      case 'instrutor':
        return UserRole.instrutor;
      case 'aluno':
        return UserRole.aluno;
      default:
        return UserRole.aluno;
    }
  }

  bool get isAdmin => perfil == UserRole.admin;
  bool get isGestor => perfil == UserRole.gestor;
  bool get isInstrutor => perfil == UserRole.instrutor;
  bool get isAluno => perfil == UserRole.aluno;

  UserModel copyWith({
    String? id,
    String? authId,
    String? aeroclubeId,
    String? nome,
    String? email,
    String? telefone,
    String? cpf,
    DateTime? dataNascimento,
    UserRole? perfil,
    String? canac,
    DateTime? cmaValidade,
    DateTime? chtValidade,
    String? cursoAtual,
    int? faseAtual,
    double? horasVoadas,
    double? horasPrevistas,
    String? avatarUrl,
    bool? ativo,
    bool? primeiroAcesso,
    DateTime? ultimoAcesso,
  }) {
    return UserModel(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      aeroclubeId: aeroclubeId ?? this.aeroclubeId,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      cpf: cpf ?? this.cpf,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      perfil: perfil ?? this.perfil,
      canac: canac ?? this.canac,
      cmaValidade: cmaValidade ?? this.cmaValidade,
      chtValidade: chtValidade ?? this.chtValidade,
      cursoAtual: cursoAtual ?? this.cursoAtual,
      faseAtual: faseAtual ?? this.faseAtual,
      horasVoadas: horasVoadas ?? this.horasVoadas,
      horasPrevistas: horasPrevistas ?? this.horasPrevistas,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ativo: ativo ?? this.ativo,
      primeiroAcesso: primeiroAcesso ?? this.primeiroAcesso,
      ultimoAcesso: ultimoAcesso ?? this.ultimoAcesso,
    );
  }
}