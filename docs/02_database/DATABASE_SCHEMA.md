# 📊 QFLY AVIÔNICA - DATABASE SCHEMA
**Versão:** 1.0  
**Data:** 27/11/2025  
**Database:** PostgreSQL 15+ (Supabase)  
**Projeto:** pqbwhulxexwignymqpfv

---

## 📋 SUMÁRIO

1. [Visão Geral](#-visão-geral)
2. [Tabelas](#-tabelas-26)
3. [ENUMs](#-enums-22-tipos)
4. [Relacionamentos (FKs)](#-relacionamentos-foreign-keys)
5. [Indexes](#-indexes)
6. [RLS Policies](#-rls-policies-segurança)
7. [Storage Buckets](#-storage-buckets)
8. [Functions](#-functions)
9. [Diagrama ER](#-diagrama-er-simplificado)

---

## 🎯 VISÃO GERAL

```
┌─────────────────────────────────────────────────────────────┐
│  📊 QFLY DATABASE STATS                                     │
├─────────────────────────────────────────────────────────────┤
│  Tabelas:        26 (23 app + 3 PostGIS)                   │
│  ENUMs:          22 tipos customizados                      │
│  Foreign Keys:   35 relacionamentos                         │
│  Indexes:        65+ otimizações                           │
│  RLS Policies:   67 regras de segurança                    │
│  Storage:        7 buckets                                  │
│  Functions:      800+ (maioria PostGIS)                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 TABELAS (26)

### 🏢 **CORE - Organização**

#### `aeroclubes` (18 colunas)
> Entidade raiz multi-tenant

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `nome` | varchar | Nome oficial |
| `nome_fantasia` | varchar | Nome comercial |
| `cnpj` | varchar | UNIQUE |
| `cidade` | varchar | - |
| `estado` | char(2) | UF |
| `cep` | varchar | - |
| `endereco` | text | - |
| `codigo_anac` | varchar | UNIQUE - Código ANAC |
| `homologacao_anac` | date | Data homologação |
| `telefone` | varchar | - |
| `email` | varchar | - |
| `website` | varchar | - |
| `timezone` | varchar | Ex: America/Sao_Paulo |
| `config` | jsonb | Configurações customizadas |
| `ativo` | boolean | Status |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

#### `usuarios` (24 colunas)
> Todos os perfis: admin, gestor, instrutor, aluno

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `auth_id` | uuid | UNIQUE - Link Supabase Auth |
| `aeroclube_id` | uuid | FK → aeroclubes |
| `nome` | varchar | Nome completo |
| `email` | varchar | UNIQUE |
| `telefone` | varchar | - |
| `cpf` | varchar | UNIQUE |
| `data_nascimento` | date | - |
| `perfil` | enum | `admin`, `gestor`, `instrutor`, `aluno` |
| `canac` | varchar | Código ANAC pessoa |
| `cma_validade` | date | Certificado Médico |
| `cht_validade` | date | Cert. Habilitação Técnica |
| `curso_atual` | varchar | PP, PC, IFR, etc |
| `fase_atual` | integer | Fase do curso |
| `horas_voadas` | numeric | Total acumulado |
| `horas_previstas` | numeric | Previsão curso |
| `sinacta` | varchar | Sistema ANAC |
| `especialidades` | array | Ex: ['MNTE', 'MLTE'] |
| `avatar_url` | text | Foto perfil |
| `ativo` | boolean | Status |
| `primeiro_acesso` | boolean | Flag onboarding |
| `ultimo_acesso` | timestamptz | - |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

#### `aeronaves` (26 colunas)
> Frota do aeroclube

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `aeroclube_id` | uuid | FK → aeroclubes |
| `prefixo` | varchar | UNIQUE - Ex: PT-ABC |
| `modelo` | varchar | Ex: C172, PA-28 |
| `fabricante` | varchar | Cessna, Piper |
| `ano_fabricacao` | integer | - |
| `numero_serie` | varchar | S/N |
| `categoria` | varchar | MNTE, MLTE |
| `tipo_motor` | varchar | - |
| `mtow_kg` | numeric | Peso máximo |
| `hobbs_atual` | numeric | Horímetro |
| `tacometro_atual` | numeric | - |
| `proxima_inspecao_hobbs` | numeric | - |
| `proxima_inspecao_data` | date | - |
| `cva_validade` | date | Cert. Verificação Aeronaveg. |
| `seguro_validade` | date | - |
| `iam_validade` | date | Inspeção Anual Manutenção |
| `spu_codigo` | varchar | ID do ESP32 |
| `spu_ssid` | varchar | WiFi AP name |
| `spu_instalado_em` | date | - |
| `habilitacao` | varchar | MNTE, MLTE, MNPJ |
| `config` | jsonb | Configs específicas |
| `ativo` | boolean | - |
| `disponivel` | boolean | Para agendamento |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

### 📚 **CURRÍCULO - Estrutura Didática**

#### `cursos` (12 colunas)
> PP, PC, IFR, INVA, etc

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `codigo` | varchar | UNIQUE - Ex: PP, PC |
| `nome` | varchar | Piloto Privado |
| `descricao` | text | - |
| `horas_minimas` | numeric | Requisito ANAC |
| `horas_solo_minimas` | numeric | - |
| `horas_noturnas_minimas` | numeric | - |
| `horas_instrumento_minimas` | numeric | - |
| `total_fases` | integer | Qtd fases |
| `ativo` | boolean | - |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

#### `fases` (10 colunas)
> Divisões do curso

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `curso_id` | uuid | FK → cursos |
| `numero` | integer | 1, 2, 3... |
| `nome` | varchar | - |
| `descricao` | text | - |
| `horas_minimas` | numeric | - |
| `missoes_obrigatorias` | integer | - |
| `ordem` | integer | Sequência |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

#### `missoes` (13 colunas)
> Atividades específicas (FAP)

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `fase_id` | uuid | FK → fases |
| `codigo` | varchar | Ex: M1, M2 |
| `nome` | varchar | - |
| `descricao` | text | - |
| `objetivos` | array | Lista objetivos |
| `tipo` | varchar | solo, duplo |
| `horas_previstas` | numeric | - |
| `repeticoes_minimas` | integer | - |
| `ordem` | integer | - |
| `obrigatoria` | boolean | - |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

### ✈️ **OPERACIONAL - Voos**

#### `aulas_agendadas` (18 colunas)
> Agenda de instrução

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `aeroclube_id` | uuid | FK → aeroclubes |
| `instrutor_id` | uuid | FK → usuarios |
| `aluno_id` | uuid | FK → usuarios |
| `aeronave_id` | uuid | FK → aeronaves |
| `missao_id` | uuid | FK → missoes |
| `data_hora_inicio` | timestamptz | - |
| `data_hora_fim` | timestamptz | - |
| `duracao_prevista_min` | integer | - |
| `tipo` | varchar | instrucao, cheque |
| `observacoes` | text | - |
| `plano_voo_url` | text | PDF plano |
| `rota_prevista` | text | - |
| `status` | varchar | scheduled, completed |
| `cancelamento_motivo` | text | - |
| `voo_id` | uuid | Link pós-voo |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

#### `voos` (27 colunas)
> Registro de voos executados

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `aeroclube_id` | uuid | FK → aeroclubes |
| `instrutor_id` | uuid | FK → usuarios |
| `aluno_id` | uuid | FK → usuarios |
| `aeronave_id` | uuid | FK → aeronaves |
| `aula_agendada_id` | uuid | FK → aulas_agendadas |
| `missao_id` | uuid | FK → missoes |
| `local_id` | varchar | UNIQUE - ID offline |
| `device_id` | varchar | Tablet ID |
| `inicio_voo` | timestamptz | - |
| `fim_voo` | timestamptz | - |
| `duracao_minutos` | integer | - |
| `hobbs_inicio` | numeric | - |
| `hobbs_fim` | numeric | - |
| `aeroporto_origem` | varchar | ICAO |
| `aeroporto_destino` | varchar | ICAO |
| `rota` | text | - |
| `tipo_voo` | varchar | local, navegação |
| `condicoes_voo` | varchar | VFR, IFR |
| `status` | enum | `flight_status` |
| `sync_status` | enum | `sync_status` |
| `synced_at` | timestamptz | - |
| `sync_error` | text | - |
| `sync_version` | integer | Controle conflito |
| `metadata` | jsonb | Dados extras |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

#### `telemetria` (29 colunas)
> Dados sensores ESP32 (20Hz)

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `voo_id` | uuid | FK → voos |
| `seq` | integer | Sequência pacote |
| `timestamp` | timestamptz | Momento coleta |
| `latitude` | numeric | GPS |
| `longitude` | numeric | GPS |
| `altitude_msl_ft` | numeric | Altitude MSL |
| `altitude_agl_ft` | numeric | Altitude AGL |
| `ground_speed_kts` | numeric | Velocidade solo |
| `heading_true` | integer | Proa |
| `satellites` | integer | Satélites GPS |
| `hdop` | numeric | Precisão GPS |
| `pitch` | numeric | Atitude |
| `roll` | numeric | Atitude |
| `yaw` | numeric | Atitude |
| `ias_kts` | numeric | Velocidade indicada |
| `tas_kts` | numeric | Velocidade verdadeira |
| `vsi_fpm` | numeric | Razão subida/descida |
| `pressure_alt_ft` | numeric | Altitude pressão |
| `qnh_mb` | numeric | Ajuste altímetro |
| `density_alt_ft` | numeric | Altitude densidade |
| `rpm` | integer | Motor |
| `manifold_pressure` | numeric | Motor |
| `oat_celsius` | numeric | Temperatura externa |
| `turn_rate` | numeric | Taxa curva |
| `slip_ball` | numeric | Coordenação |
| `status` | varchar | flying, ground |
| `raw_data` | jsonb | JSON original ESP32 |
| `created_at` | timestamptz | - |

---

#### `avaliacoes` (35 colunas)
> Ficha Avaliação Piloto (FAP)

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `voo_id` | uuid | FK → voos |
| `instrutor_id` | uuid | FK → usuarios |
| `briefing` | enum | fap_grade (1-5, NA) |
| `preparacao_voo` | enum | fap_grade |
| `inspecao_prevoo` | enum | fap_grade |
| `taxi` | enum | fap_grade |
| `decolagem` | enum | fap_grade |
| `saida_trafego` | enum | fap_grade |
| `nivelamento` | enum | fap_grade |
| `curvas` | enum | fap_grade |
| `subidas` | enum | fap_grade |
| `descidas` | enum | fap_grade |
| `voo_lento` | enum | fap_grade |
| `estois` | enum | fap_grade |
| `orientacao` | enum | fap_grade |
| `navegacao_estimada` | enum | fap_grade |
| `navegacao_radio` | enum | fap_grade |
| `entrada_trafego` | enum | fap_grade |
| `aproximacao` | enum | fap_grade |
| `pouso` | enum | fap_grade |
| `arremetida` | enum | fap_grade |
| `emergencias` | enum | fap_grade |
| `disciplina_voo` | enum | fap_grade |
| `consciencia_situacional` | enum | fap_grade |
| `tomada_decisao` | enum | fap_grade |
| `nota_final` | numeric | Média calculada |
| `pontos_fortes` | text | - |
| `pontos_melhorar` | text | - |
| `observacoes` | text | - |
| `aprovado` | boolean | - |
| `repetir_missao` | boolean | - |
| `proxima_missao_id` | uuid | FK → missoes |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

#### `voos_civ` (30 colunas)
> Dados CIV Digital ANAC

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `voo_id` | uuid | FK → voos (UNIQUE) |
| `pousos` | integer | Quantidade |
| `funcao_instrutor` | enum | funcao_bordo_type |
| `funcao_aluno` | enum | funcao_bordo_type |
| `tipo_copiloto` | enum | tipo_copiloto_type |
| `natureza_voo` | enum | natureza_voo_type |
| `e_simulador` | boolean | - |
| `tempo_diurno_min` | integer | - |
| `tempo_noturno_min` | integer | - |
| `tempo_navegacao_min` | integer | - |
| `tempo_ifr_real_min` | integer | - |
| `tempo_ifr_simulado_min` | integer | - |
| `milhas_navegacao` | numeric | - |
| `tempo_simulador_min` | integer | - |
| `habilitacao_especifica` | varchar | MNTE, MLTE |
| `fstd_identificacao` | varchar | ID simulador |
| `observacoes` | text | - |
| `etapa_treinamento` | text | - |
| `status_saci` | enum | civ_saci_status_type |
| `cadastrado_saci_em` | timestamptz | - |
| `lancado_por_canac` | varchar | - |
| `exclusao_solicitada_em` | timestamptz | - |
| `exclusao_solicitada_por_canac` | varchar | - |
| `pdf_url` | text | - |
| `pdf_gerado_em` | timestamptz | - |
| `pdf_content_hash` | varchar | Verificação |
| `html_content` | text | HTML renderizado |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

#### `civ_registros` (14 colunas)
> Log envios ANAC

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `voo_id` | uuid | FK → voos |
| `protocolo_anac` | varchar | - |
| `numero_civ` | varchar | - |
| `xml_enviado` | text | - |
| `xml_resposta` | text | - |
| `status` | enum | civ_status |
| `tentativas` | integer | Retry count |
| `ultimo_erro` | text | - |
| `gerado_em` | timestamptz | - |
| `enviado_em` | timestamptz | - |
| `confirmado_em` | timestamptz | - |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

### 📋 **CHECKLISTS**

#### `checklists` (10 colunas)
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `aeroclube_id` | uuid | FK → aeroclubes |
| `aeronave_modelo` | varchar | Modelo aplicável |
| `nome` | varchar | - |
| `descricao` | text | - |
| `tipo` | varchar | pre-voo, pos-voo |
| `versao` | integer | - |
| `ativo` | boolean | - |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

#### `checklist_items` (9 colunas)
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `checklist_id` | uuid | FK → checklists |
| `ordem` | integer | Sequência |
| `categoria` | varchar | Agrupamento |
| `item` | text | Texto item |
| `descricao` | text | Detalhes |
| `tipo_resposta` | varchar | check, input |
| `obrigatorio` | boolean | - |
| `created_at` | timestamptz | - |

#### `checklist_execucoes` (9 colunas)
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `voo_id` | uuid | FK → voos |
| `checklist_id` | uuid | FK → checklists |
| `iniciado_em` | timestamptz | - |
| `finalizado_em` | timestamptz | - |
| `total_items` | integer | - |
| `items_completados` | integer | - |
| `respostas` | jsonb | Dados preenchidos |
| `created_at` | timestamptz | - |

---

### 📁 **DOCUMENTOS**

#### `documentos_usuarios` (14 colunas)
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `usuario_id` | uuid | FK → usuarios |
| `tipo` | enum | document_type |
| `nome` | varchar | - |
| `numero` | varchar | - |
| `storage_path` | text | Path no bucket |
| `url` | text | URL pública |
| `emitido_em` | date | - |
| `validade` | date | - |
| `verificado` | boolean | - |
| `verificado_por` | uuid | FK → usuarios |
| `verificado_em` | timestamptz | - |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

#### `documentos_aeronaves` (11 colunas)
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `aeronave_id` | uuid | FK → aeronaves |
| `tipo` | enum | document_type |
| `nome` | varchar | - |
| `numero` | varchar | - |
| `storage_path` | text | - |
| `url` | text | - |
| `emitido_em` | date | - |
| `validade` | date | - |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

### 🔧 **MANUTENÇÃO**

#### `manutencoes` (15 colunas)
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `aeronave_id` | uuid | FK → aeronaves |
| `tipo` | varchar | preventiva, corretiva |
| `descricao` | text | - |
| `data_realizada` | date | - |
| `hobbs_realizada` | numeric | - |
| `oficina` | varchar | - |
| `mecanico` | varchar | - |
| `proxima_hobbs` | numeric | - |
| `proxima_data` | date | - |
| `ordem_servico` | varchar | - |
| `storage_path` | text | Docs anexos |
| `custo` | numeric | - |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

### 📸 **MÍDIA**

#### `fotos_voo` (13 colunas)
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `voo_id` | uuid | FK → voos |
| `storage_path` | text | - |
| `url` | text | - |
| `tipo` | varchar | checklist, avaliacao |
| `descricao` | text | - |
| `tamanho_bytes` | integer | - |
| `mime_type` | varchar | - |
| `latitude` | numeric | EXIF |
| `longitude` | numeric | EXIF |
| `sync_status` | enum | sync_status |
| `synced_at` | timestamptz | - |
| `created_at` | timestamptz | - |

#### `logbook_entries` (7 colunas)
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `voo_id` | uuid | FK → voos |
| `instrutor_id` | uuid | FK → usuarios |
| `conteudo` | text | Diário bordo |
| `fotos` | jsonb | URLs fotos |
| `created_at` | timestamptz | - |
| `updated_at` | timestamptz | - |

---

### 🔔 **SISTEMA**

#### `notificacoes` (10 colunas)
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `usuario_id` | uuid | FK → usuarios |
| `tipo` | varchar | alerta, info |
| `titulo` | varchar | - |
| `mensagem` | text | - |
| `action_url` | text | Link ação |
| `action_data` | jsonb | - |
| `lida` | boolean | - |
| `lida_em` | timestamptz | - |
| `created_at` | timestamptz | - |

#### `audit_logs` (10 colunas)
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `usuario_id` | uuid | FK → usuarios |
| `tabela` | varchar | Tabela afetada |
| `registro_id` | uuid | ID registro |
| `acao` | varchar | INSERT, UPDATE |
| `dados_antigos` | jsonb | Before |
| `dados_novos` | jsonb | After |
| `ip_address` | inet | - |
| `user_agent` | text | - |
| `created_at` | timestamptz | - |

#### `wifi_logs` (6 colunas)
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | uuid | PK |
| `voo_id` | uuid | FK → voos |
| `event_type` | varchar | disconnected, reconnected |
| `timestamp` | timestamptz | - |
| `duration_seconds` | integer | - |
| `created_at` | timestamptz | - |

---

## 🏷️ ENUMS (22 tipos)

### **Aplicação**

| Enum | Valores |
|------|---------|
| `user_role` | `admin`, `gestor`, `instrutor`, `aluno` |
| `flight_status` | `scheduled`, `preflight`, `flying`, `landed`, `completed`, `cancelled` |
| `sync_status` | `pending`, `syncing`, `synced`, `error` |
| `fap_grade` | `1`, `2`, `3`, `4`, `5`, `NA` |
| `document_type` | `cma`, `cht`, `cva`, `seguro`, `outro` |
| `civ_status` | `pending`, `generating`, `sent`, `confirmed`, `error` |
| `civ_saci_status_type` | `nao_lancado`, `cadastrado`, `confirmado`, `excluido`, `erro` |
| `funcao_bordo_type` | `piloto_comando`, `copiloto`, `instrutor_voo`, `instrutor_voo_solo`, `instrutor_voo_observador`, `piloto_instrucao`, `piloto_instrucao_solo`, `piloto_instrucao_comando` |
| `natureza_voo_type` | `instrucao`, `nao_instrucao` |
| `tipo_copiloto_type` | `single_pilot`, `single_pilot_regulamentar`, `dual_pilot` |

### **Supabase Auth (sistema)**

| Enum | Valores |
|------|---------|
| `aal_level` | `aal1`, `aal2`, `aal3` |
| `factor_status` | `unverified`, `verified` |
| `factor_type` | `totp`, `webauthn`, `phone` |
| `one_time_token_type` | `confirmation_token`, `reauthentication_token`, `recovery_token`, ... |

---

## 🔗 RELACIONAMENTOS (Foreign Keys)

```
aeroclubes (1) ←──── (N) usuarios
aeroclubes (1) ←──── (N) aeronaves
aeroclubes (1) ←──── (N) aulas_agendadas
aeroclubes (1) ←──── (N) voos
aeroclubes (1) ←──── (N) checklists

cursos (1) ←──── (N) fases
fases (1) ←──── (N) missoes

usuarios (1) ←──── (N) aulas_agendadas [instrutor]
usuarios (1) ←──── (N) aulas_agendadas [aluno]
usuarios (1) ←──── (N) voos [instrutor]
usuarios (1) ←──── (N) voos [aluno]
usuarios (1) ←──── (N) avaliacoes
usuarios (1) ←──── (N) documentos_usuarios
usuarios (1) ←──── (N) notificacoes
usuarios (1) ←──── (N) audit_logs
usuarios (1) ←──── (N) logbook_entries

aeronaves (1) ←──── (N) aulas_agendadas
aeronaves (1) ←──── (N) voos
aeronaves (1) ←──── (N) manutencoes
aeronaves (1) ←──── (N) documentos_aeronaves

voos (1) ←──── (N) telemetria
voos (1) ←──── (1) avaliacoes
voos (1) ←──── (1) voos_civ
voos (1) ←──── (N) civ_registros
voos (1) ←──── (N) fotos_voo
voos (1) ←──── (N) logbook_entries
voos (1) ←──── (N) wifi_logs
voos (1) ←──── (N) checklist_execucoes

checklists (1) ←──── (N) checklist_items
checklists (1) ←──── (N) checklist_execucoes

missoes (1) ←──── (N) aulas_agendadas
missoes (1) ←──── (N) voos
missoes (1) ←──── (N) avaliacoes [proxima_missao]
```

---

## 📇 INDEXES

### **Por tabela principal**

| Tabela | Indexes |
|--------|---------|
| `aeroclubes` | cnpj (unique), codigo_anac (unique), estado, ativo |
| `usuarios` | auth_id (unique), email (unique), cpf (unique), aeroclube, perfil, canac, ativo |
| `aeronaves` | prefixo (unique), aeroclube, ativo |
| `voos` | local_id (unique), aeroclube, instrutor, aluno, aeronave, status, sync, inicio |
| `telemetria` | voo, voo_seq, voo_time, coords (PostGIS) |
| `avaliacoes` | voo, instrutor |
| `aulas_agendadas` | aeroclube, instrutor, aluno, data, status |
| `voos_civ` | voo_id (unique), status, created, natureza |

---

## 🔒 RLS POLICIES (Segurança)

### **Padrão por perfil**

| Perfil | Permissões |
|--------|------------|
| `admin` | FULL ACCESS todas tabelas |
| `gestor` | CRUD no próprio aeroclube |
| `instrutor` | CRUD próprios voos/avaliacoes, SELECT alunos |
| `aluno` | SELECT próprios dados apenas |

### **Exemplos críticos**

```sql
-- Admin vê tudo
CREATE POLICY "admin_usuarios_all" ON usuarios
  FOR ALL TO authenticated
  USING (get_user_perfil() = 'admin');

-- Gestor só seu aeroclube
CREATE POLICY "gestor_usuarios_aeroclube" ON usuarios
  FOR ALL TO authenticated
  USING (
    get_user_perfil() = 'gestor' 
    AND aeroclube_id = get_user_aeroclube_id()
  );

-- Aluno só próprios dados
CREATE POLICY "aluno_usuarios_own" ON usuarios
  FOR SELECT TO authenticated
  USING (
    get_user_perfil() = 'aluno' 
    AND auth_id = auth.uid()
  );
```

---

## 📦 STORAGE BUCKETS

| Bucket | Público | Uso |
|--------|---------|-----|
| `fotos-voo` | ❌ | Fotos durante voo |
| `documentos-usuarios` | ❌ | CMA, CHT, docs pessoais |
| `documentos-aeronaves` | ❌ | CVA, seguro, IAM |
| `fotos-manutencao` | ❌ | Registros manutenção |
| `planos-voo` | ❌ | PDFs planos |
| `materiais-aeroclube` | ❌ | Material didático |
| `civ-documents` | ✅ | PDFs CIV (público) |

---

## ⚙️ FUNCTIONS (Principais)

### **Helpers Auth**

```sql
get_user_id()          -- UUID do usuário logado
get_user_perfil()      -- Perfil (admin, gestor, etc)
get_user_aeroclube_id() -- Aeroclube do usuário
```

### **Triggers**

```sql
update_updated_at()           -- Auto-update updated_at
update_voos_civ_updated_at()  -- Específico voos_civ
handle_new_user()             -- Cria usuario após auth.signup
```

### **PostGIS (800+)**

Funções geoespaciais para telemetria: `st_distance`, `st_contains`, `st_intersects`, etc.

---

## 🗺️ DIAGRAMA ER (Simplificado)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ AEROCLUBES  │────<│  USUARIOS   │     │   CURSOS    │
└─────────────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       │           ┌───────┴───────┐          │
       │           │               │      ┌───┴───┐
       ▼           ▼               ▼      ▼       │
┌─────────────┐  ┌─────────────┐      ┌───────┐   │
│  AERONAVES  │  │AULAS_AGEND. │──────│ FASES │   │
└──────┬──────┘  └──────┬──────┘      └───┬───┘   │
       │                │                 │       │
       │           ┌────┴────┐       ┌────┴────┐  │
       │           │         │       │ MISSOES │──┘
       │           ▼         │       └────┬────┘
       │    ┌─────────────┐  │            │
       └───>│    VOOS     │<─┴────────────┘
            └──────┬──────┘
                   │
     ┌─────────────┼─────────────┬─────────────┐
     ▼             ▼             ▼             ▼
┌─────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│TELEMETR.│  │AVALIACOES│  │ VOOS_CIV │  │FOTOS_VOO │
└─────────┘  └──────────┘  └──────────┘  └──────────┘
```

---

## 📝 NOTAS

### ⚠️ Tabelas PostGIS (ignorar)
- `geography_columns`
- `geometry_columns`
- `spatial_ref_sys`

### 🔄 Campos padrão
Todas tabelas têm: `id` (uuid PK), `created_at`, `updated_at`

### 🔐 Multi-tenant
Isolamento por `aeroclube_id` + RLS policies

---

**Documento gerado em:** 27/11/2025  
**Próxima revisão:** Quando houver alteração de schema