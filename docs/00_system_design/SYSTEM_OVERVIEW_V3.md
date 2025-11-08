# 📋 SYSTEM OVERVIEW - AVIÔNICA MVP

**🆕 Versão:** 3.0  
**📅 Data:** 06/11/2025  
**✅ Status:** Documento Mestre Completo - Versão Corrigida  
**👤 Autor:** Equipe Aviônica

---

## 🔄 CHANGELOG V3.0

### 🔴 Correções Críticas

✅ **Replay 2D** → Removido TODAS menções 3D/Cesium → Leaflet 2D  
✅ **SSID Padronizado** → "CODIGO-qfly-AP" em TODO documento  
✅ **Bateria** → ESP32 NÃO monitora bateria (removido campo JSON)  
✅ **Bateria Tablet** → ADICIONA monitoramento bateria tablet  
✅ **WiFi Loss** → Dados perdidos ignorados + log da perda  
✅ **Diário Bordo** → Tabela logs para busca futura  
✅ **Storage** → Mantém 5GB (justificado)  
✅ **Particionamento** → NÃO fazer MVP (clarificado)  
✅ **Calibração** → Flutter controla (ESP32 faz internamente)  

### ⭐ Melhorias Adicionadas

✅ **Dashboard Admin** → Métricas avançadas completas  
✅ **Workflows N8N** → Diagramas macro intuitivos  
✅ **Backup** → Estratégia completa documentada  
✅ **Testes/QA** → Seção detalhada adicionada  
✅ **Portal Aluno** → Simplificado MVP (sem suporte/chat)  

### 📦 Pós-MVP Registrado

✅ **Conquistas** → Sistema gamificação tipo PEAK  
✅ **Vídeo/Áudio** → GoPro + sync telemetria  
✅ **PWA** → Web app progressivo  

---

## 🎯 VISÃO EXECUTIVA

### 💡 Propósito

Sistema **end-to-end** para **digitalização completa** da instrução de voo em aeroclubes brasileiros, integrando **hardware real de telemetria** (ESP32 SPU) com **software de gestão profissional** e **avaliação objetiva baseada em dados**.

---

### 🏆 Diferencial Competitivo

```
📊 CONCORRÊNCIA (SAGA, Alis, Plane It):
   → Software apenas (sem hardware)
   → Avaliação subjetiva (texto/notas manuais)
   → Sem evidência física de performance
   → Sem telemetria real
   → Sem replay interativo
   → Portal aluno limitado

✨ AVIÔNICA (Nossa Proposta):
   → ✅ Hardware SPU próprio (telemetria REAL 20Hz)
   → ✅ Avaliação objetiva (dados sensores reais)
   → ✅ Evidência física verificável e incontestável
   → ✅ Sixpack digital tempo real (6 instrumentos)
   → ✅ Replay 2D interativo com análise
   → ✅ Live tracking 4G (acompanhamento remoto)
   → ✅ Portal aluno completo (progresso, CIV, documentos)
   → ✅ CIV Digital automático (conformidade ANAC)
   → ✅ 4 portais especializados (admin, gestor, instrutor, aluno)
```

---

### 📊 Números-Chave MVP

```yaml
Sistemas:
  - Hardware: 1 (ESP32 SPU)
  - Software: 3 (Mobile + Backend + Web)
  
Perfis Mobile:
  - Instrutor: ✅ Completo (tablet)
  - Aluno: ❌ Pós-MVP (mobile nativo)
  
Perfis Web:
  - Admin: ✅
  - Gestor: ✅
  - Instrutor: ✅
  - Aluno: ✅ (simplificado)

Capacidades:
  - Offline-first: 100% funcional sem internet em voo
  - Sync automático: WiFi/4G → Cloud
  - Live tracking: 4G opcional durante voo
  - Regulatório: CIV Digital ANAC obrigatório
  - Storage tablet: 5GB (margem segurança)
  - Telemetria: 20Hz (50ms/pacote)
  - Sensores: 7 dispositivos físicos
  - Replay: Mapa 2D interativo (Leaflet)
```

---

### 💰 Validação Mercado

```
📊 Mercado Brasil:
   - 94 aeroclubes ANAC homologados
   - ~15.000 alunos ativos/ano
   - ~2.500 instrutores certificados
   - Ticket médio: R$ 450/hora voo

🎯 Go-to-Market:
   - Fase 1: 1 aeroclube piloto (6 meses)
   - Fase 2: 3-5 aeroclubes (12 meses)
   - Fase 3: 10-15 aeroclubes (18 meses)
   - Fase 4: Expansão nacional (24 meses)

💰 Modelo Negócio:
   - SaaS: R$ 299-1.200/mês/aeroclube
   - Hardware SPU: R$ 1.200-2.400/unidade
   - Setup: R$ 2.000-10.000/aeroclube (one-time)
```

---

## 🏗️ ARQUITETURA MACRO - 4 SISTEMAS

```
┌───────────────────────────────────────────────────────────────────────┐
│                    🌐 SISTEMA AVIÔNICA MVP v3.0                        │
│                                                                        │
│  Hardware SPU + Mobile App + Backend + Web App (4 portais)            │
└───────────────────────────────────────────────────────────────────────┘

┌─────────────────┐    WebSocket      ┌─────────────────┐
│   ESP32 SPU     │◄───── WiFi ──────►│  MOBILE APP     │
│   (Aeronave)    │     20Hz JSON     │  (Tablet)       │
│                 │                   │                 │
│ • 7 Sensores    │                   │ • Offline 1°    │
│ • GPS 20Hz      │                   │ • Sixpack       │
│ • Telemetria    │                   │ • Avaliação FAP │
│ • WiFi AP       │                   │ • Plano voo     │
│ • Calibração    │                   │ • Agenda        │
│                 │                   │ • Checklist     │
│                 │                   │ • Fotos         │
└─────────────────┘                   │ • Battery Mon   │
                                      └────────┬────────┘
                                               │
                                          WiFi │ Sync
                                          4G   │ Live
                                               │
                                        ┌──────▼──────────┐
                                        │   BACKEND       │
                                        │                 │
                                        │ • Supabase Auth │
                                        │ • N8N Workflows │
                                        │ • PostgreSQL 14 │
                                        │ • Redis Cache   │
                                        │ • S3 Storage    │
                                        │ • WebSocket Srv │
                                        │ • API REST      │
                                        │ • CIV ANAC API  │
                                        └──────┬──────────┘
                                               │
                                          HTTPS│ API
                                               │
                                        ┌──────▼──────────┐
                                        │   WEB APP       │
                                        │   Next.js 14    │
                                        │   + React 18    │
                                        │                 │
                                        │ 📊 Portal Admin │
                                        │ 🏢 Portal Gestor│
                                        │ 👨‍✈️ Portal Instr │
                                        │ 👨‍🎓 Portal Aluno │
                                        │                 │
                                        │ • Live Tracking │
                                        │ • Replay 2D     │
                                        │ • Dashboards BI │
                                        │ • Relatórios    │
                                        │ • CIV Digital   │
                                        │ • Docs/Upload   │
                                        └─────────────────┘
```

---

## 🔧 STACK TECNOLÓGICO DETALHADO

### ⚙️ **Hardware (ESP32 SPU)**

```yaml
Microcontrolador:
  - ESP32 DevKit V1 (dual-core 240MHz)
  - RAM: 520KB
  - Flash: 4MB
  - WiFi: 802.11 b/g/n (2.4GHz)
  - Custo: ~R$ 35

Sensores (7 unidades):
  1. 📍 GPS: NEO-M8M (10Hz → interpolado 20Hz)
  2. 📏 Barômetro: BMP180/085 (altitude)
  3. 🧭 Bússola: HMC5883L (heading magnético)
  4. 📐 Acelerômetro: ADXL345 (3 eixos)
  5. 🔄 Giroscópio: L3G4200D (3 eixos)
  6. 🎯 IMU: LSM6DS3 (6DOF redundância)
  7. 🌡️ Temperatura: BMP180 integrado

Alimentação:
  - Power bank / bateria própria → 5V → ESP32
  - Bateria backup: 18650 (2h autonomia)

Conexão:
  - WiFi AP: SSID "CODIGO-qfly-AP" (192.168.4.1)
  - WebSocket: ws://192.168.4.1:81
  - Protocolo: JSON UTF-8

Calibração:
  - ⚙️ Automática ao ligar (interna ESP32)
  - ✅ Flutter aguarda {status: "ready"}
  - ❌ Flutter NÃO envia comandos calibração
```

---

### 📱 **Mobile App (Flutter)**

```yaml
Framework: Flutter 3.16+
Linguagem: Dart 3.2+
Target: Android 8+ / iOS 13+ (tablets prioritário)

Packages principais:
  - web_socket_channel: WebSocket ESP32
  - sqflite: Database local (voos)
  - hive: Cache rápido (config)
  - geolocator: GPS device
  - camera: Fotos
  - pdf: Geração documentos
  - network_info_plus: SSID WiFi
  - device_info_plus: Device ID
  - permission_handler: Permissões
  - dio: HTTP client
  - flutter_map: Mapas offline (Leaflet 2D)
  - battery_plus: Monitoramento bateria tablet
  - supabase_flutter: Auth

Storage:
  - SQLite: 1 DB por voo (telemetria)
  - Hive: Cache (alunos, aeronaves, missões)
  - Files: Fotos, PDFs, logs

Storage Tablet (Justificativa 5GB):
  1 Voo (1h):
    • Metadata: 50KB
    • Telemetria: 2.5MB (72k pacotes comprimidos)
    • Fotos (4): 800KB (200KB cada)
    • Avaliação: 20KB
    • Plano voo PDF: 500KB
    • TOTAL: ~3.8MB

  20 voos pendentes sync: 76MB
  100 voos cache: 380MB
  App + Sistema: 200MB
  Margem segurança: 4.3GB
  ─────────────────────────
  TOTAL: ~5GB necessário ✅

Target Size:
  - APK: ~50MB
  - Storage mínimo: 5GB disponível
```

---

### 🖥️ **Backend**

```yaml
Autenticação:
  - Supabase Auth (JWT)
  - MFA: Opcional pós-MVP
  - OAuth: Google/Apple pós-MVP

Workflows:
  - N8N (self-hosted)
  - Docker compose
  - Node.js 18+

Database:
  - PostgreSQL 14+ (Supabase)
  - PostGIS (geoespacial)
  - ❌ Particionamento: NÃO fazer MVP
  - ✅ Quando implementar: >500k registros (6+ meses)
  - 25+ tabelas

Cache:
  - Redis 7+
  - TTL: 60s (live tracking)
  - Pub/Sub: WebSocket broadcast

Storage:
  - AWS S3 ou Supabase Storage
  - Fotos: JPEG 85% quality
  - Telemetria: Gzip comprimido
  - Retention: 5 anos (regulatório)

APIs Integradas:
  - ANAC CIV Digital (obrigatório)
  - DECEA AIS (planejamento - pós-MVP)
```

---

### 🌐 **Web App**

```yaml
Framework: Next.js 14 (App Router)
UI Library: React 18
Linguagem: TypeScript 5+

Styling:
  - TailwindCSS 3
  - shadcn/ui components

Visualização:
  - Recharts: Gráficos telemetria
  - Leaflet: Mapas 2D interativos
  - ❌ Cesium: NÃO utilizado (3D removido)

Build:
  - Vercel / Netlify / Docker
```

---

## 📡 JSON TELEMETRIA (ESP32 → TABLET)

### ✅ Estrutura Corrigida V3.0

```json
{
  "timestamp": 1730905820123,
  "seq": 1245,
  "status": "flying",
  
  "gps": {
    "lat": -25.4284,
    "lng": -49.2733,
    "alt_msl": 850.5,
    "speed_kts": 85.2,
    "heading": 120,
    "satellites": 12,
    "hdop": 0.9
  },
  
  "attitude": {
    "pitch": -2.5,
    "roll": 5.0,
    "yaw": 120
  },
  
  "airspeed": {
    "ias_kts": 82.0,
    "tas_kts": 85.2
  },
  
  "altitude": {
    "indicated_ft": 2900,
    "pressure_mb": 1013.25,
    "qnh_mb": 1013.25,
    "density_alt_ft": 3100
  },
  
  "engine": {
    "rpm": 2300,
    "manifold_pressure": 23.5
  },
  
  "vertical_speed": {
    "vsi_fpm": -50
  },
  
  "temperature": {
    "oat_c": 18.5
  },
  
  "turn_coordinator": {
    "turn_rate": 0.5,
    "slip_ball": 0.2
  }
}
```

### ⚠️ Campos Removidos

❌ **bateria** → ESP32 NÃO monitora bateria (removido)  
✅ **Bateria Tablet** → Monitorada por Flutter separadamente

---

## 🔋 MONITORAMENTO BATERIA TABLET

### 📊 Sistema Alertas

```dart
// Flutter - Battery Monitoring
import 'package:battery_plus/battery_plus.dart';

class BatteryMonitor {
  final Battery _battery = Battery();
  
  Stream<BatteryLevel> monitorBattery() async* {
    await for (final level in _battery.onBatteryStateChanged) {
      final percent = await _battery.batteryLevel;
      
      if (percent < 15) {
        yield BatteryLevel.critical; // 🔴 Vermelho
      } else if (percent < 30) {
        yield BatteryLevel.low; // 🟡 Amarelo
      } else {
        yield BatteryLevel.normal; // 🟢 Verde
      }
    }
  }
}
```

### 🚨 Alertas Visuais

```
🔋 NÍVEIS BATERIA TABLET:

✅ >30%: Verde - Normal
  • Sem alertas
  • Continua voo normalmente

⚠️ 15-30%: Amarelo - Baixa
  • Banner topo: "Bateria baixa! Conecte carregador"
  • Ícone piscando
  • Não bloqueia voo

🔴 <15%: Vermelho - Crítica
  • Popup modal: "BATERIA CRÍTICA! Finalize voo!"
  • Som alerta
  • Recomendação pousar
  • Não bloqueia (piloto decide)
```

---

## 🔌 RECONEXÃO WIFI (FLUXO LOSS)

### ⚠️ Comportamento V3.0

```yaml
Quando WiFi desconecta ESP32:

1. TABLET (Offline):
   • Exibe: "⚠️ Telemetria offline (último: 12:34:56)"
   • Sixpack congela último valor conhecido
   • Continua gravando LOCAL (GPS tablet + acelerômetro)
   • Voo NÃO é interrompido
   • Log timestamp: "wifi_disconnected_at"

2. ESP32 (Continua gravando):
   • ❌ NÃO armazena buffer (memória limitada)
   • ❌ Dados perdidos são DESCARTADOS
   • Continua transmitindo (se ninguém receber, perde)

3. QUANDO RECONECTA:
   • Tablet: "✅ Telemetria reconectada"
   • Retoma recepção tempo real
   • Log timestamp: "wifi_reconnected_at"
   • ❌ NÃO sincroniza dados perdidos
   
4. LOGS BANCO DADOS:
   INSERT INTO flight_wifi_logs (
     flight_id,
     event_type, -- 'disconnected' | 'reconnected'
     timestamp,
     duration_seconds
   ) VALUES (...);

5. ANÁLISE PÓS-VOO:
   • Gráfico telemetria: GAP visível
   • Marcador: "⚠️ Perda WiFi (2min 35s)"
   • Instrutor vê período sem dados
```

### 📝 Tabela Logs WiFi

```sql
CREATE TABLE flight_wifi_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  flight_id UUID REFERENCES flights(id),
  event_type VARCHAR(20) NOT NULL, -- 'disconnected' | 'reconnected'
  timestamp TIMESTAMPTZ NOT NULL,
  duration_seconds INTEGER, -- null se ainda desconectado
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_flight_wifi ON flight_wifi_logs(flight_id, timestamp);
```

---

## 📓 DIÁRIO DE BORDO DIGITAL

### 💾 Sistema Armazenamento

```yaml
Funcionalidade:
  • Instrutor digita no tablet após voo
  • Sistema salva banco de dados
  • ⚠️ Papel continua obrigatório (ANAC)
  • Backup digital para conferência futura

Tabela Database:
  CREATE TABLE flight_logbook_entries (
    id UUID PRIMARY KEY,
    flight_id UUID REFERENCES flights(id),
    instructor_id UUID REFERENCES users(id),
    content TEXT NOT NULL,
    photos JSONB, -- URLs fotos diário
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
  );

Uso:
  1. Instrutor finaliza voo
  2. Tela "Diário de Bordo" opcional
  3. Digita observações/anotações
  4. Anexa fotos (opcional)
  5. Salva → PostgreSQL
  
  Portal Web:
    • Gestor: Busca diários histórico
    • Instrutor: Revê seus diários
    • Aluno: Vê diário do seu voo
    • Filtros: Data, aluno, instrutor, aeronave

Pós-MVP:
  • Gerar PDF formatado
  • Impressão térmica aeroclube
  • Lobby ANAC: Digital 100% (anos)
```

---

## 🔄 N8N WORKFLOWS (MACRO)

### 📊 Diagrama Intuitivo Workflows

```
┌─────────────────────────────────────────────────────────────────────┐
│                     🔄 N8N WORKFLOWS SISTEMA                         │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│ 1️⃣ FLIGHT SYNC PROCESSOR (Principal)                            │
└──────────────────────────────────────────────────────────────────┘
    📥 Trigger: POST /api/flights/sync (tablet finaliza voo)
    │
    ├─► 🔐 Valida JWT
    ├─► 💾 Salva PostgreSQL (flights + telemetry)
    ├─► 📤 TRIGGER → Workflow 2 (CIV Generator)
    ├─► 📤 TRIGGER → Workflow 4 (Hobbs Updater)
    ├─► 📤 TRIGGER → Workflow 6 (Notifications)
    └─► ✅ Retorna 200 OK


┌──────────────────────────────────────────────────────────────────┐
│ 2️⃣ CIV GENERATOR (Triggered)                                    │
└──────────────────────────────────────────────────────────────────┘
    📥 Evento: "flight_saved"
    │
    ├─► 📊 Busca dados completos flight
    ├─► 🔨 Gera XML CIV (padrão ANAC)
    ├─► 🔏 Assina digitalmente
    ├─► 🌐 POST API ANAC
    ├─► 💾 Salva protocolo resposta
    ├─► 📝 Log envio (audit_logs)
    ├─► 🔄 Retry 3x se erro (exponential backoff)
    └─► 📤 TRIGGER → Workflow 6 (Notificações)


┌──────────────────────────────────────────────────────────────────┐
│ 3️⃣ LIVE TELEMETRY RECEIVER (Real-time)                          │
└──────────────────────────────────────────────────────────────────┘
    📥 Trigger: POST /api/flights/live-telemetry (loop 4G)
    │
    ├─► 🗜️ Descomprime gzip
    ├─► ✅ Valida flight_id
    ├─► 💾 Salva Redis (TTL 60s) - key: "live:{flight_id}"
    ├─► 📡 Broadcast WebSocket → Todos conectados portal
    ├─► 📝 Log recebimento (metrics)
    └─► ✅ Retorna 200 OK


┌──────────────────────────────────────────────────────────────────┐
│ 4️⃣ AIRCRAFT HOBBS UPDATER (Triggered)                           │
└──────────────────────────────────────────────────────────────────┘
    📥 Evento: "flight_finalized"
    │
    ├─► 🔢 Calcula horas voadas (tempo voo)
    ├─► 💾 UPDATE aircraft.hobbs_atual += horas
    ├─► 🔧 Calcula próxima manutenção
    ├─► ⚠️ Alerta se <10h para manutenção
    ├─► 📝 Log alteração (audit_logs)
    └─► 📤 TRIGGER → Workflow 6 (se alerta)


┌──────────────────────────────────────────────────────────────────┐
│ 5️⃣ DOCUMENT EXPIRY CHECKER (Cron)                               │
└──────────────────────────────────────────────────────────────────┘
    📥 Trigger: Cron diário (06:00 AM)
    │
    ├─► 🔍 Query PostgreSQL: Validades próximas (<30 dias)
    │   • users.cma_validade
    │   • users.cht_validade
    │   • aircraft.cva_validade
    │
    ├─► ⚠️ Gera lista alertas
    ├─► 📤 TRIGGER → Workflow 6 (Notificações)
    └─► 📝 Log execução


┌──────────────────────────────────────────────────────────────────┐
│ 6️⃣ NOTIFICATION DISPATCHER (Central)                            │
└──────────────────────────────────────────────────────────────────┘
    📥 Eventos: Múltiplos workflows
    │
    ├─► 📊 Determina destinatários (roles)
    ├─► 📧 Email (SMTP)
    ├─► 🔔 Push App (Firebase) - pós-MVP
    ├─► 💾 Salva logs_notificacoes
    └─► ✅ Confirma envio


┌──────────────────────────────────────────────────────────────────┐
│ 7️⃣ CACHE SYNC PROVIDER (API)                                    │
└──────────────────────────────────────────────────────────────────┘
    📥 Trigger: GET /api/cache/sync (tablet abre app)
    │
    ├─► 🔍 Query PostgreSQL agregado:
    │   • students (aeroclube)
    │   • aircraft (aeroclube)
    │   • instructors (aeroclube)
    │   • missions (curso PP/PC)
    │   • evaluation_templates
    │
    ├─► 💾 Cache Redis (1h)
    ├─► 📦 Retorna JSON comprimido
    └─► ✅ 200 OK


┌──────────────────────────────────────────────────────────────────┐
│ 8️⃣ REPORTS GENERATOR (On-demand)                                │
└──────────────────────────────────────────────────────────────────┘
    📥 Trigger: POST /api/reports/generate
    │
    ├─► 📊 Query PostgreSQL agregado (complexo)
    ├─► 📄 Gera PDF/Excel (template)
    ├─► 💾 Upload S3
    ├─► 📝 Retorna URL pública (TTL 7 dias)
    └─► ✅ 200 OK
```

### ⚡ Fluxos Interligados

```
TABLET FINALIZA VOO
      ↓
┌─────▼─────┐
│ Workflow 1│ (Flight Sync)
└─────┬─────┘
      ├──────► Workflow 2 (CIV ANAC)
      ├──────► Workflow 4 (Hobbs Update)
      └──────► Workflow 6 (Notifications)
                    ↓
               📧 Email gestor
               📧 Email instrutor
               📧 Email aluno

TABLET EM VOO (4G)
      ↓
┌─────▼─────┐
│ Workflow 3│ (Live Telemetry)
└─────┬─────┘
      ├──────► Redis (cache 60s)
      └──────► WebSocket Broadcast
                    ↓
               🌐 Portal Web (mapa tempo real)

CRON DIÁRIO 06:00
      ↓
┌─────▼─────┐
│ Workflow 5│ (Doc Expiry)
└─────┬─────┘
      └──────► Workflow 6 (Notifications)
                    ↓
               ⚠️ "CMA vence em 15 dias!"
```

---

## 🌐 WEB APP - 4 PORTAIS

### 📊 **PORTAL ADMIN (Super Admin)**

```
🔐 Acesso: admin@avionica.com

┌────────────────────────────────────────────────────┐
│ 📊 DASHBOARD                                       │
└────────────────────────────────────────────────────┘

🎯 Métricas Avançadas (NOVO V3.0):
  
  ┌─────────────────────────┐  ┌─────────────────────────┐
  │ 🔥 TEMPO REAL           │  │ 📈 PERFORMANCE          │
  │ • Voos ativos AGORA: 12 │  │ • DAU/MAU: 245/1.200   │
  │ • Aeroclubes online: 8  │  │ • Uptime: 99.95%       │
  │ • Usuários online: 34   │  │ • Latência API: 145ms  │
  └─────────────────────────┘  └─────────────────────────┘
  
  ┌─────────────────────────┐  ┌─────────────────────────┐
  │ 📊 ESTATÍSTICAS 30 DIAS │  │ 🏢 TOP AEROCLUBES      │
  │ • Voos finalizados: 892 │  │ 1. ABC - 245 voos     │
  │ • CIVs enviados: 890    │  │ 2. XYZ - 198 voos     │
  │ • Taxa sucesso: 99.7%   │  │ 3. QWE - 143 voos     │
  └─────────────────────────┘  └─────────────────────────┘
  
  ┌─────────────────────────────────────────────────────┐
  │ 📉 GRÁFICO: Voos/Dia (30 dias)                      │
  │ [Recharts Line Chart]                               │
  └─────────────────────────────────────────────────────┘
  
  ┌─────────────────────────────────────────────────────┐
  │ 🚨 ÚLTIMOS 10 ERROS CRÍTICOS                        │
  │ • 12:34 - ANAC timeout (aeroclube ABC)              │
  │ • 11:20 - PostgreSQL connection pool full           │
  │ • 09:15 - Redis cache miss rate >10%                │
  └─────────────────────────────────────────────────────┘
  
  ┌─────────────────────────────────────────────────────┐
  │ 🛠️ HEALTH CHECKS                                    │
  │ • PostgreSQL: ✅ Online (15ms)                      │
  │ • Redis: ✅ Online (3ms)                            │
  │ • N8N Workflows: ✅ 8/8 ativos                      │
  │ • ANAC API: ✅ Online (320ms)                       │
  │ • S3 Storage: ✅ Online (125ms)                     │
  └─────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────┐
│ 🗺️ LIVE TRACKING GLOBAL (NOVO V3.0)                │
└────────────────────────────────────────────────────┘
  
  🌐 Mapa Leaflet 2D:
    • Ver TODOS voos ativos (sistema inteiro)
    • 🔍 Filtrar por aeroclube específico
    • 📍 Marcadores aeronaves tempo real
    • 🎨 Cores por aeroclube
    • 📊 Painel lateral: Lista voos
    • ⚠️ Alertas críticos (todos aeroclubes)
  
  Grid View:
    ┌────────┬──────────┬─────────┬────────┐
    │Aero    │Aeronave  │Instrutor│Status  │
    ├────────┼──────────┼─────────┼────────┤
    │ABC     │PT-ABC    │João     │🟢 Ativo│
    │XYZ     │PT-XYZ    │Maria    │🟢 Ativo│
    │QWE     │PT-QWE    │Pedro    │🟡 Taxiar│
    └────────┴──────────┴─────────┴────────┘

┌────────────────────────────────────────────────────┐
│ 🏢 GERENCIAR AEROCLUBES                            │
└────────────────────────────────────────────────────┘
  • 📋 Lista todos aeroclubes
  • ➕ Adicionar novo
  • ✏️ Editar/Desativar
  • 📊 Ver estatísticas individual
  • 💳 Ver plano/faturamento

┌────────────────────────────────────────────────────┐
│ 👥 GERENCIAR USUÁRIOS GLOBAIS                      │
└────────────────────────────────────────────────────┘
  • 🔍 Busca cross-aeroclube
  • 🚫 Suspender/Reativar
  • 🔐 Reset senha
  • 📧 Ver audit logs

┌────────────────────────────────────────────────────┐
│ 🔧 CONFIGURAÇÕES SISTEMA                           │
└────────────────────────────────────────────────────┘
  • 🎛️ Feature flags
  • 🔐 Credenciais ANAC (global)
  • 📧 SMTP config
  • 💾 Backup schedule
  • ⚙️ N8N workflows status
```

---

### 🏢 **PORTAL GESTOR (Aeroclube Manager)**

```
🔐 Acesso: gestor@aeroclubexyz.com

┌────────────────────────────────────────────────────┐
│ 📊 DASHBOARD AEROCLUBE                             │
└────────────────────────────────────────────────────┘
  • 📈 Voos hoje/semana/mês
  • ✈️ Taxa ocupação aeronaves
  • 👨‍🎓 Progresso alunos (geral)
  • 👨‍✈️ Performance instrutores
  • ⛽ Consumo combustível
  • 💰 ROI por aeronave
  • 📄 Relatórios ANAC

┌────────────────────────────────────────────────────┐
│ 🗺️ LIVE TRACKING (Aeroclube)                       │
└────────────────────────────────────────────────────┘
  • Ver voos ativos DESTE aeroclube
  • Multi-tracking (até 5 aeronaves simultâneas)
  • Dashboard grid view
  • Alertas específicos

┌────────────────────────────────────────────────────┐
│ ✈️ GERENCIAR AERONAVES                             │
└────────────────────────────────────────────────────┘
  • CRUD aeronaves
  • Histórico manutenção
  • Hobbs/Tacômetro
  • Docs validade (CVA)

┌────────────────────────────────────────────────────┐
│ 👥 GERENCIAR USUÁRIOS                              │
└────────────────────────────────────────────────────┘
  • Alunos (CRUD)
  • Instrutores (CRUD)
  • Funcionários (CRUD)
  • Docs validade (CMA/CHT)

┌────────────────────────────────────────────────────┐
│ 📅 CALENDÁRIO AULAS                                │
└────────────────────────────────────────────────────┘
  • Visualizações: Mês/Semana/Dia
  • Agendar/Editar/Cancelar
  • Upload plano voo
  • Definir fase/missão

┌────────────────────────────────────────────────────┐
│ 📊 RELATÓRIOS                                      │
└────────────────────────────────────────────────────┘
  • Performance geral
  • Taxa aprovação
  • Consumo recursos
  • Export PDF/Excel
```

---

### 👨‍✈️ **PORTAL INSTRUTOR (Web)**

```
🔐 Acesso: instrutor@aeroclubexyz.com

┌────────────────────────────────────────────────────┐
│ 📊 MEU DASHBOARD                                   │
└────────────────────────────────────────────────────┘
  • 📅 Minhas aulas hoje
  • 🕐 Próximas aulas
  • 👨‍🎓 Meus alunos
  • 📈 Meu desempenho
  • ⏱️ Horas voadas (mês)

┌────────────────────────────────────────────────────┐
│ 📅 MINHA AGENDA                                    │
└────────────────────────────────────────────────────┘
  • Ver minhas aulas
  • Solicitar reagendamento
  • Upload plano voo
  • Ver disponibilidade

┌────────────────────────────────────────────────────┐
│ 👨‍🎓 MEUS ALUNOS                                    │
└────────────────────────────────────────────────────┘
  • Lista alunos
  • Ver progresso individual
  • Histórico voos
  • Gráficos evolução
  • Anotações privadas

┌────────────────────────────────────────────────────┐
│ 🗺️ REPLAY VOO (2D Interativo)                      │
└────────────────────────────────────────────────────┘
  • Selecionar voo histórico
  • Mapa 2D Leaflet
  • Playback controles (play/pause/velocidade)
  • Sixpack sincronizado
  • Gráficos altitude/velocidade
  • Marcadores eventos importantes
  • Anotações no mapa
  • Export PDF relatório

┌────────────────────────────────────────────────────┐
│ 📄 DOCUMENTOS                                      │
└────────────────────────────────────────────────────┘
  • Meus documentos (CHT/CMA)
  • Upload/renovação
```

---

### 👨‍🎓 **PORTAL ALUNO (Simplificado MVP)**

```
🔐 Acesso: aluno@email.com

┌────────────────────────────────────────────────────┐
│ 📊 MEU PROGRESSO                                   │
└────────────────────────────────────────────────────┘
  • 📈 Gráfico evolução notas
  • ⏱️ Horas voadas vs previstas
  • 📋 Fases completas
  • 🎯 Próximas missões
  • 🏆 Conquistas (pós-MVP)

┌────────────────────────────────────────────────────┐
│ ✈️ MEUS VOOS                                       │
└────────────────────────────────────────────────────┘
  • 📋 Lista voos completos
  • 📊 Ver avaliação FAP
  • 🗺️ Ver replay 2D (somente leitura)
  • 📓 Ler diário bordo instrutor
  • 📷 Fotos voo
  • ⭐ Nota final

┌────────────────────────────────────────────────────┐
│ 📅 PRÓXIMAS AULAS                                  │
└────────────────────────────────────────────────────┘
  • Ver aulas agendadas
  • Instrutor designado
  • Aeronave
  • Horário
  • Fase/Missão

┌────────────────────────────────────────────────────┐
│ 📄 CIV DIGITAL                                     │
└────────────────────────────────────────────────────┘
  • Download PDF CIV
  • Histórico registros ANAC
  • Protocolo envio
  • Status validação

┌────────────────────────────────────────────────────┐
│ 📋 MEUS DOCUMENTOS                                 │
└────────────────────────────────────────────────────┘
  • Upload documentos pessoais
  • Ver validades (CMA)
  • Alertas vencimento

❌ REMOVIDO DO MVP:
  • Suporte técnico / FAQs
  • Chat instrutor
  • Abrir tickets
  • Notificações push
  • Central ajuda
```

---

## 💾 BACKUP & DISASTER RECOVERY

### 🛡️ Estratégia Completa (NOVA V3.0)

```yaml
┌────────────────────────────────────────────────────┐
│ 📦 POSTGRESQL BACKUP                               │
└────────────────────────────────────────────────────┘

Automação:
  • Cron: 3x/dia (03:00, 11:00, 19:00)
  • Tool: pg_dump + gzip
  • Script: N8N workflow dedicated

Armazenamento:
  • Local: /backups/postgresql/
  • Remoto: S3 bucket (região diferente)
  • Retenção local: 7 dias
  • Retenção S3: 30 dias completo + 12 meses incrementais

Tipos:
  1. Full Backup (diário 03:00):
     • Dump completo database
     • ~500MB comprimido
     
  2. Incremental (11:00, 19:00):
     • WAL (Write-Ahead Log) archives
     • ~50MB cada

Restore:
  • RTO (Recovery Time): <4 horas
  • RPO (Recovery Point): <8 horas
  • Procedimento documentado
  • Teste trimestral obrigatório

┌────────────────────────────────────────────────────┐
│ 📂 TELEMETRIA & FILES BACKUP                       │
└────────────────────────────────────────────────────┘

Telemetria:
  • Formato: Gzip comprimido
  • Storage: S3 Glacier (baixo custo)
  • Retenção: 5 anos (regulatório ANAC)
  • Custo estimado: ~R$50/mês (1TB)

Fotos:
  • Formato: JPEG 85%
  • Storage: S3 Standard
  • Retenção: 5 anos
  • Custo: ~R$20/mês (200GB)

PDFs/Docs:
  • Formato: Original
  • Storage: S3 Standard
  • Retenção: 5 anos
  • Custo: ~R$10/mês (50GB)

┌────────────────────────────────────────────────────┐
│ 🔧 CONFIGURAÇÕES & SECRETS                         │
└────────────────────────────────────────────────────┘

Backup:
  • N8N workflows: Export JSON diário
  • .env files: Encrypted S3
  • SSL certificates: S3 + local
  • Supabase config: Export dashboard

Secrets Management:
  • Tool: Doppler ou AWS Secrets Manager
  • Rotação: Semestral
  • Audit log: Completo

┌────────────────────────────────────────────────────┐
│ 🚨 DISASTER RECOVERY PLAN                          │
└────────────────────────────────────────────────────┘

Cenário 1: Falha VPS/Servidor
  1. Provisionar VPS novo (30min)
  2. Restore PostgreSQL backup S3 (2h)
  3. Deploy N8N workflows (1h)
  4. Atualizar DNS (30min)
  5. Validar integridade (30min)
  → TOTAL: 4 horas

Cenário 2: Corrupção Database
  1. Identificar último backup íntegro
  2. Restore em ambiente staging (1h)
  3. Validar dados (30min)
  4. Switchover produção (30min)
  5. Comunicar usuários (perda <8h dados)
  → TOTAL: 2.5 horas

Cenário 3: Perda S3 Bucket
  • ⚠️ CRÍTICO: Geo-replicação obrigatória
  • S3 replicação cruzada: us-east-1 → sa-east-1
  • Backup local VPS: 7 dias (redundância)
  • Restore: <1 hora

Testes:
  • Frequência: 1x/trimestre
  • Ambiente: Staging isolado
  • Documentar: Tempo restore real
  • Ajustar: RTO/RPO se necessário

Responsáveis:
  • DevOps lead: Execução restore
  • CTO: Aprovação switchover
  • Suporte: Comunicação usuários
```

---

## 🧪 TESTES & QA (NOVA V3.0)

### 📋 Estratégia Completa

```yaml
┌────────────────────────────────────────────────────┐
│ 1️⃣ UNIT TESTS                                      │
└────────────────────────────────────────────────────┘

Flutter (Mobile):
  • Framework: flutter_test
  • Cobertura alvo: 70%+
  • Focus: Business logic, models, services
  • CI/CD: Run em cada commit
  
  Exemplos:
    ✅ test_telemetry_parser.dart
    ✅ test_fap_calculator.dart
    ✅ test_sqlite_repository.dart
    ✅ test_websocket_service.dart

Next.js (Web):
  • Framework: Jest + React Testing Library
  • Cobertura alvo: 60%+
  • Focus: Components, hooks, utils
  • CI/CD: Run em cada PR
  
  Exemplos:
    ✅ Dashboard.test.tsx
    ✅ FlightMap.test.tsx
    ✅ useAuth.test.ts

Backend (N8N):
  • Testes manuais (MVP)
  • Validação JSON schemas
  • Mock ANAC API responses
  • Pós-MVP: Testes automatizados

┌────────────────────────────────────────────────────┐
│ 2️⃣ INTEGRATION TESTS                               │
└────────────────────────────────────────────────────┘

ESP32 ↔ Tablet:
  • Conexão WiFi automática
  • Recebimento 1000 pacotes JSON
  • Latência <50ms
  • Perda pacotes <1%
  • Reconexão após drop

Tablet ↔ Backend:
  • Sync voo completo (offline → online)
  • Upload fotos (4 imagens)
  • CIV geração + envio ANAC (sandbox)
  • Live telemetry stream

Backend ↔ ANAC:
  • Mock API ANAC (dev/staging)
  • Validação XML CIV
  • Retry logic (3x com backoff)
  • Timeout handling

┌────────────────────────────────────────────────────┐
│ 3️⃣ E2E TESTS (End-to-End)                          │
└────────────────────────────────────────────────────┘

Fluxo Completo Voo (Simulado):
  1. Gestor agenda aula (Web)
  2. Instrutor abre app (Mobile)
  3. Conecta ESP32 (WiFi)
  4. Executa checklist (37 itens)
  5. Inicia voo (GPS fix)
  6. Recebe telemetria 1h (72k pacotes)
  7. Finaliza voo
  8. Avalia aluno (FAP)
  9. Tira fotos (4)
  10. Sync backend
  11. CIV enviado ANAC
  12. Replay disponível (Web)
  
  → SUCESSO: ✅ Todas etapas sem erros

Web App (Cypress):
  • Testes críticos UI
  • Login/Logout
  • CRUD aeronaves
  • Live tracking
  • Replay voo
  • Geração relatórios

┌────────────────────────────────────────────────────┐
│ 4️⃣ BETA TESTING (Aeroclube Piloto)                │
└────────────────────────────────────────────────────┘

Participantes:
  • 1 aeroclube selecionado
  • 2 instrutores experientes
  • 5 alunos variados (iniciante → avançado)
  • 1 gestor aeroclube

Duração:
  • 3 meses testing intensivo
  • 100+ voos reais
  • 50+ horas voo acumuladas

Metodologia:
  • Bug tracking: GitHub Issues
  • Feedback: Formulário semanal
  • Reunião: Quinzenal (retrospectiva)
  • Hotfixes: <24h para críticos

Critérios Aprovação:
  ✅ 95%+ voos sem erros críticos
  ✅ <5 bugs médios/semana
  ✅ NPS >8.0 (instrutores)
  ✅ 100% CIVs enviados ANAC sucesso

┌────────────────────────────────────────────────────┐
│ 5️⃣ HOMOLOGAÇÃO ANAC                                │
└────────────────────────────────────────────────────┘

Ambiente:
  • Sandbox ANAC (não-produção)
  • Dados fictícios CANAC
  • CPFs/CNPJs testes

Validações:
  • 100 voos teste
  • XML CIV padrão exato
  • Assinatura digital ICP-Brasil
  • Campos obrigatórios preenchidos
  • Protocolo resposta correto

Certificação:
  • Aprovação ANAC formal
  • Documento conformidade
  • Liberação ambiente produção
  • Prazo estimado: 2-4 semanas

┌────────────────────────────────────────────────────┐
│ 6️⃣ PERFORMANCE TESTS                               │
└────────────────────────────────────────────────────┘

Load Testing:
  • Tool: k6 ou Artillery
  • Cenário: 1000 usuários simultâneos
  • Duração: 1h sustained
  • Métricas:
    - Latência p95 <200ms ✅
    - Error rate <0.1% ✅
    - CPU <70% ✅
    - Memory <80% ✅

Stress Testing:
  • Cenário: 5000 usuários (pico)
  • Identificar breaking point
  • Validar graceful degradation
  • Auto-scaling triggers

Database:
  • Query performance <100ms
  • 100k+ telemetry inserts/min
  • Concurrent writes: 500+
  • Backup impacto <5% CPU

┌────────────────────────────────────────────────────┐
│ 7️⃣ SECURITY TESTS                                  │
└────────────────────────────────────────────────────┘

Pentesting:
  • Ferramenta: OWASP ZAP
  • SQL Injection ✅ Prevenido
  • XSS ✅ Sanitização
  • CSRF ✅ Tokens
  • JWT ✅ Expiração correta

Vulnerabilidades:
  • Scan: npm audit / safety (Python)
  • Dependências desatualizadas
  • CVEs conhecidos
  • Fix: <7 dias para críticos

LGPD Compliance:
  • Dados sensíveis: Encrypted at rest
  • PII: Anonimização logs
  • Consent: Termo aceite obrigatório
  • Audit: Logs acesso 2 anos
```

---

## 🚀 PÓS-MVP (ROADMAP)

### 🎮 1. SISTEMA CONQUISTAS (Gamificação)

```yaml
Inspiração: App PEAK (brain training) - pós MVP

Conquistas Aluno:
  🏆 Primeiro Voo Solo
  🏆 10 Voos Completos
  🏆 50 Horas Voadas
  🏆 Nota 5.0 em Pouso
  🏆 5 Voos Sem Erro
  🏆 Completar Fase PP
  🏆 100% Checklist (10x seguidas)

Badges Visuais:
  • Bronze / Prata / Ouro
  • Progressão barra preenchimento
  • Animações celebratórias
  • Compartilhar redes sociais

Benefícios:
  • Engajamento aluno +40%
  • Motivação continuar curso
  • Redução evasão -25%
  • Marketing viral (Instagram/TikTok)
  • Gamification → Competição saudável

Implementação:
  • Database: achievements table
  • Triggers: Eventos voo
  • UI: Portal aluno + mobile
  • Push notification: "Novo badge! 🏆"
```

---

### 📹 2. VÍDEO/ÁUDIO COCKPIT - pós MVP

```yaml
Hardware Adicional (ideia longa, alterar por telemetrias já existentes):
  • GoPro Hero 12 ou similar
  • Mount cockpit (suction cup)
  • Cabo USB-C → Tablet (poder + transfer)
  • Microfone headset pilot (áudio cockpit)

Gravação:
  • Vídeo: 1080p 30fps
  • Áudio: Stereo (pilot + copilot)
  • Sync: Timestamp GPS (milliseconds)
  • Storage: 32GB SD card (~3h vídeo)

Portal Replay:
  ┌────────────────────────────────────┐
  │ [Vídeo Cockpit]  [Telemetria Map]  │
  │                                    │
  │ ▶️ Play sincronizado                │
  │ Speed: 1x 2x 4x                    │
  │                                    │
  │ Timeline:                          │
  │ [═══●════════════════] 12:34       │
  │                                    │
  │ Anotações Instrutor:               │
  │ 📍 02:15 - "Observe entrada curva" │
  │ 📍 05:30 - "Flare muito cedo"      │
  └────────────────────────────────────┘

Análise Instrutor:
  • Pausa em momento específico
  • Anota no vídeo + telemetria
  • Aluno revê após voo
  • Aprendizado visual +60% eficácia

Custo Adicional:
  • GoPro: R$ 2.000-3.000/unidade
  • Mounts: R$ 200
  • Storage: R$ 150
  • TOTAL: +R$ 2.500/aeronave

Casos Uso:
  • Debriefing avançado
  • Evidência avaliação
  • Material didático (biblioteca)
  • Marketing aeroclube
  • Segurança (investigação incidentes)
```

---

### 📱 3. PWA (Progressive Web App) - pós MVP

```yaml
Conceito:
  • Web app que funciona como app nativo
  • "Instalar" navegador → Ícone home screen
  • Funciona offline (Service Workers)
  • Push notifications
  • NÃO precisa lojas (Apple/Google)

Vantagens:
  ✅ Deploy instantâneo (sem review stores)
  ✅ Atualização automática (refresh)
  ✅ Cross-platform (iOS/Android/Desktop)
  ✅ Menos manutenção
  ✅ Storage ilimitado (IndexedDB)

Limitações:
  ⚠️ NÃO acessa ESP32 WiFi direto
  ⚠️ Câmera limitada (resolução)
  ⚠️ GPS menos preciso
  ⚠️ Bateria drain maior

Decisão Estratégica:
  • Gestor/Admin/Aluno: PWA ✅
  • Instrutor: App nativo (precisa ESP32)

Implementação:
  • Next.js já suporta PWA
  • Plugin: next-pwa
  • Manifest.json
  • Service Worker (cache assets)
  • Push API (notificações)

Timeline: MVP+2 (6-9 meses pós-launch)
```

---

### 🌍 4. MULTI-IDIOMA (i18n)

```yaml
Mercado Internacional:
  • USA: 3.000+ flight schools
  • Europa: 1.500+ escolas
  • América Latina: 500+ escolas
  • Ásia: 800+ escolas
  
  TOTAL: 100x mercado Brasil potencial

Idiomas Prioritários:
  1. pt-BR (MVP) ✅
  2. en-US (MVP+2) → USA mercado
  3. es-ES (MVP+3) → Latam
  4. fr-FR (MVP+4) → África francofônica

Implementação:
  • Flutter: easy_localization package
  • Next.js: next-intl
  • Database: Campos i18n (JSONB)
  • Traduções: Profissionais (não Google Translate)

Adaptações Necessárias:
  • Unidades medida (ft vs m)
  • Formatos data (MM/DD vs DD/MM)
  • Moedas (USD, EUR, BRL)
  • Regulatórios (FAA vs ANAC)
  • Termos aviação (padrão ICAO)

Investimento:
  • Traduções: R$ 15.000/idioma
  • Adaptação código: R$ 30.000
  • Testes: R$ 10.000
  • TOTAL: ~R$ 55.000/idioma

ROI Potencial:
  • USA flight school: $800/mês (4x Brasil)
  • 50 escolas USA = $40k/mês = R$ 200k/mês
  • Break-even: 3 meses
  • Upside: Mercado 100x maior

Timeline: MVP+6 (12-18 meses pós-launch)
```

---

## ⚠️ CONSTRAINTS & PREMISSAS

### 🔧 Técnicas

```yaml
Mobile:
  - Offline obrigatório (voo sem internet)
  - Storage mínimo: 5GB disponível
  - Android 8+ / iOS 13+
  - Tablet prioritário (screen size)
  - Bateria: Monitoramento tablet (não ESP32)

Telemetria:
  - Latência <50ms (20Hz)
  - Pacote: ~700 bytes (sem campo bateria ESP32)
  - Perda pacotes: <1%
  - Dados perdidos: Ignorados (não recuperados)

Backend:
  - Uptime: 99.9%
  - Latência API: <200ms
  - Concurrent users: 1000+

Database:
  - ❌ Particionamento: NÃO MVP
  - ✅ Implementar: Quando >500k registros
  - Retenção: 5 anos mínimo
  - Backup: 3x/dia

Storage:
  - Fotos: JPEG 85%
  - Telemetria: Gzip
  - Total: ~10GB/aeroclube/mês
```

---

### 📜 Regulatórias

```yaml
ANAC:
  - CIV Digital: Obrigatório (desde 01/12/2022)
  - Prazo envio: 24h
  - Assinatura: ICP-Brasil
  - Retenção: 5 anos (RBAC 141)

Segurança:
  - LGPD compliance
  - Dados sensíveis: Criptografados
  - Acesso: Logs auditoria
  - Backup: Geográfico redundante
```

---

### 💼 Negócio (MVP)

```yaml
Incluído MVP:
  ✅ Portal instrutor mobile
  ✅ Portal gestor web
  ✅ Portal admin web (com live tracking global)
  ✅ Portal aluno web (simplificado)
  ✅ CIV Digital ANAC
  ✅ Live tracking 4G
  ✅ Replay telemetria 2D (Leaflet)
  ✅ Agenda aulas
  ✅ Plano voo upload
  ✅ Diário bordo digital (logs)
  ✅ Bateria tablet monitoring
  ✅ WiFi loss handling
  ✅ Backup strategy
  ✅ Testes/QA completo

Pós-MVP:
  ❌ Portal aluno mobile nativo
  ❌ Gestão financeira completa
  ❌ EAD integrado
  ❌ Áudio/vídeo cockpit
  ❌ Chat tempo real
  ❌ Gamificação (conquistas)
  ❌ Multi-idioma
  ❌ Simulador integrado
  ❌ PWA (web app progressivo)
  ❌ Particionamento database
```

---

## 📝 PRÓXIMOS PASSOS

### 📄 Documentos Faltantes

```
1. ✅ SYSTEM_OVERVIEW v3.0 (este arquivo)
2. ⏳ DATA_FLOW_DIAGRAMS.md (Mermaid)
3. ⏳ MOBILE_OVERVIEW.md (detalhes Flutter)
4. ⏳ BACKEND_OVERVIEW.md (N8N workflows detalhados)
5. ⏳ WEB_OVERVIEW.md (Next.js páginas)
6. ⏳ HARDWARE_OVERVIEW.md (ESP32 integração)
7. ⏳ API_DOCUMENTATION.md (endpoints)
8. ⏳ DEPLOYMENT_GUIDE.md (infra)
9. ⏳ TESTING_STRATEGY.md (QA detalhado)
10. ⏳ BACKUP_PROCEDURES.md (DR detalhado)
```

---

### 🏃 Prioridades Desenvolvimento

## 🏃 CRONOGRAMA DESENVOLVIMENTO - 6 MESES (12 SPRINTS)

### 📅 FASE 1: DESENVOLVIMENTO MVP (3 meses)
```
Sprint 1-2 (Semanas 1-4) - 🏗️ FUNDAÇÃO
├─ Backend: Supabase + PostgreSQL + N8N (3 workflows) + Redis
├─ Mobile: Scaffold + Login + Dashboard + WebSocket mock
└─ Web: Scaffold + Login + Layout base

Sprint 3-4 (Semanas 5-8) - 📱 CORE MOBILE
├─ Backend: Workflows sync voo + CIV sandbox + API REST
├─ Mobile: Offline-first + Sixpack + Telemetria + Bateria tablet
└─ Web: Portal Gestor (CRUD alunos/instrutores/aeronaves)

Sprint 5-6 (Semanas 9-12) - 🌐 CORE WEB + INTEGRAÇÃO
├─ Backend: CIV retry + Notificações + Workflows completos (6)
├─ Mobile: Checklist + Fotos + Avaliação FAP + Sync 4G
└─ Web: 4 Portais + Replay 2D + Live tracking + CIV digital
```

---

### 📅 FASE 2: VALIDAÇÃO + PRODUÇÃO (3 meses)
```
Sprint 7-8 (Semanas 13-16) - 🧪 BETA TESTING REAL
├─ Hardware: 2 ESP32 instalados + Manual instalação
├─ Operacional: Treinar 3 instrutores + 20 voos reais
└─ Refinamento: Bugs P0/P1 + UX feedback + Performance

Sprint 9-10 (Semanas 17-20) - 🔒 HOMOLOGAÇÃO + SECURITY
├─ ANAC: Sandbox → Produção + Certificado ICP + Aprovação
├─ Security: Pentest + LGPD + Backup geo + Audit logs
└─ Performance: Load test 1k users + 99.9% uptime

Sprint 11-12 (Semanas 21-24) - 🚀 PRODUÇÃO + GO-LIVE
├─ Deploy: Vercel + Railway + Supabase + Redis + S3 (prod)
├─ Monitoring: Sentry + Grafana + PagerDuty + StatusPage
└─ 🎉 GO-LIVE: Aeroclube piloto ativo + Marketing + Vendas
```

---

### 📊 TIMELINE VISUAL
```
MÊS 1-2  │████████│ Backend + Mobile base
MÊS 3    │████████│ Web + Integração completa → MVP funcional ✅
MÊS 4    │████████│ Beta testing + Hardware real
MÊS 5    │████████│ ANAC produção + Security audit
MÊS 6    │████████│ Deploy produção + Go-Live 🎉
```

---

### 🎯 MILESTONES CRÍTICOS
```yaml
✅ Semana 4:  Mobile offline funcional
✅ Semana 8:  Telemetria 20Hz + Sixpack
✅ Semana 12: MVP completo (4 portais + CIV)
✅ Semana 16: 20 voos reais validados
✅ Semana 20: ANAC homologado ✅
✅ Semana 24: PRODUÇÃO ATIVA 🚀
```
---

## 📚 GLOSSÁRIO

```yaml
ANAC: Agência Nacional Aviação Civil
CANAC: Código identificação pessoa ANAC
CHT: Certificado Habilitação Técnica
CIV: Caderneta Individual de Voo
CMA: Certificado Médico Aeronáutico
FAP: Ficha Avaliação Piloto
ICAO: International Civil Aviation Organization
IFR: Instrument Flight Rules (voo instrumentos)
MCA 58-3: Manual ANAC avaliação
PC: Piloto Comercial
PP: Piloto Privado
PWA: Progressive Web App
RBAC: Regulamento Brasileiro Aviação Civil
SPU: Sensor Processing Unit (ESP32)
VFR: Visual Flight Rules (voo visual)
```

---

## 📞 CONTATO & SUPORTE (???)

```yaml
Documentação:
API Docs: 
Status: 
Suporte: suporte@avionica.com
WhatsApp: +55 41 99999-9999
GitHub: https://github.com/avionica
```

---

**✅ SYSTEM OVERVIEW v3.0 - COMPLETO & CORRIGIDO**

**Status:** 📄 Documento Mestre Definitivo V3.0  
**Correções:** 12 inconsistências críticas resolvidas  
**Melhorias:** 8 seções novas adicionadas  
**Próximo:** Iniciar desenvolvimento ou criar documentos técnicos detalhados  

**Arquivos Relacionados:**
- [CIV_DIGITAL_EXPLICADO.md](computer:///mnt/user-data/outputs/CIV_DIGITAL_EXPLICADO.md)
- [DATABASE_SCHEMA_V2.sql](computer:///mnt/user-data/outputs/DATABASE_SCHEMA_V2.sql)
- [ANALISE_COMPLETA_RESPOSTAS.md](computer:///mnt/user-data/outputs/ANALISE_COMPLETA_RESPOSTAS.md)

---