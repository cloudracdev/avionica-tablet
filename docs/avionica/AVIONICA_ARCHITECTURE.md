# ARQUITETURA COMPLETA - Sistema Aviônica

**Sistema:** Plataforma End-to-End de Gestão de Instrução Aeronáutica  
**Arquitetura:** Microserviços + Cloud + IoT + Mobile  
**Data:** 04/11/2025

---

## 📐 ARQUITETURA GERAL

```
┌──────────────────────────────────────────────────────────────────┐
│                        CAMADA 4: USUÁRIOS                        │
│  Aluno (Mobile) | Instrutor (Tablet) | Gestor (Web) | Admin     │
└────────────┬──────────────────────────────────────┬──────────────┘
             │                                       │
     ┌───────▼──────────┐                  ┌────────▼────────────┐
     │  CAMADA 3: APPS  │                  │   CAMADA 3: WEB     │
     │                  │                  │                      │
     │  Flutter App     │                  │   React + Next.js   │
     │  - Sixpack       │                  │   - Central Monitor │
     │  - Gestão Voo    │                  │   - Gestão Acadêmica│
     │  - Offline-first │                  │   - EAD (Moodle)    │
     └────────┬─────────┘                  │   - E-commerce      │
              │                            └──────────┬──────────┘
              │ REST API + WebSocket                 │ REST API
              │                                       │
     ┌────────▼───────────────────────────────────────▼──────────┐
     │              CAMADA 2: BACKEND CLOUD                      │
     │                                                            │
     │  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐│
     │  │ API Gateway  │  │ Auth Service │  │ Storage Service ││
     │  └──────┬───────┘  └──────┬───────┘  └────────┬────────┘│
     │         │                  │                    │         │
     │  ┌──────▼───────┐  ┌──────▼───────┐  ┌────────▼────────┐│
     │  │Flight Service│  │User Service  │  │Telemetry Service││
     │  └──────┬───────┘  └──────┬───────┘  └────────┬────────┘│
     │         │                  │                    │         │
     │  ┌──────▼──────────────────▼────────────────────▼──────┐ │
     │  │          PostgreSQL + Redis + S3/Blob              │ │
     │  └────────────────────────────────────────────────────┘ │
     └──────────────────────────┬────────────────────────────────┘
                                │ 4G/WiFi/GPRS
     ┌──────────────────────────▼────────────────────────────────┐
     │              CAMADA 1: HARDWARE (IoT)                     │
     │                                                            │
     │  ┌──────────────────────────────────────────────────────┐│
     │  │  SPU (Sensor Processing Unit) - na aeronave          ││
     │  │  - ARM Cortex M4 @ 64MHz                             ││
     │  │  - Sensores: GPS, IMU, Barômetro, etc                ││
     │  │  - Conectividade: 4G, WiFi, Bluetooth                ││
     │  │  - Áudio + Vídeo                                     ││
     │  └──────────────────────────────────────────────────────┘│
     └────────────────────────────────────────────────────────────┘
```

---

## 🧩 COMPONENTES PRINCIPAIS

### 1. HARDWARE SPU

**Arquitetura Embarcada:**

```
┌───────────────────────────────────────────────┐
│         CPU ARM Cortex M4 @ 64MHz             │
│              1 MB Flash                       │
├───────────────────────────────────────────────┤
│  SENSORES (I2C/SPI Bus)                      │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐ │
│  │   GPS    │  │   IMU    │  │ Barômetro  │ │
│  │ (UART)   │  │(LSM9DS1) │  │  (BMP280)  │ │
│  └──────────┘  └──────────┘  └────────────┘ │
├───────────────────────────────────────────────┤
│  CONECTIVIDADE                                │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐ │
│  │  4G LTE  │  │  WiFi    │  │ Bluetooth  │ │
│  │ (SIM800) │  │(ESP32-C3)│  │  (BLE 5.0) │ │
│  └──────────┘  └──────────┘  └────────────┘ │
├───────────────────────────────────────────────┤
│  ÁUDIO/VÍDEO                                  │
│  ┌──────────┐  ┌──────────┐                  │
│  │ Microfone│  │ Câmera   │                  │
│  │(I2S/PDM) │  │(USB/SPI) │                  │
│  └──────────┘  └──────────┘                  │
├───────────────────────────────────────────────┤
│  ALIMENTAÇÃO                                  │
│  12V Aeronave → Regulador → 5V → 3.3V        │
└───────────────────────────────────────────────┘
```

**Firmware:**
- Linguagem: C/C++ (Arduino framework)
- RTOS: FreeRTOS
- Protocolo: JSON over WebSocket/MQTT
- OTA Updates: Sim

---

### 2. APP TABLET (Flutter)

**Arquitetura:**

```
┌─────────────────────────────────────────────┐
│              PRESENTATION                   │
│  ┌─────────────┐  ┌──────────────────────┐ │
│  │  Screens    │  │     Widgets          │ │
│  │ - Sixpack   │  │  - Instrumentos      │ │
│  │ - Plano Voo │  │  - Forms             │ │
│  └──────┬──────┘  └──────────┬───────────┘ │
├─────────┼──────────────────────┼─────────────┤
│         │      BLoC/Provider   │             │
│  ┌──────▼──────┐  ┌───────────▼──────────┐ │
│  │ FlightCubit │  │ TelemetryCubit       │ │
│  └──────┬──────┘  └───────────┬──────────┘ │
├─────────┼──────────────────────┼─────────────┤
│         │      DOMAIN          │             │
│  ┌──────▼──────┐  ┌───────────▼──────────┐ │
│  │ Use Cases   │  │    Entities          │ │
│  │ - StartFlight│  │  - FlightData       │ │
│  │ - SaveEval  │  │  - Student           │ │
│  └──────┬──────┘  └───────────┬──────────┘ │
├─────────┼──────────────────────┼─────────────┤
│         │      DATA            │             │
│  ┌──────▼──────┐  ┌───────────▼──────────┐ │
│  │Repositories │  │  Data Sources        │ │
│  └──────┬──────┘  └───────────┬──────────┘ │
│         │                      │             │
│  ┌──────▼──────────┐  ┌───────▼──────────┐ │
│  │  Local DB       │  │   Remote API     │ │
│  │  (Hive/Isar)    │  │   (Dio/HTTP)     │ │
│  └─────────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────┘
```

**Packages Principais:**
```yaml
dependencies:
  flutter_bloc: ^8.1.0       # State management
  dio: ^5.0.0                 # HTTP client
  web_socket_channel: ^2.4.0 # WebSocket
  hive: ^2.2.0                # Local storage
  geolocator: ^10.0.0         # GPS
  permission_handler: ^11.0.0 # Permissions
  connectivity_plus: ^5.0.0   # Network status
```

---

### 3. BACKEND CLOUD

**Arquitetura Microserviços:**

```
┌────────────────────────────────────────────────────┐
│             API GATEWAY (Kong/Nginx)               │
│  - Rate Limiting                                   │
│  - Load Balancing                                  │
│  - SSL Termination                                 │
└─────────────────┬──────────────────────────────────┘
                  │
     ┌────────────┼────────────┬─────────────┐
     │            │            │             │
     ▼            ▼            ▼             ▼
┌─────────┐  ┌─────────┐  ┌──────────┐  ┌──────────┐
│  Auth   │  │ Flight  │  │Telemetry │  │  User    │
│ Service │  │ Service │  │ Service  │  │ Service  │
│         │  │         │  │          │  │          │
│ Node.js │  │ Node.js │  │  Go      │  │ Node.js  │
│ + JWT   │  │ + REST  │  │+ WebSocket│  │ + REST   │
└────┬────┘  └────┬────┘  └────┬─────┘  └────┬─────┘
     │            │             │             │
     └────────────┴─────────────┴─────────────┘
                  │
     ┌────────────▼──────────────────┐
     │   DATABASE LAYER              │
     │                               │
     │  ┌──────────┐  ┌───────────┐ │
     │  │PostgreSQL│  │   Redis   │ │
     │  │ (Primary)│  │  (Cache)  │ │
     │  └──────────┘  └───────────┘ │
     │                               │
     │  ┌──────────┐  ┌───────────┐ │
     │  │   S3/    │  │  ElasticS.│ │
     │  │  Blob    │  │  (Logs)   │ │
     │  └──────────┘  └───────────┘ │
     └───────────────────────────────┘
```

**Tecnologias:**
- **Runtime:** Node.js 20 LTS
- **Framework:** Express.js / NestJS
- **Database:** PostgreSQL 15
- **Cache:** Redis 7
- **Storage:** AWS S3 / Azure Blob
- **Queue:** RabbitMQ / AWS SQS
- **Monitoring:** Prometheus + Grafana
- **Logs:** ELK Stack (Elasticsearch, Logstash, Kibana)

**API Endpoints:**

```
Auth Service (Port 3001)
├─ POST   /auth/login
├─ POST   /auth/register
├─ POST   /auth/refresh
└─ POST   /auth/logout

Flight Service (Port 3002)
├─ POST   /flights
├─ GET    /flights/:id
├─ GET    /flights
├─ PATCH  /flights/:id
├─ DELETE /flights/:id
└─ GET    /flights/:id/replay

Telemetry Service (Port 3003)
├─ POST   /telemetry/batch        # Bulk insert
├─ GET    /telemetry/:flightId
├─ WS     /telemetry/stream/:id   # Real-time
└─ GET    /telemetry/export/:id   # CSV/JSON

User Service (Port 3004)
├─ CRUD   /students
├─ CRUD   /instructors
├─ GET    /students/:id/history
└─ GET    /students/:id/stats

Evaluation Service (Port 3005)
├─ POST   /evaluations
├─ GET    /evaluations/:id
├─ GET    /evaluations/flight/:flightId
└─ PATCH  /evaluations/:id
```

---

### 4. WEB APP (React)

**Arquitetura:**

```
┌─────────────────────────────────────────────┐
│           NEXT.JS APP                       │
│  ┌──────────────┐  ┌────────────────────┐  │
│  │   Pages      │  │    Components      │  │
│  │ - Dashboard  │  │  - Map             │  │
│  │ - Monitoring │  │  - Sixpack Display │  │
│  │ - Students   │  │  - DataTable       │  │
│  └──────┬───────┘  └────────┬───────────┘  │
├─────────┼──────────────────┼─────────────────┤
│         │   STATE (Redux)   │                │
│  ┌──────▼──────┐  ┌────────▼───────────┐   │
│  │   Slices    │  │      API Layer     │   │
│  │ - flights   │  │  (RTK Query)       │   │
│  │ - users     │  │                    │   │
│  └─────────────┘  └────────────────────┘   │
├─────────────────────────────────────────────┤
│         EXTERNAL SERVICES                   │
│  ┌──────────────┐  ┌────────────────────┐  │
│  │  Backend API │  │   Moodle API       │  │
│  │  (REST)      │  │   (REST)           │  │
│  └──────────────┘  └────────────────────┘  │
└─────────────────────────────────────────────┘
```

**Stack:**
- Framework: Next.js 14 (App Router)
- UI: Tailwind CSS + shadcn/ui
- State: Redux Toolkit + RTK Query
- Maps: Mapbox GL JS / Google Maps
- Charts: Recharts
- Forms: React Hook Form + Zod

---

### 5. EAD (Moodle)

**Integração:**

```
┌────────────────────────────────────────┐
│           MOODLE LMS                   │
│  - PHP 8.1                             │
│  - MySQL 8.0                           │
│  - Apache/Nginx                        │
├────────────────────────────────────────┤
│  PLUGINS CUSTOM                        │
│  ┌──────────────────────────────────┐ │
│  │ local_avionica                   │ │
│  │  - Sincronização alunos          │ │
│  │  - API integration                │ │
│  └──────────────────────────────────┘ │
│  ┌──────────────────────────────────┐ │
│  │ mod_facerecognition              │ │
│  │  - Identificação facial          │ │
│  │  - Anti-fraude                   │ │
│  └──────────────────────────────────┘ │
├────────────────────────────────────────┤
│  API REST                              │
│  /webservice/rest/server.php          │
└─────────────┬──────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│      Backend Aviônica                   │
│  - Cria usuário Moodle                  │
│  - Matricula em cursos                  │
│  - Consulta progresso                   │
│  - Verifica certificados                │
└─────────────────────────────────────────┘
```

---

## 🔄 FLUXOS DE DADOS

### Fluxo 1: Coleta de Telemetria

```
1. SPU coleta dados sensores (1Hz)
   └─ GPS, IMU, Barômetro, etc

2. SPU processa e formata JSON
   └─ {"timestamp": ..., "lat": ..., "alt": ...}

3. SPU tenta enviar
   ├─ Via 4G → Backend Cloud (preferencial)
   ├─ Via WiFi → Tablet → Backend (fallback 1)
   └─ Armazena local se offline (fallback 2)

4. Backend recebe e valida
   └─ POST /telemetry/batch

5. Backend armazena
   ├─ PostgreSQL (dados estruturados)
   ├─ S3 (JSON bruto para replay)
   └─ Redis (cache para queries rápidas)

6. Backend notifica via WebSocket
   └─ Web App (central) recebe atualização real-time
```

### Fluxo 2: Voo Completo (End-to-End)

```
ANTES DO VOO:
1. Instrutor cria plano de voo (Tablet)
   └─ Origem, destino, rota, objetivos

2. Tablet sincroniza com Backend
   └─ POST /flights {status: "planned"}

3. Backend notifica Web App
   └─ Gestor vê voo planejado no mapa

DURANTE O VOO:
4. SPU inicia coleta automática
   └─ Detecta movimento GPS > 5 knots

5. Telemetria streaming
   ├─ SPU → Backend (4G)
   └─ Backend → WebSocket → Web App

6. Instrutor monitora no Tablet
   └─ Sixpack em tempo real

APÓS O VOO:
7. SPU detecta pouso (acelerômetro)
   └─ Para coleta automática

8. Instrutor faz debriefing (Tablet)
   └─ Notas, comentários, avaliação

9. Tablet envia avaliação
   └─ POST /evaluations

10. Backend processa estatísticas
    └─ Max/min de todos parâmetros

11. Web App atualiza histórico aluno
    └─ Horas de voo, competências
```

### Fluxo 3: Offline → Online Sync

```
1. Voo acontece SEM conexão
   └─ SPU armazena tudo localmente (1 MB Flash)

2. Tablet também armazena (Hive local)
   └─ Dados do voo + avaliação

3. Quando WiFi disponível:
   ├─ SPU → Tablet (Bluetooth)
   └─ Tablet → Backend (WiFi/4G)

4. Backend detecta dados antigos
   └─ Timestamp analysis

5. Backend processa em batch
   └─ Insere tudo com timestamp original

6. Backend marca como "synced"
   └─ SPU pode deletar dados locais
```

---

## 🔐 SEGURANÇA

### Autenticação & Autorização

```
┌──────────────────────────────────────┐
│  JWT (JSON Web Token)                │
│  - Access Token (15 min)             │
│  - Refresh Token (7 dias)            │
│  - Stored: httpOnly cookie + local   │
└──────────────────────────────────────┘

Roles:
├─ SUPER_ADMIN (Quadritech)
│  └─ Acesso total a tudo
├─ ADMIN_AEROCLUBE
│  └─ Gestão do aeroclube
├─ INSTRUTOR
│  └─ Voos + Avaliações
└─ ALUNO
   └─ Ver próprios dados + EAD
```

### Criptografia

- **Em trânsito:** TLS 1.3
- **Em repouso:** AES-256 (senhas: bcrypt)
- **Telemetria sensível:** Encrypted JSON

### Rate Limiting

```
API Gateway:
├─ 100 req/min por IP (geral)
├─ 1000 req/min por auth token
└─ 10 req/sec para telemetry/batch
```

---

## 📊 ESCALABILIDADE

### Horizontal Scaling

```
Load Balancer (AWS ALB / Nginx)
       │
   ┌───┴────┬────────┬────────┐
   │        │        │        │
   ▼        ▼        ▼        ▼
Node 1   Node 2   Node 3   Node N
(API)    (API)    (API)    (Auto-scale)
   │        │        │        │
   └────────┴────────┴────────┘
             │
    ┌────────▼─────────┐
    │  PostgreSQL      │
    │  (Primary)       │
    │  + Replicas      │
    └──────────────────┘
```

### Database Sharding

```
Sharding por Aeroclube ID:
├─ Shard 1: Aeroclubes 1-100
├─ Shard 2: Aeroclubes 101-200
└─ Shard N: ...
```

### CDN para Assets

```
CloudFlare / AWS CloudFront
├─ Moodle vídeos
├─ App assets (images, fonts)
└─ Frontend static files
```

---

## 🔧 DEPLOY

### Infraestrutura (AWS)

```
┌────────────────────────────────────────┐
│          Route 53 (DNS)                │
└─────────────┬──────────────────────────┘
              │
┌─────────────▼──────────────────────────┐
│     CloudFront (CDN)                   │
└─────────────┬──────────────────────────┘
              │
┌─────────────▼──────────────────────────┐
│     ALB (Load Balancer)                │
└─────────────┬──────────────────────────┘
              │
     ┌────────┴────────┐
     │                  │
┌────▼─────┐     ┌─────▼────┐
│   ECS    │     │   ECS    │
│ (API)    │     │  (Web)   │
│ Fargate  │     │ Fargate  │
└────┬─────┘     └─────┬────┘
     │                  │
     └────────┬─────────┘
              │
┌─────────────▼──────────────────────────┐
│     RDS PostgreSQL (Multi-AZ)          │
└────────────────────────────────────────┘
│     ElastiCache Redis                  │
└────────────────────────────────────────┘
│     S3 (Storage)                       │
└────────────────────────────────────────┘
```

### CI/CD Pipeline

```
GitHub
  │
  ├─ git push → main
  │
  ▼
GitHub Actions
  │
  ├─ 1. Run tests
  ├─ 2. Build Docker image
  ├─ 3. Push to ECR
  ├─ 4. Deploy to ECS (staging)
  ├─ 5. Run E2E tests
  └─ 6. Deploy to ECS (production)
```

---

## 📏 MÉTRICAS & MONITORAMENTO

### KPIs Técnicos

```
Latência:
├─ API: < 200ms (p95)
├─ WebSocket: < 50ms (p95)
└─ Telemetry insert: < 100ms (bulk)

Disponibilidade:
└─ 99.9% uptime (SLA)

Throughput:
├─ 1000 voos simultâneos
└─ 100k telemetry points/segundo
```

### Logs & Alertas

```
CloudWatch / Datadog:
├─ Error rate > 1% → PagerDuty
├─ Latency > 500ms → Slack
├─ CPU > 80% → Auto-scale
└─ Disk > 90% → Email
```

---

**Próximo:** AVIONICA_MODULES.md (detalhamento)

**Criado em:** 04/11/2025  
**Versão:** 1.0