# 🏗️ ARQUITETURA UML - AVIÔNICA MVP

**📅 Data:** 06/11/2025  
**🎯 Propósito:** Visão macro de componentes e integrações  
**👥 Audiência:** CTO, Arquitetos, Tech Leads

---

## 📑 ÍNDICE

1. [🎨 Diagrama de Componentes - Nível 1 (Macro)](#-diagrama-de-componentes---nível-1-macro)
2. [📊 Diagrama de Classes - Entidades Principais](#-diagrama-de-classes---entidades-principais)
3. [🔄 Diagrama de Deployment](#-diagrama-de-deployment)
4. [📡 Fluxo de Dados - Visão Geral](#-fluxo-de-dados---visão-geral)
5. [🔐 Camadas de Segurança](#-camadas-de-segurança)
6. [📈 Escalabilidade - Estratégia](#-escalabilidade---estratégia)
7. [🎯 Decisões Arquiteturais - Chaves](#-decisões-arquiteturais---chaves)
8. [🔧 Tecnologias - Stack Completo](#-tecnologias---stack-completo)
9. [📊 Métricas de Sucesso - KPIs](#-métricas-de-sucesso---kpis)
10. [✅ Checklist Implementação (6 meses / 12 sprints)](#-checklist-implementação)
11. [🎓 Referências Arquiteturais](#-referências-arquiteturais)

---

## 🎨 DIAGRAMA DE COMPONENTES - NÍVEL 1 (MACRO)

```mermaid
graph TB
    subgraph HARDWARE["🛩️ HARDWARE LAYER"]
        ESP32["⚙️ ESP32 SPU<br/>───────────<br/>7 Sensores<br/>GPS 20Hz<br/>WiFi AP<br/>Telemetria"]
    end

    subgraph MOBILE["📱 MOBILE LAYER"]
        FLUTTER["📲 Flutter App<br/>───────────<br/>Offline-First<br/>SQLite Local<br/>Sixpack Digital<br/>Avaliação FAP"]
    end

    subgraph BACKEND["☁️ BACKEND LAYER"]
        SUPABASE["🔐 Supabase Auth<br/>───────────<br/>JWT + RLS<br/>PostgreSQL 14<br/>Storage S3"]
        
        N8N["⚡ N8N Workflows<br/>───────────<br/>8 Automações<br/>CIV ANAC<br/>Notificações<br/>Logs"]
        
        REDIS["⚡ Redis Cache<br/>───────────<br/>Live Tracking<br/>WebSocket Pub<br/>TTL 60s"]
    end

    subgraph WEB["🌐 WEB LAYER"]
        NEXTJS["🖥️ Next.js 14<br/>───────────<br/>4 Portais<br/>SSR + ISR<br/>Replay 2D<br/>Dashboards BI"]
    end

    subgraph EXTERNAL["🌍 INTEGRAÇÕES"]
        ANAC["📋 ANAC API<br/>───────────<br/>CIV Digital<br/>ICP-Brasil<br/>24h SLA"]
        
        SMS["📲 SMS/Email<br/>───────────<br/>Notificações<br/>Alertas<br/>2FA"]
    end

    %% Conexões Hardware → Mobile
    ESP32 -->|"WebSocket<br/>ws://192.168.4.1:81<br/>JSON 20Hz"| FLUTTER

    %% Conexões Mobile → Backend
    FLUTTER -->|"WiFi/4G Sync<br/>REST API<br/>HTTPS"| SUPABASE
    FLUTTER -->|"Live Track<br/>4G opcional<br/>WebSocket"| REDIS

    %% Conexões Backend Internas
    SUPABASE -->|"Triggers<br/>Webhooks"| N8N
    N8N -->|"Cache Inval<br/>Pub/Sub"| REDIS
    N8N -->|"DB Write<br/>SQL"| SUPABASE

    %% Conexões Web → Backend
    NEXTJS -->|"Auth JWT<br/>API REST<br/>HTTPS"| SUPABASE
    NEXTJS -->|"Live Data<br/>WebSocket<br/>Subscribe"| REDIS

    %% Integrações Externas
    N8N -->|"XML Assindo<br/>ICP-Brasil<br/>HTTPS"| ANAC
    N8N -->|"Twilio/SMTP<br/>Templates"| SMS

    %% Estilos
    classDef hardware fill:#e74c3c,stroke:#c0392b,color:#fff
    classDef mobile fill:#3498db,stroke:#2980b9,color:#fff
    classDef backend fill:#2ecc71,stroke:#27ae60,color:#fff
    classDef web fill:#9b59b6,stroke:#8e44ad,color:#fff
    classDef external fill:#f39c12,stroke:#e67e22,color:#fff

    class ESP32 hardware
    class FLUTTER mobile
    class SUPABASE,N8N,REDIS backend
    class NEXTJS web
    class ANAC,SMS external
```

---

## 📊 DIAGRAMA DE CLASSES - ENTIDADES PRINCIPAIS

```mermaid
classDiagram
    class Usuario {
        +UUID id
        +String email
        +String tipo_usuario
        +String canac
        +String nome_completo
        +Boolean ativo
        +auth()
        +verificarPermissoes()
    }

    class Aeroclube {
        +UUID id
        +String codigo_anac
        +String razao_social
        +String cnpj
        +JSON endereco
        +String status
        +calcularEstatisticas()
    }

    class Aluno {
        +UUID id
        +UUID usuario_id
        +UUID aeroclube_id
        +String tipo_licenca
        +Integer horas_voadas
        +Date validade_cma
        +verificarDocumentos()
        +calcularProgresso()
    }

    class Instrutor {
        +UUID id
        +UUID usuario_id
        +String cht_numero
        +Date validade_cht
        +Boolean ativo_instrucao
        +avaliarAluno()
        +aprovarVoo()
    }

    class Aeronave {
        +UUID id
        +UUID aeroclube_id
        +String matricula
        +String modelo
        +String codigo_esp32
        +Boolean ativa
        +verificarManutencao()
    }

    class Voo {
        +UUID id
        +UUID aluno_id
        +UUID instrutor_id
        +UUID aeronave_id
        +Timestamp inicio
        +Timestamp fim
        +Integer duracao
        +String tipo_voo
        +calcularTelemetria()
        +gerarCIV()
    }

    class Telemetria {
        +UUID id
        +UUID voo_id
        +Timestamp timestamp
        +JSON gps_data
        +JSON sensor_data
        +analisarPerformance()
    }

    class AvaliacaoFAP {
        +UUID id
        +UUID voo_id
        +JSON items_avaliados
        +Integer nota_final
        +String observacoes
        +calcularMedia()
    }

    class CIVDigital {
        +UUID id
        +UUID voo_id
        +String numero_civ
        +Timestamp enviado_anac
        +String status_anac
        +String xml_assinado
        +enviarANAC()
        +validarAssinatura()
    }

    %% Relacionamentos
    Usuario "1" --> "0..1" Aluno
    Usuario "1" --> "0..1" Instrutor
    Aeroclube "1" --> "*" Aluno
    Aeroclube "1" --> "*" Instrutor
    Aeroclube "1" --> "*" Aeronave
    Aluno "1" --> "*" Voo
    Instrutor "1" --> "*" Voo
    Aeronave "1" --> "*" Voo
    Voo "1" --> "*" Telemetria
    Voo "1" --> "0..1" AvaliacaoFAP
    Voo "1" --> "0..1" CIVDigital
```

---

## 🔄 DIAGRAMA DE DEPLOYMENT

```mermaid
graph TB
    subgraph EDGE["🌐 EDGE / CLIENT"]
        TABLET["📱 Tablet Android/iOS<br/>Flutter 3.16+<br/>SQLite + Cache<br/>Offline-First"]
        
        BROWSER["🖥️ Browser<br/>Chrome/Safari/Edge<br/>React 18<br/>WebSocket Client"]
    end

    subgraph CLOUD["☁️ CLOUD INFRASTRUCTURE"]
        subgraph COMPUTE["⚡ Compute Layer"]
            WEBAPP["Next.js Server<br/>──────────<br/>Vercel/Railway<br/>Node.js 18<br/>SSR + API Routes"]
            
            N8N_SERVER["N8N Instance<br/>──────────<br/>Docker Compose<br/>Self-hosted<br/>8 Workflows"]
        end

        subgraph DATA["💾 Data Layer"]
            POSTGRES["PostgreSQL 14<br/>──────────<br/>Supabase<br/>25+ Tables<br/>PostGIS"]
            
            REDIS_SERVER["Redis 7<br/>──────────<br/>Cloud/Self<br/>Pub/Sub<br/>Cache TTL"]
            
            S3["Object Storage<br/>──────────<br/>S3/Supabase<br/>Fotos + PDFs<br/>Backup 3x/dia"]
        end

        subgraph MONITOR["📊 Observability"]
            LOGS["Logs<br/>──────────<br/>Winston/Pino<br/>Structured JSON"]
            
            METRICS["Metrics<br/>──────────<br/>Prometheus<br/>Grafana"]
        end
    end

    subgraph EXTERNAL_SVC["🌍 External Services"]
        ANAC_API["ANAC API<br/>──────────<br/>XML SOAP<br/>ICP-Brasil<br/>Gov.br"]
        
        COMM["Communications<br/>──────────<br/>Twilio SMS<br/>SendGrid Email"]
    end

    %% Client → Cloud
    TABLET -->|"HTTPS<br/>REST + WS"| WEBAPP
    BROWSER -->|"HTTPS<br/>SSR + API"| WEBAPP

    %% Cloud Internal
    WEBAPP -->|"Auth + Query"| POSTGRES
    WEBAPP -->|"Live Sync"| REDIS_SERVER
    
    N8N_SERVER -->|"Automation"| POSTGRES
    N8N_SERVER -->|"Cache"| REDIS_SERVER
    N8N_SERVER -->|"Upload"| S3
    
    WEBAPP -->|"Static Files"| S3
    
    %% Monitoring
    WEBAPP -.->|"Winston"| LOGS
    N8N_SERVER -.->|"Logs"| LOGS
    POSTGRES -.->|"Metrics"| METRICS
    REDIS_SERVER -.->|"Metrics"| METRICS

    %% External
    N8N_SERVER -->|"CIV XML"| ANAC_API
    N8N_SERVER -->|"Notify"| COMM

    %% Styles
    classDef edge fill:#3498db,stroke:#2980b9,color:#fff
    classDef compute fill:#2ecc71,stroke:#27ae60,color:#fff
    classDef data fill:#e74c3c,stroke:#c0392b,color:#fff
    classDef monitor fill:#95a5a6,stroke:#7f8c8d,color:#fff
    classDef external fill:#f39c12,stroke:#e67e22,color:#fff

    class TABLET,BROWSER edge
    class WEBAPP,N8N_SERVER compute
    class POSTGRES,REDIS_SERVER,S3 data
    class LOGS,METRICS monitor
    class ANAC_API,COMM external
```

---

## 📡 FLUXO DE DADOS - VISÃO GERAL

```mermaid
flowchart LR
    A["⚙️ ESP32<br/>Sensores"] -->|"JSON<br/>20Hz"| B["📱 Tablet<br/>SQLite"]
    
    B -->|"Offline<br/>Storage"| C[("💾 Local DB<br/>5GB")]
    
    C -->|"WiFi/4G<br/>Sync"| D["☁️ Backend<br/>PostgreSQL"]
    
    D -->|"Process<br/>N8N"| E["📋 CIV<br/>ANAC"]
    
    D -->|"WebSocket<br/>Live"| F["🖥️ Web App<br/>Portais"]
    
    F -->|"View<br/>Replay"| G["🗺️ Mapa 2D<br/>Leaflet"]
    
    D -->|"Analytics"| H["📊 BI<br/>Dashboards"]

    style A fill:#e74c3c,color:#fff
    style B fill:#3498db,color:#fff
    style C fill:#34495e,color:#fff
    style D fill:#2ecc71,color:#fff
    style E fill:#f39c12,color:#fff
    style F fill:#9b59b6,color:#fff
    style G fill:#1abc9c,color:#fff
    style H fill:#e67e22,color:#fff
```

---

## 🔐 CAMADAS DE SEGURANÇA

```mermaid
graph TB
    subgraph USERS["👥 Camada Usuário"]
        U1["Admin"]
        U2["Gestor"]
        U3["Instrutor"]
        U4["Aluno"]
    end

    subgraph AUTH["🔐 Camada Autenticação"]
        JWT["JWT Token<br/>───────<br/>RS256<br/>15min expire<br/>Refresh 7d"]
        
        RLS["Row Level Security<br/>───────<br/>PostgreSQL<br/>Context-aware<br/>Role-based"]
    end

    subgraph AUTHOR["🛡️ Camada Autorização"]
        RBAC["RBAC Rules<br/>───────<br/>4 Roles<br/>50+ Policies<br/>Hierarquia"]
        
        POLICY["DB Policies<br/>───────<br/>Supabase<br/>Auto-enforce<br/>SQL Level"]
    end

    subgraph DATA["💾 Camada Dados"]
        ENCRYPT["Encryption<br/>───────<br/>AES-256 rest<br/>TLS 1.3 transit<br/>Sensitive fields"]
        
        AUDIT["Audit Logs<br/>───────<br/>WHO WHAT WHEN<br/>Immutable<br/>5yr retention"]
    end

    %% Fluxo
    U1 & U2 & U3 & U4 --> JWT
    JWT --> RLS
    RLS --> RBAC
    RBAC --> POLICY
    POLICY --> ENCRYPT
    ENCRYPT --> AUDIT

    %% Styles
    classDef user fill:#3498db,color:#fff
    classDef auth fill:#2ecc71,color:#fff
    classDef authz fill:#f39c12,color:#fff
    classDef data fill:#e74c3c,color:#fff

    class U1,U2,U3,U4 user
    class JWT,RLS auth
    class RBAC,POLICY authz
    class ENCRYPT,AUDIT data
```

---

## 📈 ESCALABILIDADE - ESTRATÉGIA

```mermaid
graph LR
    subgraph MVP["🎯 MVP (6 meses)"]
        M1["1 Aeroclube<br/>50 Alunos<br/>5k Voos/ano"]
    end

    subgraph PHASE2["📈 Fase 2 (12m)"]
        P2["5 Aeroclubes<br/>250 Alunos<br/>25k Voos/ano"]
    end

    subgraph PHASE3["🚀 Fase 3 (24m)"]
        P3["15 Aeroclubes<br/>750 Alunos<br/>75k Voos/ano"]
    end

    subgraph SCALE["💪 Scale Ready"]
        S1["100 Aeroclubes<br/>5k Alunos<br/>500k Voos/ano<br/>───────<br/>Particionamento<br/>Read Replicas<br/>CDN Global<br/>Multi-region"]
    end

    M1 -->|"Validação"| P2
    P2 -->|"Crescimento"| P3
    P3 -->|"Expansão"| S1

    style M1 fill:#3498db,color:#fff
    style P2 fill:#2ecc71,color:#fff
    style P3 fill:#f39c12,color:#fff
    style S1 fill:#e74c3c,color:#fff
```

---

## 🎯 DECISÕES ARQUITETURAIS - CHAVES

| # | Decisão | Alternativa Rejeitada | Justificativa |
|---|---------|----------------------|---------------|
| **1** | 🔐 **Supabase Auth** | Auth0, Firebase Auth | Open-source, PostgreSQL native, RLS automático |
| **2** | ⚡ **N8N Workflows** | Zapier, Make | Self-hosted, sem limites, visual, barato |
| **3** | 📱 **Flutter Mobile** | React Native, Native | Single codebase, performance, offline-first |
| **4** | 🖥️ **Next.js Web** | Vue/Nuxt, SvelteKit | SEO, SSR/ISR, React ecosystem, Vercel |
| **5** | 💾 **PostgreSQL** | MongoDB, MySQL | Relacional, PostGIS, Supabase, ACID |
| **6** | ⚡ **Redis Cache** | Memcached, In-memory | Pub/Sub, estruturas avançadas, persistência |
| **7** | 🗺️ **Leaflet 2D** | Cesium 3D, Mapbox GL | Leve, offline, tiles gratuitos, suficiente MVP |
| **8** | ☁️ **Vercel Deploy** | AWS, GCP, Azure | DX excelente, CI/CD automático, edge network |

---

## 🔧 TECNOLOGIAS - STACK COMPLETO

### 🎨 Frontend

```yaml
Mobile:
  • Flutter 3.16+ (Dart 3.2)
  • Packages: 15+ essenciais
  • Target: Android 8+ / iOS 13+
  • Size: ~50MB APK

Web:
  • Next.js 14 (React 18)
  • TypeScript 5+
  • TailwindCSS 3
  • shadcn/ui components
  • Chart.js + Recharts
  • Leaflet 2D maps
```

### ⚙️ Backend

```yaml
Runtime:
  • Node.js 18 LTS
  • N8N (self-hosted)
  • Docker Compose

Database:
  • PostgreSQL 14 (Supabase)
  • PostGIS (geo)
  • Redis 7 (cache)

Storage:
  • S3 / Supabase Storage
  • ~10GB/aeroclube/mês
```

### 🛠️ DevOps

```yaml
CI/CD:
  • GitHub Actions
  • Vercel (auto-deploy)
  • Docker (N8N)

Monitoring:
  • Sentry (errors)
  • Prometheus (metrics)
  • Grafana (dashboards)
  • Winston (logs)

Testing:
  • Jest (unit)
  • Playwright (e2e)
  • Flutter test
```

---

## 📊 MÉTRICAS DE SUCESSO - KPIs

```mermaid
mindmap
  root((📊 KPIs))
    Técnicos
      Uptime 99.9%
      Latência API <200ms
      Telemetria 20Hz
      Sync <5min
    Negócio
      50 Alunos ativos
      500 Voos/mês
      CIV 24h compliance
      NPS >50
    UX
      Offline 100%
      Crash rate <0.1%
      Load time <2s
      Mobile 60fps
    Operacional
      Backup 3x/dia
      Recovery <1h
      Logs 30d retention
      Support <4h SLA
```

---

## ✅ CHECKLIST IMPLEMENTAÇÃO

**⏱️ Timeline Total:** 6 meses (24 semanas)  
**🎯 Objetivo:** MVP em produção com 1 aeroclube piloto  
**👥 Time:** 3 Devs + 1 QA

---

### 📅 FASE 1: DESENVOLVIMENTO MVP (Meses 1-3)

#### Sprint 1-2 (Semanas 1-4) - Fundação
**🎯 Objetivo:** Infraestrutura base + protótipo funcional

**☁️ Backend:**
- [ ] Setup Supabase projeto + Auth (JWT + RLS)
- [ ] PostgreSQL: 25 tabelas criadas + migrations
- [ ] N8N: Setup Docker Compose self-hosted
- [ ] N8N: 3 workflows iniciais (sync, logs, notificações)
- [ ] Redis: Setup + config Pub/Sub
- [ ] API REST: 10 endpoints base (CRUD)

**📱 Mobile:**
- [ ] Flutter scaffold + estrutura pastas
- [ ] Tela: Login/Auth (email + senha)
- [ ] Tela: Dashboard instrutor (home)
- [ ] WebSocket: Conectar ESP32 test (mock data)
- [ ] SQLite: Setup local database
- [ ] Hive: Cache configuração

**🖥️ Web:**
- [ ] Next.js scaffold + TypeScript
- [ ] Página: Login admin/gestor
- [ ] Auth: Supabase integration
- [ ] Layout: Sidebar + header base

---

#### Sprint 3-4 (Semanas 5-8) - Features Core Mobile
**🎯 Objetivo:** App instrutor funcional offline

**☁️ Backend:**
- [ ] N8N: Workflow sync voo completo
- [ ] N8N: Workflow CIV ANAC (sandbox)
- [ ] API: POST /voos/sync (multipart)
- [ ] API: GET /voos/:id/telemetria
- [ ] Storage S3: Upload fotos + PDFs

**📱 Mobile:**
- [ ] Tela: Selecionar aluno (lista offline)
- [ ] Tela: Selecionar aeronave (lista offline)
- [ ] Tela: Plano de voo (upload PDF)
- [ ] Tela: Sixpack digital (6 instrumentos tempo real)
- [ ] Tela: Iniciar/finalizar voo
- [ ] Feature: Gravação telemetria local (SQLite)
- [ ] Feature: Offline-first completo
- [ ] Feature: Monitoramento bateria tablet

**🖥️ Web:**
- [ ] Portal Gestor: Dashboard estatísticas
- [ ] Portal Gestor: CRUD alunos
- [ ] Portal Gestor: CRUD instrutores
- [ ] Portal Gestor: CRUD aeronaves

---

#### Sprint 5-6 (Semanas 9-12) - Features Core Web + Avaliação
**🎯 Objetivo:** Avaliação FAP + CIV + Portais Web

**☁️ Backend:**
- [ ] N8N: Workflow CIV retry automático (3x)
- [ ] N8N: Workflow email notificações
- [ ] N8N: Workflow SMS alertas
- [ ] API: POST /avaliacoes-fap
- [ ] API: GET /civ-digital/:voo_id

**📱 Mobile:**
- [ ] Tela: Checklist digital (15 items)
- [ ] Tela: Fotos checklist (câmera + galeria)
- [ ] Tela: Avaliação FAP (8 categorias + notas)
- [ ] Tela: Assinatura digital (canvas)
- [ ] Tela: Diário de bordo (logs texto)
- [ ] Feature: Sincronização WiFi/4G
- [ ] Feature: Live tracking 4G (opcional)

**🖥️ Web:**
- [ ] Portal Admin: Dashboard global
- [ ] Portal Admin: Lista aeroclubes (CRUD)
- [ ] Portal Admin: Métricas avançadas (BI)
- [ ] Portal Admin: Live tracking global
- [ ] Portal Instrutor: Meus voos (lista)
- [ ] Portal Instrutor: Visualizar avaliação
- [ ] Portal Aluno: Meus voos (simplificado)
- [ ] Portal Aluno: CIV download
- [ ] Feature: Replay 2D Leaflet (mapa + timeline)

---

### 📅 FASE 2: VALIDAÇÃO + PRODUÇÃO (Meses 4-6)

#### Sprint 7-8 (Semanas 13-16) - Beta Testing Real
**🎯 Objetivo:** Aeroclube piloto usando sistema real

**🛩️ Hardware:**
- [ ] Montar 2 unidades ESP32 SPU completas
- [ ] Instalar em 2 aeronaves piloto
- [ ] Testar sensores (calibração + accuracy)
- [ ] Criar manual instalação hardware

**📱 Mobile + 🖥️ Web:**
- [ ] Bugs críticos corrigidos (P0/P1)
- [ ] UX refinamentos (feedback beta)
- [ ] Performance otimização (< 2s load)
- [ ] Crash rate < 0.1%

**👥 Operacional:**
- [ ] Treinar 3 instrutores aeroclube piloto
- [ ] Treinar 1 gestor aeroclube
- [ ] Acompanhar 20 voos reais
- [ ] Coletar feedback estruturado (form)
- [ ] Ajustar features baseado em feedback

**📊 Métricas Beta:**
- [ ] 50+ voos gravados
- [ ] 10+ alunos cadastrados
- [ ] 20+ CIV gerados (sandbox)
- [ ] NPS beta > 40

---

#### Sprint 9-10 (Semanas 17-20) - Homologação ANAC + Security
**🎯 Objetivo:** Compliance regulatório + segurança

**📋 ANAC:**
- [ ] Documentação técnica completa
- [ ] Certificado ICP-Brasil (produção)
- [ ] CIV sandbox → produção (migração)
- [ ] Testes conformidade RBAC 141
- [ ] Protocolo 24h SLA validado
- [ ] Homologação ANAC aprovada ✅

**🔒 Security:**
- [ ] Audit logs implementado (5yr retention)
- [ ] Penetration testing (terceirizado)
- [ ] LGPD compliance checklist
- [ ] Criptografia AES-256 (dados sensíveis)
- [ ] Backup geo-redundante (3x/dia)
- [ ] Disaster recovery testado (RTO < 1h)

**⚡ Performance:**
- [ ] Load testing: 1000 concurrent users
- [ ] Stress testing: 10k voos/mês
- [ ] Telemetria: 20Hz sem perda (99%+)
- [ ] API latency: p95 < 200ms
- [ ] Uptime: 99.9% comprovado (30d)

---

#### Sprint 11-12 (Semanas 21-24) - Produção + Go-Live
**🎯 Objetivo:** Sistema estável em produção

**🚀 Deploy Produção:**
- [ ] Vercel: Web app produção
- [ ] Railway: N8N produção
- [ ] Supabase: Database produção
- [ ] Redis: Cache produção
- [ ] S3: Storage produção
- [ ] CI/CD: GitHub Actions (auto-deploy)

**📊 Monitoring:**
- [ ] Sentry: Error tracking live
- [ ] Prometheus: Metrics collection
- [ ] Grafana: Dashboards 24/7
- [ ] PagerDuty: Alertas on-call
- [ ] StatusPage: Status público

**👥 Onboarding:**
- [ ] Manual instrutor completo (PDF + vídeos)
- [ ] Manual gestor completo
- [ ] FAQ + troubleshooting
- [ ] Suporte: Email + WhatsApp (4h SLA)
- [ ] Treinamento remoto (2h/aeroclube)

**📈 Go-Live:**
- [ ] Aeroclube piloto: Produção ativa
- [ ] Marketing: Landing page + materiais
- [ ] Vendas: Pitch deck + proposta comercial
- [ ] 🎉 **MVP OFICIAL EM PRODUÇÃO**

---

### 📊 RESUMO CRONOGRAMA 6 MESES

```
┌─────────────────────────────────────────────────────────────────┐
│  MÊS 1-2: Sprint 1-4  │  Fundação + Core Mobile                 │
│  ├─ Backend base      │  ├─ Offline-first                       │
│  ├─ Mobile scaffold   │  ├─ Sixpack digital                    │
│  └─ Web base          │  └─ Avaliação FAP                       │
├─────────────────────────────────────────────────────────────────┤
│  MÊS 3: Sprint 5-6    │  Core Web + Integração                  │
│  ├─ CIV ANAC         │  ├─ Replay 2D                           │
│  ├─ 4 Portais web    │  ├─ Live tracking                       │
│  └─ Sync completo    │  └─ MVP funcional ✅                     │
├─────────────────────────────────────────────────────────────────┤
│  MÊS 4: Sprint 7-8    │  Beta Testing Real                      │
│  ├─ Hardware install │  ├─ 20 voos reais                       │
│  ├─ Treinar users    │  ├─ Coletar feedback                    │
│  └─ Bug fixing       │  └─ UX refinamento                       │
├─────────────────────────────────────────────────────────────────┤
│  MÊS 5: Sprint 9-10   │  Homologação + Security                 │
│  ├─ ANAC produção    │  ├─ Pen testing                         │
│  ├─ Load testing     │  ├─ LGPD compliance                     │
│  └─ DR testing       │  └─ Audit logs                          │
├─────────────────────────────────────────────────────────────────┤
│  MÊS 6: Sprint 11-12  │  Produção + Go-Live                     │
│  ├─ Deploy prod      │  ├─ Monitoring 24/7                     │
│  ├─ Onboarding       │  ├─ Suporte setup                       │
│  └─ 🎉 GO-LIVE        │  └─ Marketing/vendas                    │
└─────────────────────────────────────────────────────────────────┘
```

---

### 🎯 MILESTONES CRÍTICOS

| Semana | Milestone | Critério Sucesso |
|--------|-----------|------------------|
| **4** | 🎯 Protótipo Mobile | Conecta ESP32 + grava telemetria local |
| **8** | 🎯 MVP Offline Funcional | Voo completo offline sem bugs críticos |
| **12** | 🎯 MVP Completo | 4 portais + CIV ANAC + Replay 2D |
| **16** | 🎯 Beta Validado | 50 voos reais + NPS > 40 |
| **20** | 🎯 Homologação ANAC | CIV produção aprovado |
| **24** | 🎉 **GO-LIVE PRODUÇÃO** | 1 aeroclube ativo pagante |

---

### 👥 RECURSOS NECESSÁRIOS

**Time Core:**
- 1x Dev Full-Stack (Backend + N8N + DevOps)
- 1x Dev Mobile (Flutter expert)
- 1x Dev Frontend (Next.js + React)
- 1x QA (testes E2E + homologação)

**Tempo Parcial:**
- 1x UI/UX Designer (sprints 1-6, 30%)
- 1x DevOps (sprints 9-12, 50%)
- 1x Advogado (ANAC + LGPD, sprints 9-10)

**Custo Estimado 6 Meses:**
```yaml
Salários: R$ 180.000 (3 devs + 1 QA)
Infra cloud: R$ 3.600 (R$ 600/mês)
Ferramentas: R$ 6.000 (licenças/SaaS)
Hardware: R$ 4.800 (2 ESP32 completos)
Terceiros: R$ 15.000 (pen test + legal)
────────────────────────────────────
TOTAL: ~R$ 210.000 (MVP completo)
```

---

## 🎓 REFERÊNCIAS ARQUITETURAIS

**Padrões Aplicados:**
- 🏗️ **Clean Architecture** (Robert C. Martin)
- 🔷 **Domain-Driven Design** (Eric Evans)
- ⚡ **Event-Driven Architecture** (webhooks/triggers)
- 🎯 **CQRS Light** (read/write separation)
- 🛡️ **Security by Design** (OWASP Top 10)

**Inspirações:**
- 📊 **Flightradar24** (live tracking)
- 🎮 **Strava** (replay + análise)
- 📚 **Notion** (offline-first)
- 🏥 **Epic Systems** (regulatório healthcare)

---

**✅ DIAGRAMA COMPLETO**  
**📊 Tokens restantes:** ~161.000  
**⏭️ Próximo:** Diagramas de Sequência