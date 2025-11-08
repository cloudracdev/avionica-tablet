# 🚀 AVIÔNICA - SPRINT PLAN MVP (24 SEMANAS)

**Projeto:** Sistema Aviônica Completo (Hardware + Mobile + Backend + Web)  
**Duração:** 24 semanas | 12 sprints × 2 semanas  
**Capacidade:** 1 dev fullstack = 35 SP/sprint  
**Data:** 07/11/2025

---

## 📊 OVERVIEW EXECUTIVO

### 🎯 Objetivo
Entregar MVP production-ready em 6 meses:
- 📱 Mobile tablet offline-first (Flutter)
- 🖥️ Backend workflows (Supabase + N8N)
- 🌐 Web 4 portais (Next.js)
- 🔌 Integração SPU SPU (20Hz telemetria)
- 📜 CIV Digital ANAC homologado

### 🏆 Métricas Chave MVP

| Métrica | Atual | Meta 24 Semanas |
|---------|-------|-----------------|
| 🧪 Cobertura Testes | 0% | ≥70% |
| 🏗️ Dívida Técnica | ~30% | <5% |
| ⚠️ Warnings Build | 28 | 0 |
| 📐 Arquitetura | 4/10 | 8/10 |
| 🔌 SPU Integração | Mock | Real 20Hz |
| 🌐 Portais Web | 0 | 4 completos |
| ✈️ Voos Reais | 0 | 20+ validados |
| 📜 CIV ANAC | Mock | Prod homologado |

### ⭐ North Star Metric
**"Voo Real Completo de Ponta a Ponta"**
- Login → Checklist → Voo com telemetria → Avaliação → CIV ANAC enviado
- Meta: <10 min do login até CIV gerado

---

## 🗺️ ROADMAP 24 SEMANAS

```
├─ 🏗️  FASE 1: FUNDAÇÃO (Sprint 1-6)       → Refatoração + Backend + Web base
├─ 🧪  FASE 2: INTEGRAÇÃO (Sprint 7-8)     → Beta real + Hardware
├─ 🔒  FASE 3: HOMOLOGAÇÃO (Sprint 9-10)   → ANAC + Security
└─ 🚀  FASE 4: PRODUÇÃO (Sprint 11-12)     → Deploy + Go-Live
```

---

## 🎯 SPRINTS DETALHADAS

---

## 🔥 SPRINT 1-2: REFATORAÇÃO MOBILE

**Objetivo:** Limpar código + arquitetura + testes base  
**Duração:** Semanas 1-4 | 35 SP/sprint | Risco: 🟡 Médio

### 📦 Sprint 1 (Semanas 1-2)

#### 1. Arquitetura Limpa (20 SP)
- Separar sixpack_screen (643 → <200 linhas)
- Migrar Map → FlightData type-safe
- Provider/Riverpod state management
- Repository pattern (WebSocket, Local)
- Injeção dependência básica

#### 2. Infraestrutura Testes (12 SP)
- Setup test runner + coverage
- Mocks (WebSocket, Sensores)
- Testes SmoothingService
- Testes CalibrationService
- Widget tests 2 instrumentos

#### 3. CI/CD (3 SP)
- GitHub Actions pipeline
- Lint + analyze
- Coverage reports

### 📦 Sprint 2 (Semanas 3-4)

#### 1. Estabilidade (15 SP)
- Reconnect WebSocket (exponential backoff)
- Error boundaries globais
- Validação ranges sensores
- Fallback último valor válido
- Tratamento WiFi loss (conforme overview)

#### 2. Persistência Local (15 SP)
- SQLite setup (1 DB por voo)
- Hive cache rápido
- FlightSession CRUD
- Offline-first completo
- Migrations

#### 3. Testes (5 SP)
- Cobertura 40% → 60%
- Widget tests 4 instrumentos
- Integration tests offline

### 🎯 KPIs Sprints 1-2
- ✅ sixpack_screen: <200 linhas
- ✅ Cobertura: 0% → 60%
- ✅ Warnings: 28 → <10
- ✅ Arquitetura: 4/10 → 7/10
- ✅ Offline-first funcional

---

## 🖥️ SPRINT 3-4: BACKEND + AUTH

**Objetivo:** Supabase + N8N workflows + auth production  
**Duração:** Semanas 5-8 | 35 SP/sprint | Risco: 🟡 Médio

### 📦 Sprint 3 (Semanas 5-6)

#### 1. Infra Backend (18 SP)
- Supabase Auth setup (JWT)
- PostgreSQL schema completo (do overview)
- Redis cache
- S3/Storage fotos
- API REST base

#### 2. N8N Workflows (12 SP)
- Workflow 1: Sync voo mobile → cloud
- Workflow 2: CIV ANAC (sandbox)
- Workflow 3: Notificações email
- Docker compose N8N

#### 3. Mobile Auth (5 SP)
- Login/Signup real
- Protected routes
- Session persistence
- Roles (instrutor/aluno/gestor/admin)

### 📦 Sprint 4 (Semanas 7-8)

#### 1. Sync Mobile ↔ Cloud (20 SP)
- Sync voos pendentes (WiFi/4G)
- Conflict resolution
- Queue offline
- Progress indicators
- Bateria tablet monitoring (overview)

#### 2. Web Scaffold (10 SP)
- Next.js 14 setup
- Layout base 4 portais
- Auth páginas
- Routing

#### 3. Testes (5 SP)
- Auth flow tests
- Sync tests
- API tests
- Cobertura 60% → 65%

### 🎯 KPIs Sprints 3-4
- ✅ Supabase + N8N rodando
- ✅ Auth production
- ✅ Sync automático funcional
- ✅ Web scaffold pronto
- ✅ 3 workflows N8N ativos

---

## 🌐 SPRINT 5-6: PORTAIS WEB + FEATURES MOBILE

**Objetivo:** 4 portais + features essenciais mobile  
**Duração:** Semanas 9-12 | 38 SP/sprint | Risco: 🟢 Baixo

### 📦 Sprint 5 (Semanas 9-10)

#### 1. Portal Gestor (15 SP)
- CRUD alunos/instrutores
- CRUD aeronaves
- Agenda aulas
- Dashboard resumo
- Relatórios básicos

#### 2. Portal Admin (13 SP)
- Gestão aeroclubes
- Usuários global
- Live tracking global (conforme overview)
- Métricas sistema
- Config N8N workflows

#### 3. Mobile Features (10 SP)
- Checklist digital
- Fotos câmera (4 fotos/voo)
- Plano voo upload PDF
- Bateria tablet UI

### 📦 Sprint 6 (Semanas 11-12)

#### 1. Portal Instrutor Web (12 SP)
- Histórico voos aluno
- Avaliação FAP detalhada
- Replay 2D telemetria (Leaflet)
- CIV digital visualização
- Análise progresso

#### 2. Portal Aluno Web (10 SP)
- Ver próprios voos
- Progresso CIV
- Documentos upload (CMA, CHT)
- Perfil básico
- Histórico simplificado

#### 3. Mobile Avaliação FAP (8 SP)
- Formulário MCA 58-3
- 6 categorias avaliação
- Salvar local + sync
- Assinatura digital básica

#### 4. N8N Workflows (5 SP)
- Workflow 4: CIV retry logic
- Workflow 5: Relatórios automáticos
- Workflow 6: Backup diário

### 🎯 KPIs Sprints 5-6
- ✅ 4 portais web funcionais
- ✅ Replay 2D (Leaflet)
- ✅ 6 workflows N8N completos
- ✅ Mobile features essenciais
- ✅ Cobertura: 65% → 70%

---

## 🧪 SPRINT 7-8: BETA TESTING REAL

**Objetivo:** Hardware SPU real + 20 voos validados  
**Duração:** Semanas 13-16 | 35 SP/sprint | Risco: 🔴 Alto

### 📦 Sprint 7 (Semanas 13-14)

#### 1. Integração SPU Real (20 SP)
- Remover mock WebSocket
- Integrar SPU SPU 20Hz
- Calibração automática SPU
- Validar 7 sensores
- GPS interpolação 20Hz
- Tratamento perda pacotes (<1%)
- WiFi SSID "CODIGO-qfly-AP"

#### 2. Hardware Setup (10 SP)
- Montar 2 SPU completos
- Manual instalação aeronave
- Teste voo solo (1 voo)
- Ajustes calibração
- Documentar problemas

#### 3. Mobile Ajustes (5 SP)
- Sixpack 20Hz real
- Validação ranges sensores
- WiFi loss handling
- Logs estruturados

### 📦 Sprint 8 (Semanas 15-16)

#### 1. Beta Operacional (25 SP)
- Treinar 3 instrutores reais
- 20 voos reais executados
- Coletar feedback UX
- Bugs P0/P1 identificados
- Métricas performance real

#### 2. Refinamentos (10 SP)
- Fix bugs críticos
- UX melhorias feedback
- Performance tuning
- Estabilidade WebSocket

### 🎯 KPIs Sprints 7-8
- ✅ 2 SPU instalados
- ✅ 20 voos reais validados
- ✅ 3 instrutores treinados
- ✅ Telemetria 20Hz estável
- ✅ <5 bugs P0 abertos
- ✅ Cobertura: 70% → 72%

### ⚠️ Riscos
| Risco | Mitigação |
|-------|-----------|
| SPU falha voo | Backup SPU + fallback mock |
| WiFi instável | Retry + offline resiliente |
| Sensores descalibrados | Protocolo calibração documentado |
| Resistência instrutores | Treinar bem + support ativo |

---

## 🔒 SPRINT 9-10: HOMOLOGAÇÃO + SECURITY

**Objetivo:** ANAC produção + pentest + compliance  
**Duração:** Semanas 17-20 | 38 SP/sprint | Risco: 🔴 Alto

### 📦 Sprint 9 (Semanas 17-18)

#### 1. CIV ANAC Produção (18 SP)
- Migrar sandbox → produção
- Certificado ICP-Brasil
- Workflow retry robusto
- Testar 20 CIVs reais
- Aprovação ANAC formal
- Prazo 24h compliance

#### 2. Security Audit (12 SP)
- Pentest externo
- LGPD compliance
- Audit logs completos
- Criptografia dados sensíveis
- Correções vulnerabilidades

#### 3. Backup Geo (5 SP)
- Backup 3x/dia automático
- Redundância geográfica
- Teste restore
- DR procedures

### 📦 Sprint 10 (Semanas 19-20)

#### 1. Performance Load Test (15 SP)
- Simular 1000 users
- Latência API <200ms
- Uptime 99.9% target
- Stress test N8N workflows
- Otimizações críticas

#### 2. Monitoring Completo (13 SP)
- Sentry crashes
- Grafana dashboards
- PagerDuty alertas
- StatusPage público
- Logs ELK stack

#### 3. Documentação Final (7 SP)
- User manuals (4 perfis)
- API docs
- Troubleshooting
- Vídeo tutoriais
- FAQ

### 🎯 KPIs Sprints 9-10
- ✅ CIV ANAC homologado ✅
- ✅ Pentest sem críticos
- ✅ LGPD compliant
- ✅ Load test 1k users OK
- ✅ 99.9% uptime simulado
- ✅ Docs 100% cobertura
- ✅ Cobertura: 72% → 75%

### ⚠️ Riscos
| Risco | Mitigação |
|-------|-----------|
| ANAC rejeita CIV | Validar com ANAC antes + advogado |
| Falhas pentest | Fix imediato vulnerabilidades |
| Load test falha | Otimizar queries + Redis cache |

---

## 🚀 SPRINT 11-12: PRODUÇÃO + GO-LIVE

**Objetivo:** Deploy produção + go-live aeroclube piloto  
**Duração:** Semanas 21-24 | 35 SP/sprint | Risco: 🟡 Médio

### 📦 Sprint 11 (Semanas 21-22)

#### 1. Deploy Produção (20 SP)
- Vercel produção (web)
- Railway N8N produção
- Supabase produção
- Redis produção
- S3 produção
- DNS + SSL
- Smoke tests

#### 2. Monitoring Live (10 SP)
- Sentry live
- Grafana dashboards live
- PagerDuty on-call
- StatusPage ativo
- Incident response plan

#### 3. Release Prep (5 SP)
- Versioning v1.0.0
- Changelog
- Rollback procedures
- Hotfix pipeline

### 📦 Sprint 12 (Semanas 23-24)

#### 1. Go-Live Aeroclube (15 SP)
- Onboarding aeroclube piloto
- Setup infra local
- Treinar equipe completa
- 1ª semana acompanhamento
- Support ativo

#### 2. Marketing Launch (10 SP)
- Landing page otimizada
- Press release
- Social media kit
- Vídeo demo profissional
- SEO on-page

#### 3. Métricas Sucesso (5 SP)
- Analytics conversão
- NPS survey setup
- Usage dashboards
- Growth loops básicos

#### 4. Retrospectiva 6 Meses (5 SP)
- Review completo
- Lições aprendidas
- Roadmap pós-MVP
- Debt técnica mapeada

### 🎯 KPIs Sprints 11-12
- ✅ v1.0.0 PRODUÇÃO ✅
- ✅ Aeroclube piloto ativo
- ✅ 50+ voos produção
- ✅ Zero P0 bugs
- ✅ 99.9% uptime real
- ✅ NPS ≥40
- ✅ 10+ instrutores usando
- ✅ CIV enviados 100% sucesso

---

## 📈 MÉTRICAS SUCESSO MVP (24 SEMANAS)

### 🎯 OKRs Principais

**O1: MVP Production-Ready**
- KR1: 4 portais web funcionais ✓
- KR2: 20 voos reais validados ✓
- KR3: CIV ANAC homologado ✓
- KR4: Aeroclube piloto ativo ✓

**O2: Excelência Técnica**
- KR1: Cobertura ≥70% ✓
- KR2: Warnings = 0 ✓
- KR3: Arquitetura 8/10 ✓
- KR4: Uptime 99.9% ✓

**O3: Validação Mercado**
- KR1: 50+ voos produção ✓
- KR2: 10+ instrutores usando ✓
- KR3: NPS ≥40 ✓
- KR4: Zero bugs P0 ✓

---

## 🗓️ TIMELINE VISUAL

```
📅 SEMANAS 1-4   │████████│ FUNDAÇÃO Mobile
   Sprint 1-2    │ Arquitetura + Testes + Offline

📅 SEMANAS 5-8   │████████│ BACKEND + AUTH
   Sprint 3-4    │ Supabase + N8N + Sync

📅 SEMANAS 9-12  │████████│ WEB 4 PORTAIS
   Sprint 5-6    │ Admin + Gestor + Instrutor + Aluno

📅 SEMANAS 13-16 │████████│ BETA REAL
   Sprint 7-8    │ SPU + 20 voos + Treinamento

📅 SEMANAS 17-20 │████████│ HOMOLOGAÇÃO
   Sprint 9-10   │ ANAC + Security + Load Test

📅 SEMANAS 21-24 │████████│ PRODUÇÃO
   Sprint 11-12  │ Deploy + Go-Live 🚀
```

---

## ⚠️ RISCOS PRINCIPAIS (24 SEMANAS)

| # | Risco | Prob | Impacto | Mitigação |
|---|-------|------|---------|-----------|
| R1 | Burnout dev solo | 🟡 | 🔴 | Buffer 10% + breaks + sprint flex |
| R2 | SPU falha voo | 🟡 | 🔴 | Backup hardware + fallback mock |
| R3 | ANAC rejeita CIV | 🟡 | 🔴 | Validar antes + advogado + sandbox |
| R4 | WiFi instável | 🟢 | 🟡 | Offline-first + retry + logs |
| R5 | Scope creep | 🟡 | 🟡 | PO firme + MVP focus estrito |
| R6 | Beta adoption | 🟡 | 🟡 | Treinar bem + support ativo |
| R7 | Performance voo | 🟢 | 🟡 | Profile + testes reais cedo |
| R8 | Load test falha | 🟡 | 🔴 | Otimizar antes + Redis + índices |

### 🛡️ Mitigações Críticas

**Burnout (R1):**
- 10% buffer cada sprint
- Pomodoro 25/5
- 1h almoço obrigatório
- Sexta sprint planning (não dev)

**Hardware (R2):**
- 2 SPU backup
- Fallback mock sempre disponível
- Protocolo troubleshoot documentado

**ANAC (R3):**
- Validar sandbox 1 mês antes
- Consultor aviação civil
- Certificado ICP teste antecipado
- Buffer 2 semanas aprovação

**Scope Creep (R5):**
- MVP estrito: sem IA, sem voz, sem "extras"
- Change control: +1 feature = -1 feature
- Backlog pós-MVP documentado

---

## 🎯 RELEASES & VERSIONAMENTO

```
Sprint 1-2  → v0.1.0-alpha  (refactor interno)
Sprint 3-4  → v0.2.0-alpha  (backend + auth)
Sprint 5-6  → v0.3.0-beta   (4 portais funcionais)
Sprint 7-8  → v0.4.0-beta   (beta 20 voos reais)
Sprint 9-10 → v0.9.0-rc1    (ANAC homologado)
Sprint 11-12→ v1.0.0        🚀 PRODUÇÃO GO-LIVE
```

---

## 💡 STACK TECNOLÓGICA FINAL (CONFORME OVERVIEW)

### ✅ Mobile (Flutter)

```yaml
Framework: Flutter 3.16+
Linguagem: Dart 3.2+
Target: Android 8+ / iOS 13+ (tablets)

Packages core:
  - web_socket_channel: WebSocket SPU
  - sqflite: Database local (1 DB por voo)
  - hive: Cache rápido (config)
  - flutter_riverpod: State management
  - dio: HTTP client
  - flutter_map: Replay 2D (Leaflet)
  - battery_plus: Bateria tablet
  - supabase_flutter: Auth
  - camera: Fotos
  - pdf: Geração docs

Storage: 5GB necessário
```

---

### ✅ Backend

```yaml
Autenticação:
  - Supabase Auth (JWT)

Workflows:
  - N8N (self-hosted Docker)
  - Node.js 18+
  - 6 workflows MVP:
    1. Sync voo mobile → cloud
    2. CIV ANAC (sandbox → prod)
    3. Notificações email
    4. CIV retry logic
    5. Relatórios automáticos
    6. Backup diário

Database:
  - PostgreSQL 14+ (Supabase)
  - Redis cache

Storage:
  - S3 (fotos, PDFs, telemetria)

Hosting:
  - N8N: Railway (self-hosted)
  - Supabase: Cloud
  - Redis: Railway/Upstash
```

---

### ✅ Web (Next.js)

```yaml
Framework: Next.js 14 App Router
Linguagem: TypeScript 5+
UI: React 18 + Tailwind CSS

Features:
  - 4 Portais (admin, gestor, instrutor, aluno)
  - Live tracking 4G (mapa global)
  - Replay 2D telemetria (Leaflet)
  - CIV Digital visualização
  - Dashboards BI
  - Upload documentos

Hosting: Vercel
```

---

### ✅ Hardware (SPU SPU)

```yaml
Microcontrolador: SPU DevKit V1
7 Sensores:
  1. GPS NEO-M8M (10Hz → 20Hz interpolado)
  2. Barômetro BMP180 (altitude)
  3. Bússola HMC5883L (heading)
  4. Acelerômetro ADXL345
  5. Giroscópio L3G4200D
  6. IMU LSM6DS3 (redundância)
  7. Temperatura BMP180

Conexão:
  - WiFi AP: SSID "CODIGO-qfly-AP"
  - WebSocket: ws://192.168.4.1:81
  - Telemetria: 20Hz (50ms/pacote)
  - JSON UTF-8 (~700 bytes/pacote)

Calibração: Automática interna SPU
```

---

### ✅ Monitoramento & DevOps

```yaml
Crashes: Sentry
Monitoring: Grafana + Prometheus
Alertas: PagerDuty
Uptime: StatusPage
Logs: ELK Stack básico

CI/CD:
  - GitHub Actions
  - Deploy automático (Vercel + Railway)
  - Smoke tests

Backup:
  - 3x/dia automático
  - Redundância geográfica
  - Retenção 5 anos (ANAC)
```

---

## 🚫 O QUE **NÃO** ESTÁ NO MVP

**Pós-MVP (não fazer agora):**
- ❌ Inteligência Artificial / IA Generativa
- ❌ Comandos de voz / Speech
- ❌ Análise automática ML
- ❌ Portal aluno mobile nativo
- ❌ EAD integrado
- ❌ Áudio/vídeo cockpit
- ❌ Chat tempo real
- ❌ Gamificação (conquistas)
- ❌ Multi-idioma
- ❌ PWA
- ❌ Particionamento database
- ❌ Simulador integrado

**Justificativa:** MVP deve validar core value:
> "Telemetria real + CIV automático ANAC"

Resto é feature pós-validação.

---

## 🔧 N8N - O QUE ELE FAZ NO PROJETO

**N8N = Workflow Automation** (tipo Zapier/Make mas self-hosted)

### ✅ Casos de Uso no MVP

**1. Sync Voo Mobile → Cloud**
```
Trigger: Webhook mobile envia voo completo
├─ Validar JSON
├─ Salvar PostgreSQL (voos, telemetria)
├─ Upload S3 (fotos, PDFs)
├─ Atualizar cache Redis
└─ Notificar instrutor (email)
```

**2. CIV ANAC Automático**
```
Trigger: Voo finalizado + avaliado
├─ Montar XML CIV (padrão ANAC)
├─ Assinar digitalmente (ICP-Brasil)
├─ Enviar API ANAC
├─ Retry se falhar (exponential backoff)
├─ Salvar comprovante
└─ Notificar status
```

**3. Notificações**
```
Trigger: Eventos diversos
├─ Email (SendGrid/Resend)
├─ WhatsApp (Twilio opcional)
└─ Push notification (Firebase)
```

**4. Relatórios Automáticos**
```
Trigger: Cron diário/semanal
├─ Query agregação PostgreSQL
├─ Gerar PDF (Puppeteer)
├─ Enviar gestores
└─ Salvar histórico
```

**5. Backup Diário**
```
Trigger: Cron 3x/dia
├─ Dump PostgreSQL
├─ Compactar
├─ Upload S3 geo-redundante
└─ Notificar sucesso/erro
```

**6. Live Tracking 4G**
```
Trigger: WebSocket mobile envia GPS
├─ Validar coordenadas
├─ Atualizar Redis (posição real-time)
├─ Broadcast web portais
└─ Salvar trail PostgreSQL
```

### ❌ N8N NÃO Faz

- ❌ Inteligência Artificial / ML
- ❌ Análise complexa de dados
- ❌ Processamento pesado
- ❌ Hosting do app
- ❌ Database primário

**N8N é orquestrador, não processador.**

---

## 📞 COMUNICAÇÃO & RITUAIS

### 📧 Reports Quinzenais
```
🎯 Sprint X | Semanas Y-Z
✅ Completado: X/35 SP (Z%)
📊 Velocidade: X SP
🐛 Bugs: P0=0 P1=X
🎉 Wins: [top 2]
🚨 Bloqueios: [se houver]
📅 Next: [foco sprint]
```

### 🎯 Retrospectiva (fim sprint)
- ✅ O que funcionou
- ❌ O que falhou
- 🔄 Ajustes próxima
- 📊 Velocidade real vs esperada

---

## 🎉 CONCLUSÃO

### ✨ TL;DR

**24 semanas** para MVP production-ready:

**MÊS 1-2** → Refatoração mobile + testes + offline  
**MÊS 3** → Backend Supabase + N8N + 4 portais web  
**MÊS 4** → Beta 20 voos reais + SPU  
**MÊS 5** → Homologação ANAC + security  
**MÊS 6** → Deploy produção + go-live aeroclube

### 🎯 Entregáveis Concretos

**Fim 6 Meses:**
- ✅ Mobile offline-first (Flutter)
- ✅ SPU 20Hz telemetria real
- ✅ 4 portais web (Next.js)
- ✅ Backend Supabase + N8N 6 workflows
- ✅ CIV ANAC homologado produção
- ✅ 20+ voos reais validados
- ✅ Aeroclube piloto ativo
- ✅ 50+ voos produção
- ✅ 10+ instrutores treinados
- ✅ NPS ≥40
- ✅ 99.9% uptime
- ✅ Cobertura testes ≥70%
- ✅ Zero bugs P0

### 🚀 Próximos Passos

1. ✅ **Aprovar plano** (stakeholders)
2. ✅ **Sprint 0** (setup ambiente dev)
3. ✅ **Kickoff Sprint 1** (refatoração)
4. 🏃‍♂️ **Executar sem distração!**

### ⚠️ Lembrete Crítico

**NÃO adicionar "features legais" no meio:**
- ❌ "Que tal IA pra..."
- ❌ "Podemos colocar voz..."
- ❌ "E se fizéssemos..."

**Foco LASER no MVP:**
> "Telemetria SPU 20Hz + CIV ANAC automático"

Todo resto é pós-MVP. **Period.**

---

**Bora codar!** 💪⚡

**📊 Tokens restantes: ~127.000** 🎯