# 📋 SYSTEM OVERVIEW - AVIÔNICA MVP

**Versão:** 2.0  
**Data:** 05/11/2025  
**Status:** ✅ Documento Mestre Completo - Versão Definitiva  
**Autor:** Equipe Aviônica

**Changelog v2.0:**
- ✅ Web App expandido (4 portais completos)
- ✅ Mobile expandido (agenda, plano voo, live 4G)
- ✅ JSON ESP32 corrigido (timestamp, seq, status, bateria)
- ✅ Checklist digital completo (37 itens)
- ✅ Autenticação híbrida (Supabase + N8N)
- ✅ PostgreSQL v2 (25+ tabelas, logs, particionamento)
- ✅ Replay telemetria avançado (3D, gráficos, anotações)
- ✅ Storage tablet otimizado (1 DB por voo)
- ✅ Portal aluno web obrigatório
- ✅ CIV Digital detalhado

---

## 🎯 VISÃO EXECUTIVA

### Propósito
Sistema **end-to-end** para **digitalização completa** da instrução de voo em aeroclubes brasileiros, integrando **hardware real de telemetria** (ESP32 SPU) com **software de gestão profissional** e **avaliação objetiva baseada em dados**.

### Diferencial Competitivo

```
🏆 CONCORRÊNCIA (SAGA, Alis, Plane It):
   → Software apenas (sem hardware)
   → Avaliação subjetiva (texto/notas manuais)
   → Sem evidência física de performance
   → Sem telemetria real
   → Sem replay 3D
   → Portal aluno limitado

✨ AVIÔNICA (Nossa Proposta):
   → ✅ Hardware SPU próprio (telemetria REAL 20Hz)
   → ✅ Avaliação objetiva (dados sensores reais)
   → ✅ Evidência física verificável e incontestável
   → ✅ Sixpack digital tempo real (6 instrumentos)
   → ✅ Replay 3D interativo com análise
   → ✅ Live tracking 4G (acompanhamento remoto)
   → ✅ Portal aluno completo (progresso, CIV, documentos)
   → ✅ CIV Digital automático (conformidade ANAC)
   → ✅ 4 portais especializados (admin, gestor, instrutor, aluno)
```

### Números-Chave MVP

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
  - Aluno: ✅

Capacidades:
  - Offline-first: 100% funcional sem internet em voo
  - Sync automático: WiFi/4G → Cloud
  - Live tracking: 4G opcional durante voo
  - Regulatório: CIV Digital ANAC obrigatório
  - Storage tablet: 5GB (20 voos típico)
  - Telemetria: 20Hz (50ms/pacote)
  - Sensores: 8 dispositivos físicos
```

### Validação Mercado

```
📊 Mercado Brasil:
   - 94 aeroclubes ANAC homologados
   - ~15.000 alunos ativos/ano
   - ~2.500 instrutores certificados
   - Ticket médio: R$ 450/hora voo

🎯 Go-to-Market:
   - Fase 1: 1 aeroclube piloto (6 ~ 9 meses)
   - Fase 2: 3-5 aeroclubes (12 ~ 18 meses)
   - Fase 3: 10-15 aeroclubes (18 ~ 24 meses)
   - Fase 4: Expansão nacional (24 ~ 30 meses)

💰 Modelo Negócio:
   - SaaS: R$ 299 ~ 1200/mês por aeroclube (ilimitado)
   - Hardware SPU: R$ 1.200 ~ 2400/unidade (custo R$ 400 ~ 800)
   - Setup: R$ 2.000 ~ 10.000/aeroclube (one-time)
```

---

## 🏗️ ARQUITETURA MACRO - 4 SISTEMAS

```
┌───────────────────────────────────────────────────────────────────────┐
│                    🌐 SISTEMA AVIÔNICA MVP v2.0                        │
│                                                                        │
│  Hardware SPU + Mobile App + Backend + Web App (4 portais)            │
└───────────────────────────────────────────────────────────────────────┘

┌─────────────────┐    WebSocket      ┌─────────────────┐
│   ESP32 SPU     │◄───── WiFi ──────►│  MOBILE APP     │
│   (Aeronave)    │     20Hz JSON     │  (Tablet)       │
│                 │                   │                 │
│ • 8 Sensores    │                   │ • Offline 1°    │
│ • GPS 20Hz      │                   │ • Sixpack       │
│ • Telemetria    │                   │ • Avaliação FAP │
│                 │                   │ • Plano voo     │
│ • Bateria       │                   │ • Agenda        │
│ • WiFi AP       │                   │ • Checklist     │
│                 │                   │ • Fotos         │
└─────────────────┘                   └────────┬────────┘
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
                                        │ • Replay 3D     │
                                        │ • Dashboards BI │
                                        │ • Relatórios    │
                                        │ • CIV Digital   │
                                        │ • Docs/Upload   │
                                        │ • Mensagens     │
                                        └─────────────────┘
```

### Stack Tecnológico Detalhado

#### 🔧 **Hardware (ESP32 SPU)**
```yaml
Microcontrolador:
  - ESP32 DevKit V1 (dual-core 240MHz)
  - RAM: 520KB
  - Flash: 4MB
  - WiFi: 802.11 b/g/n (2.4GHz)
  - Custo: ~R$ 35

Sensores:
  1. GPS: NEO-M8M (10Hz → interpolado 20Hz)
  2. Barômetro: BMP180/085 (altitude)
  3. Bússola: HMC5883L (heading magnético)
  4. Acelerômetro: ADXL345 (3 eixos)
  5. Giroscópio: L3G4200D (3 eixos)
  6. IMU: LSM6DS3 (6DOF redundância)
  7. Temperatura: BMP180 integrado
  8. Bateria: Monitor tensão ADC

Alimentação:
  - Power bank / bateria própria → 5V → ESP32
  - Bateria backup: 18650 (2h autonomia)

Conexão:
  - WiFi AP: SSID "CODIGO-qfly-AP" (192.168.4.1)
  - WebSocket: ws://192.168.4.1:81
  - Protocolo: JSON UTF-8
```

#### 📱 **Mobile App**
```yaml
Framework: Flutter 3.16+
Linguagem: Dart 3.2+
Target: Android 8+ / iOS 13+ (tablets androids prioritário)

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
  - flutter_map: Mapas offline
  - supabase_flutter: Auth

Storage:
  - SQLite: 1 DB por voo (telemetria)
  - Hive: Cache (alunos, aeronaves, missões)
  - Files: Fotos, PDFs, logs

Target Size:
  - APK: ~50MB
  - Storage mínimo: 5GB disponível
```

#### 🖥️ **Backend**
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
  - Particionamento (telemetria por mês) pós-MVP
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
  - DECEA AIS (planejamento - futuro) pós-MVP
```

#### 🌐 **Web App**
```yaml
Framework: Next.js 14 (App Router)
UI Library: React 18
Linguagem: TypeScript 5+

Styling:
  - TailwindCSS 3
  - shadcn/ui components
  - Framer Motion (animações) - não necessário

Visualização:
  - Recharts: Gráficos telemetria
  - Leaflet: Mapas 2D

Build:
  - Vercel, Netlify ou Docker
```

---

## 🔄 FLUXO COMPLETO DE UM VOO (EXPANDIDO)

### 📅 **PLANEJAMENTO (Web/Mobile - dias antes)**

```

[Gestor ou Instrutor no Web App]
    ↓
1. Acessar Calendário de Aulas
   ┌──────────────────────────────────────┐
   │ 📅 Visualizações:                    │
   │ • Mês / Semana / Dia                 │
   │                                      │
   │ 📋 Aulas Agendadas:                  │
   │ • Ver todas aulas                    │
   │ • 🔍 Filtrar (aluno/instrutor/avião) │
   │ • ✏️ Editar aula (clicar na aula)    │
   │ • ❌ Cancelar aula                   │
   │ • 🔄 Remarcar aula                   │
   │                                      │
   │ [ ➕ Agendar Nova Aula ]              │
   └──────────────────────────────────────┘
    ↓
2. 📅 AGENDAR NOVA AULA:
   ┌──────────────────────────────────────┐
   │ • Selecionar Aluno                   │
   │ • Selecionar Instrutor               │
   │ • Selecionar Aeronave                │
   │ • Data/Hora                          │
   │ • Fase/Missão currículo              │
   │ • Duração estimada                   │
   │                                      │
   │ 📄 PLANO DE VOO (Opcional): ⭐ NOVO  │
   │   Escolha uma opção:                 │
   │   ○ 📤 Upload PDF                    │
   │      → OCR automático campos         │
   │      → Validação ICAO                │
   │   ○ ✍️ Preencher campos manual       │
   │      → Formulário ICAO               │
   │   ○ ⏭️ Sem plano (voo local)         │
   │                                      │
   │ 🗺️ Download mapas offline (opcional) │
   │ 📝 Observações prévias               │
   │                                      │
   │ ⚠️ Sistema valida automaticamente    │
   │    (Backend):                        │
   │ ✓ Conflitos agenda                   │
   │ ✓ Aeronave disponível                │
   │ ✓ Documentos (CMA/CHT)-pós MVP       |
   └──────────────────────────────────────┘
    ↓
3. Salvar agendamento
    ↓
4. 📧 Notificações enviadas (pós-MVP):
   • Email/SMS instrutor
   • Email/SMS aluno
   • Push notification app
    ↓
✅ AULA AGENDADA

[Sync mobile automático quando tablet conectar WiFi]
```

### 📱 **PRÉ-VOO (Mobile Offline)**

```
[Instrutor no Tablet - dia do voo]
    ↓
1. 🔐 Login Biométrico
   • Email/senha ou
   • Digital/Face ID (pós-MVP)
    ↓
2. 🔄 SINCRONIZAÇÃO AUTOMÁTICA:
   [Se WiFi disponível]
   ┌──────────────────────────────┐
   │ 📡 Sincronizando...          │
   │                              │
   │ ✅ Aulas agendadas           │
   │ ✅ Perfis alunos             │
   │ ✅ Aeronaves/status          │
   │ ✅ Templates FAP             │
   │ ✅ Cache atualizado          │
   │                              │
   │ Última sync: Agora           │
   └──────────────────────────────┘
    ↓
3. 📊 DASHBOARD:
   ┌──────────────────────────────────────┐
   │ 🗓️ AULAS DE HOJE:                    │
   │                                      │
   │ 🟢 Próxima (10:00-11:30):            │
   │ • Aluno: João Pedro Santos           │
   │ • Aeronave: PT-ABC                   │
   │ • Missão: Curvas 30°                 │
   │ [ ▶️ Iniciar Aula ]                  │
   │ [ 👁️ Ver Detalhes ]                  │
   │ [ ✏️ Editar ]                        │
   │                                      │
   │ ⏰ Próximas hoje:                    │
   │ • 14:00-15:30 - Maria Silva - PT-XYZ │
   │   [ 👁️ Ver ] [ ✏️ Editar ]           │
   │ • 16:00-17:00 - Carlos Lima - PT-ABC │
   │   [ 👁️ Ver ] [ ✏️ Editar ]           │
   │                                      │
   │ ✅ Concluídas hoje: 1 aula           │
   │                                      │
   │ ──────────────────────────────       │
   │ [ 📅 Ver Todas Aulas ]               │
   │ [ ➕ Criar Aula Agora ]               │
   │ [ 🔄 Sincronizar ]                   │
   └──────────────────────────────────────┘
    ↓
    
   OPÇÕES DISPONÍVEIS:
   
   A) ▶️ INICIAR PRÓXIMA AULA
      → Continua para passo 4
      
   B) 📅 VER TODAS AULAS
      ┌──────────────────────────────┐
      │ 📋 Minhas Aulas              │
      │                              │
      │ 🔍 Filtros:                  │
      │ • Hoje / Semana / Mês        │
      │ • Por aluno                  │
      │ • Por aeronave               │
      │ • Por status                 │
      │                              │
      │ Lista aulas:                 │
      │ Cada aula tem:               │
      │ [ ▶️ Iniciar ]               │
      │ [ ✏️ Editar ]                │
      │ [ ❌ Cancelar ]               │
      └──────────────────────────────┘
      
   C) ➕ CRIAR AULA AGORA
      ┌──────────────────────────────┐
      │ 🆘 Criar Aula Não Agendada   │
      │                              │
      │ • Selecionar Aluno           │
      │ • Selecionar Aeronave        │
      │ • Missão/Fase                │
      │ • Duração estimada           │
      │ • Motivo (emergência/reposição)│
      │                              │
      │ ⚠️ Aula NÃO estava agendada  │
      │                              │
      │ [ Criar e Iniciar ]          │
      └──────────────────────────────┘
      
   D) ✏️ EDITAR AULA
      → Alterar horário/aeronave
      → Salva local, sync depois
    ↓
4. Iniciar Aula → Carregar dados:
   ┌──────────────────────────────┐
   │ 📂 Carregando...             │
   │                              │
   │ ✅ Perfil aluno              │
   │ ✅ Histórico voos anteriores │
   │ ✅ Plano de voo (se houver)  │
   │ ✅ Template avaliação FAP    │
   │ ✅ Checklist aeronave        │
   └──────────────────────────────┘
    ↓
5. 📸 FOTOS COMPROVAÇÃO PRÉ-VOO:
   ┌──────────────────────────────┐
   │ 📷 Fotos Obrigatórias        │
   │                              │
   │ [ 📸 Foto Instrutor ]        │
   │ ✅ Carlos Silva (selfie)     │
   │                              │
   │ [ 📸 Foto Aluno ]            │
   │ ✅ João Pedro (selfie)       │
   │                              │
   │ [ 📸 Diário Bordo ]          │
   │ ○ Opcional                   │
   │                              │
   │ [Comprimidas 85% auto]       │
   │                              │
   │ [ Continuar ]                │
   └──────────────────────────────┘
    ↓
6. ✅ CHECKLIST DIGITAL PRÉ-VOO:
   ┌──────────────────────────────┐
   │ Cessna 152 - Preflight       │
   │                              │
   │ 📋 DOCUMENTOS (5 itens)      │
   │ ☐ Certificado Matrícula      │
   │ ☐ Certificado Aeronaveg.     │
   │ ☐ Apólice Seguro RETA        │
   │ ☐ Manual Operação            │
   │ ☑️ Diário Bordo 📸           │
   │                              │
   │ 🔧 EXTERIOR (16 itens)       │
   │ ☐ Fuselagem (danos)          │
   │ ☐ Asa Esquerda               │
   │ ☐ Flap Esquerdo              │
   │ ...                          │
   │                              │
   │ ⚙️ MOTOR (7 itens)           │
   │ ☐ Nível Óleo [6.5] qts 📸    │
   │ ☐ Combustível Esq [40] L     │
   │ ☐ Combustível Dir [40] L     │
   │ ☐ Dreno combustível 📸       │
   │ ...                          │
   │                              │
   │ Progress: 12/37 (32%)        │
   │ [ Continuar ]                │
   └──────────────────────────────┘
    ↓
7. 📋 DADOS INICIAIS AERONAVE:
   ┌──────────────────────────────┐
   │ PT-ABC - Cessna 152          │
   │                              │
   │ Hobbs Início: [2847.5] h     │
   │ Combustível Total: [80.0] L  │
   │ Nível Óleo: [6.5] qts        │
   │                              │
   │ Horário Decolagem:           │
   │ Previsto: 10:00              │
   │ Real: [____]                 │
   │                              │
   │ Weather Briefing:            │
   │ Vento: [180°] @ [8] kt       │
   │ Visibilidade: [10] km        │
   │ Teto: [3000] ft              │
   │ QNH: [1013] hPa              │
   │ Obs: [CAVOK]                 │
   │                              │
   │ [ Salvar e Continuar ]       │
   └──────────────────────────────┘
    ↓
8. 📶 CONECTAR ESP32:
   ┌──────────────────────────────┐
   │ 🔌 Conectar SPU              │
   │                              │
   │ 1. Ligar ESP32 na aeronave   │
   │ 2. Aguardar WiFi "C-qfly-AP" │
   │ 3. Conectar tablet ao WiFi   │
   │                              │
   │ Status: 🔍 Procurando...     │
   │                              │
   │ [ Conectar Manualmente ]     │
   └──────────────────────────────┘
    ↓
   [App detecta WiFi "C-qfly-AP" automaticamente]
   [Conecta WebSocket ws://192.168.4.1:81]
    ↓
9. ⚙️ CALIBRAÇÃO SENSORES:        ⭐ CORRIGIDO
   ┌──────────────────────────────┐
   │ 🎯 Calibrando Sensores...    │
   │    (Flutter controlando)     │
   │                              │
   │ ✅ Acelerômetro - OK         │
   │ ✅ Giroscópio - OK           │
   │ ✅ Bússola - Curitiba -20°   │
   │ ✅ Barômetro - 1013 hPa      │
   │ 🛰️ GPS - Aguardando fix...   │
   │    Satélites: 7/12           │
   │                              │
   │ [Flutter envia comandos ao   │
   │  ESP32 para calibrar cada    │
   │  sensor individualmente]     │
   │                              │
   │ [Calibração leva ~30s]       │
   └──────────────────────────────┘
    ↓
   [Flutter recebe {"calibrado": true, "status": "ready"}]
    ↓
✅ PRONTO PARA VOO
   ┌──────────────────────────────┐
   │ ✈️ Sistema Pronto!           │
   │                              │
   │ ✅ Checklist: 37/37          │
   │ ✅ ESP32: Conectado          │
   │ ✅ Calibração: OK            │
   │ ✅ GPS: 12 satélites         │
   │ ✅ Bateria: 98%              │
   │                              │
   │ [ INICIAR VOO ] 🚀           │
   └──────────────────────────────┘
```

### ✈️ **DURANTE VOO (Telemetria Real-Time + Live 4G)**

```
┌────────────────────────────────────────────────────────────────┐
│  TABLET INSTRUTOR (Cockpit)                                    │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  📊 SIXPACK DIGITAL (tempo real)                               │
│  ┌──────────┬──────────┬──────────┐                            │
│  │ VELOCÍM. │ ALTÍMETR │ HORIZ.   │                            │
│  │  145 kt  │ 2850 ft  │ ARTIF.   │                            │
│  │          │          │  ╱───╲   │                            │
│  └──────────┴──────────┴──────────┘                            │
│  ┌──────────┬──────────┬──────────┐                            │
│  │ BÚSSOLA  │ VARIÔM.  │ COORD.   │                            │
│  │  087°    │ +236fpm  │ CURVA    │                            │
│  │    ↑     │    ↑     │   ─○─    │                            │
│  └──────────┴──────────┴──────────┘                            │
│                                                                │
│  🗺️ MAPA (GPS tracking)                                        │
│  [Trajeto em tempo real sobreposto ao mapa]                    │
│                                                                │
│  📈 TELEMETRIA                                                 │
│  • ESP32: ✅ Conectado (20Hz)                                  │
│  • Pacotes: 45.230 recebidos                                   │
│  • GPS: 12 sats / HDOP 0.8                                     │
│  • Bateria: 87%                                                │
│  • Storage: 2.1GB livre                                        │
│                                                                │
│  ⚠️ ALERTAS                                                    │
│  [Nenhum alerta no momento]                                    │
│                                                                │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│  ESP32 SPU (Aviônica)                                          │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  📡 SENSORES LENDO (20Hz):                                     │
│  • GPS: -25.4035, -49.2941 (12 sats)                           │
│  • Altitude: 853.4m (2800.5ft)                                 │
│  • Velocidade: 145.2 km/h                                      │
│  • Heading: 087° (E)                                           │
│  • Pitch: -2.3° (nariz ligeiramente baixo)                     │
│  • Roll: 15.7° (inclinado direita)                             │
│  • Variômetro: +1.2 m/s (+236 fpm)                             │
│  • Temperatura: 28.5°C                                         │
│  • Pressão: 90812 Pa                                           │
│                                                                │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│  TABLET: GRAVAÇÃO LOCAL                                        │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  📁 /flights/pending_sync/flight_012/                          │
│     ├─ telemetry.db (SQLite)                                    │
│     │   └─ 45.230 registros (2.1MB)                             │
│     ├─ metadata.json                                            │
│     └─ photos/                                                  │
│         ├─ pre_instructor.jpg                                   │
│         └─ pre_student.jpg                                      │
│                                                                │
│  ✅ Todos pacotes salvos localmente                            │
│  ✅ Funciona 100% offline                                      │
│                                                                │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│  LIVE TRACKING 4G (Opcional) ⭐ NOVO                           │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  SE tablet tiver chip 4G/5G:                                   │
│                                                                │
│  📤 ENVIANDO AO VIVO (a cada X segundos):                      │
│  • Posição GPS atual                                           │
│  • Altitude, velocidade                                        │
│  • Heading, pitch, roll                                        │
│  • Status sistemas                                             │
│                                                                │
│  Dados comprimidos: ~2KB/pacote                                │
│  Uso 4G: ~1.4MB/hora voo                                       │
│                                                                │
│  🌐 WEB APP (Base/Gestor):                                     │
│  Vê em tempo real:                                             │
│  • Mapa com posição aeronave                                   │
│  • Todos instrumentos ao vivo                                  │
│  • Múltiplas aeronaves simultâneas                             │
│  • Alertas automáticos                                         │
│                                                                │
└────────────────────────────────────────────────────────────────┘

⚠️ DESCONEXÃO WiFi ESP32:                     ⭐ NOVO
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  [WiFi lost - reconectando...]                                 │
│                                                                │
│  🔄 RECONEXÃO AUTOMÁTICA:                                      │
│  • Monitora conexão a cada 2s                                  │
│  • Verifica SSID = "CODIGO-qfly-AP"                            │
│  • Tenta reconectar WebSocket                                  │
│  • Tentativas: Infinitas (até voo acabar)                      │
│                                                                │
│  📱 TABLET:                                                    │
│  • Continua enquanto conexão WebSocket (localmente)            │
│  • Mostra últimos dados conhecidos                             │
│  • Aviso visual: "Telemetria offline"                          │
│                                                                │
│  📡 ESP32:                                                     │
│  • Aguarda reconexão tablet                                    │
│                                                                │
│  ✅ REDUNDÂNCIA TOTAL                                          │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### 🛬 **PÓS-VOO (Avaliação + Sync)**

```
1. 🛬 CONFIRMAÇÃO FINALIZAÇÃO:
   ┌──────────────────────────────────────┐
   │ ⚠️ Confirmar Fim de Voo?             │
   │                                      │
   │ Verificações automáticas:            │
   │ ✅ Velocidade: 0 km/h                │
   │ ✅ Motor: Desligado                  │
   │ ✅ Aeronave: Parada                  │
   │                                      │
   │ O voo foi realmente finalizado       │
   │ com segurança?                       │
   │                                      │
   │ [ Não, ainda em voo ]                │
   │ [ Sim, finalizar ] ✅                │
   └──────────────────────────────────────┘

2. 📋 DADOS FINAIS AERONAVE:
   ┌──────────────────────────────────────┐
   │ PT-ABC - Cessna 152                  │
   │                                      │
   │ Hobbs Final: [2848.9] h              │
   │ Diferença: 1.4h ✅ (calculado auto)  │
   │                                      │
   │ Combustível Abastecido:              │
   │ [40.0] litros                        │
   │                                      │
   │ Horário Pouso Real:                  │
   │ [11:38]                              │
   │                                      │
   │ Problemas/Anormalidades:             │
   │ [Nenhum]                             │
   │                                      │
   │ [ Continuar ]                        │
   └──────────────────────────────────────┘

3. 📸 FOTOS PÓS-VOO:
   ┌──────────────────────────────────────┐
   │ 📷 Fotos Obrigatórias                │
   │                                      │
   │ [ 📸 Foto Instrutor (pós) ]          │
   │ ✅ Carlos Silva                      │
   │                                      │
   │ [ 📸 Foto Aluno (pós) ]              │
   │ ✅ João Pedro                        │
   │                                      │
   │ Obrigatórias para CIV ANAC           │
   │                                      │
   │ [ Continuar ]                        │
   └──────────────────────────────────────┘

4. 📊 AVALIAÇÃO DIGITAL FAP:
   ┌──────────────────────────────────────┐
   │ 📊 Avaliação de Voo                  │
   │                                      │
   │ Missão: Curvas 30°                   │
   │ Template: Padrão MCA 58-3            │
   │                                      │
   │ ITEM 1: Decolagem                    │
   │ Nota: ●●●●○ [4]                      │
   │ Obs: [Boa técnica]                   │
   │                                      │
   │ ITEM 2: Subida                       │
   │ Nota: ●●●●○ [4]                      │
   │ Obs: [Nivelamento preciso]           │
   │                                      │
   │ ITEM 3: Voo Nivelado                 │
   │ Nota: ●●●●● [5]                      │
   │ Obs: [Excelente controle]            │
   │                                      │
   │ ITEM 4: Curvas Coordenadas           │
   │ Nota: ●●●○○ [3] ⚠️                   │
   │ Obs: [Perda altitude, precisa        │
   │       mais prática]                  │
   │                                      │
   │ ITEM 5: Descida                      │
   │ Nota: ●●●●○ [4]                      │
   │                                      │
   │ ITEM 6: Pouso                        │
   │ Nota: ●●●●○ [4]                      │
   │                                      │
   │ ──────────────────────────           │
   │ NOTA FINAL: 4.0                      │
   │ RESULTADO: ✅ APROVADO               │
   │                                      │
   │ Observações Gerais:                  │
   │ [Aluno demonstrou boa...]            │
   │                                      │
   │ Pontos Fortes:                       │
   │ [Pousos consistentes...]             │
   │                                      │
   │ Pontos Melhorar:                     │
   │ [Coordenação curvas...]              │
   │                                      │
   │ [ ✍️ Assinar (Instrutor) ]           │
   └──────────────────────────────────────┘

5. ✍️ ASSINATURAS DIGITAIS:
   ┌──────────────────────────────────────┐
   │ ✍️ Assinar Digitalmente              │
   │                                      │
   │ Instrutor:                           │
   │ [ Desenhar assinatura aqui ]         │
   │ ✅ Carlos Silva - 05/11/2025         │
   │                                      │
   │ Aluno:                               │
   │ [ Desenhar assinatura aqui ]         │
   │ ✅ João Pedro - 05/11/2025           │
   │                                      │
   │ Salvas como PNG                      │
   │                                      │
   │ [ Confirmar Assinaturas ]            │
   └──────────────────────────────────────┘

6. 💾 SALVAR TUDO LOCALMENTE:
   ┌──────────────────────────────────────┐
   │ ✅ Salvando Voo Localmente...        │
   │                                      │
   │ ✅ Metadata                          │
   │ ✅ Telemetria (45.230 pacotes)       │
   │ ✅ Avaliação FAP                     │
   │ ✅ Fotos (4 imagens)                 │
   │ ✅ Assinaturas (2)                   │
   │ ✅ Plano voo (se houver)             │
   │                                      │
   │ Total: 3.2 MB                        │
   │ Storage disponível: 4.8 GB           │
   │                                      │
   │ [ OK ]                               │
   └──────────────────────────────────────┘

7. 📓 DIÁRIO DE BORDO (Opcional):
   ┌──────────────────────────────────────┐
   │ 📓 Diário de Bordo                   │
   │                                      │
   │ Escolha uma opção:                   │
   │                                      │
   │ ○ ✍️ Digitar no Tablet Agora         │
   │   (Sistema guarda backup digital)    │
   │                                      │
   │   Observações do voo:                │
   │   [___________________________]      │
   │   [___________________________]      │
   │   [___________________________]      │
   │                                      │
   │   Dados incluídos automaticamente:   │
   │   • Data: 05/11/2025                 │
   │   • Hobbs: 2847.5 → 2848.9 (1.4h)   │
   │   • Aluno: João Pedro Santos         │
   │   • Instrutor: Carlos Silva          │
   │   • Aeronave: PT-ABC                 │
   │   • Resultado: Aprovado              │
   │                                      │
   │ ○ ⏭️ Anotar no Papel Depois          │
   │   (Diário físico obrigatório no avião)│
   │                                      │
   │ [ Salvar ] [ Pular ]                 │
   └──────────────────────────────────────┘

8. ⏳ AGUARDAR WiFi AEROCLUBE:
   ┌──────────────────────────────────────┐
   │ 📶 Procurando WiFi...                │
   │                                      │
   │ Voos pendentes sync: 1               │
   │ Tamanho: 3.2 MB                      │
   │                                      │
   │ Aguardando conexão WiFi aeroclube    │
   │ para sincronizar automaticamente     │
   │                                      │
   │ [ Sincronizar Via 4G Agora ]         │
   │ [ Sincronizar Depois ]               │
   └──────────────────────────────────────┘

9. 🔄 SINCRONIZAÇÃO AUTOMÁTICA:
   ┌──────────────────────────────────────┐
   │ ✅ WiFi Conectado!                   │
   │ SSID: Aeroclube_Curitiba             │
   │                                      │
   │ 📤 Sincronizando Voo 012...          │
   │                                      │
   │ Progresso: [████████████░░░] 80%     │
   │                                      │
   │ • Metadata: ✅ Enviado               │
   │ • Telemetria: 🔄 Enviando            │
   │ • Fotos: ⏳ Aguardando               │
   │ • Avaliação: ⏳ Aguardando           │
   │                                      │
   │ Enviando para Backend...             │
   └──────────────────────────────────────┘

10. ✅ BACKEND PROCESSA AUTOMATICAMENTE:
    ┌──────────────────────────────────────┐
    │ 🖥️ Backend Processando...            │
    │                                      │
    │ ✅ Salvar PostgreSQL                 │
    │ ✅ Upload fotos Supabase Storage     │
    │ ✅ Comprimir telemetria              │
    │ ✅ Gerar XML CIV Digital             │
    │ ✅ Assinar digitalmente (ICP-Brasil) │
    │ ✅ Enviar API ANAC                   │
    │ ✅ Receber protocolo ANAC            │
    │ ✅ Atualizar Hobbs aeronave          │
    │ ✅ Notificar instrutor               │
    │ ✅ Notificar aluno                   │
    │                                      │
    │ Tempo total: 4.7 segundos            │
    └──────────────────────────────────────┘

11. 🏛️ REGISTRO ANAC CONFIRMADO:
    ┌──────────────────────────────────────┐
    │ ✅ CIV DIGITAL REGISTRADO ANAC       │
    │                                      │
    │ Backend enviou XML CIV para ANAC     │
    │ ANAC validou e registrou oficialmente│
    │                                      │
    │ Protocolo CIV:                       │
    │ CIV-2025-BR-AAC-001-00847            │
    │                                      │
    │ Data registro:                       │
    │ 05/11/2025 às 11:47:23               │
    │                                      │
    │ Status: REGISTRADO ✅                │
    │                                      │
    │ Voo oficial no histórico aluno       │
    └──────────────────────────────────────┘

12. 📱 CONFIRMAÇÃO NO TABLET:
    ┌──────────────────────────────────────┐
    │ ✅ Voo Sincronizado com Sucesso!     │
    │                                      │
    │ VOO-2025-00847                       │
    │ 05/11/2025 - 1.4 horas               │
    │                                      │
    │ ✅ Salvo no servidor                 │
    │ ✅ CIV enviado ANAC                  │
    │ ✅ Protocolo: CIV-2025-...           │
    │                                      │
    │ 📧 Notificações enviadas:            │
    │ • Email instrutor                    │
    │ • Email aluno                        │
    │ • Push notification app              │
    │                                      │
    │ [ Ver Detalhes no Web App ]          │
    │ [ Fazer Novo Voo ]                   │
    └──────────────────────────────────────┘

13. 🗑️ LIMPEZA AUTOMÁTICA STORAGE:
    ┌──────────────────────────────────────┐
    │ 🧹 Limpando Storage Local...         │
    │                                      │
    │ Deletado:                            │
    │ • Voo 012 da pasta pending_sync      │
    │                                      │
    │ Mantido em cache:                    │
    │ • Últimos 3 voos (acesso rápido)     │
    │                                      │
    │ Storage liberado: 3.2 MB             │
    │ Storage disponível: 4.8 GB           │
    │                                      │
    │ ✅ Pronto para próximo voo           │
    └──────────────────────────────────────┘

✅ VOO COMPLETO E ARQUIVADO
```

---

## 📦 PAYLOAD ESP32 → TABLET (CORRIGIDO)

### JSON Structure v2.0 (768 bytes @ 20Hz)

```json
{
  // ========== SIX-PACK PRINCIPAL ==========
  "velocidade": 145.2,           // km/h (GPS)
  "altitude": 853.4,              // metros (barômetro)
  "altitude_ft": 2800.5,          // pés
  "heading": 087,                 // graus (0-360)
  "pitch": -2.3,                  // graus (nariz up/down)
  "roll": 15.7,                   // graus (asa left/right)
  "variometro": 1.2,              // m/s (subida/descida)
  "variometro_ft": 236.2,         // pés/min
  
  // ========== COORDENADOR DE CURVA ==========
  "coordcurva": -3.1,             // diferença angular
  
  // ========== DADOS AMBIENTAIS ==========
  "temperatura": 28.5,            // °C
  "pressao": 90812,               // Pa (Pascals)
  
  // ========== GPS ==========
  "lat": -25.4035174,
  "lng": -49.2940581,
  "satelites": 12,
  "hdop": 0.95,                   // precisão GPS
  
  // ========== GIROSCÓPIO L3G4200D ==========
  "gyro_x": 245,                  // raw values
  "gyro_y": -89,
  "gyro_z": 1024,
  
  // ========== ACELERÔMETRO ADXL345 ==========
  "acel_x": 0.12,                 // g's
  "acel_y": -0.05,
  "acel_z": 1.02,
  
  // ========== LSM6DS3 (backup/redundância) ==========
  "lsm_ax": 0.11,
  "lsm_ay": -0.04,
  "lsm_az": 1.01,
  "lsm_gx": 2.34,
  "lsm_gy": -1.12,
  "lsm_gz": 0.78,
  
  // ========== METADATA (NOVOS CAMPOS v2.0) ========== ⭐
  "timestamp": 1730824567890,     // epoch milliseconds
  "seq": 45230,                   // número sequencial pacote
  "status": "ok",                 // "ok", "warning", "error"
  "calibrado": true,              // sensores calibrados?
  "bateria": 4.15                 // volts (3.7-4.2V = 18650)
}
```

### Correções ESP32 (main.ino) - VERIFICAR (NÃO ESTUDADO)⚠️

**Adicionar no código:**

```cpp
// Variáveis globais (adicionar):
unsigned long packetCounter = 0;
bool isCalibrated = false;
const int BAT_PIN = 34; // GPIO para ler bateria

// No loop(), ao montar JSON (linha ~424):
doc["timestamp"] = millis();
doc["seq"] = packetCounter++;
doc["status"] = "ok";  // TODO: adicionar lógica validação
doc["calibrado"] = isCalibrated;
doc["bateria"] = analogRead(BAT_PIN) * (3.3/4095.0) * 2.0;

// Implementar auto-calibração (chamar no setup):
void autoCalibration() {
  // Zerar offsets acelerômetro
  // Ajustar declinação magnética
  // Aguardar GPS fix
  // ...
  isCalibrated = true;
}
```

**Status:** ⚠️ Correções necessárias no firmware

---

## 🔐 AUTENTICAÇÃO & AUTORIZAÇÃO (HÍBRIDO)

### Estratégia Supabase + N8N ⭐ NOVO

```
┌─────────────────────────────────────────────────────────────┐
│  ARQUITETURA AUTENTICAÇÃO HÍBRIDA                           │
└─────────────────────────────────────────────────────────────┘

Frontend (Web/Mobile)
    ↓
┌─────────────────────────┐
│   SUPABASE AUTH         │
│                         │
│ • Login email/senha     │
│ • JWT tokens            │
│ • Refresh automático    │
│ • MFA (pós-MVP)         │
│ • OAuth (pós-MVP)       │
│ • Row Level Security    │
└────────┬────────────────┘
         │
         │ JWT Token
         │
         ↓
┌─────────────────────────┐       ┌─────────────────────────┐
│   N8N BACKEND           │◄──────┤   SUPABASE POSTGRES     │
│                         │       │                         │
│ • Valida JWT            │       │ • users (auth.users)    │
│ • Business logic        │       │ • user_profiles         │
│ • CIV ANAC              │       │ • flights               │
│ • Telemetry process     │       │ • telemetry             │
│ • Workflows             │       │ • evaluations           │
└─────────────────────────┘       │ • + 20 tabelas          │
                                  └─────────────────────────┘
```

### Setup Supabase

```
┌─────────────────────────────────────────────────────────────┐
│  O QUE SUPABASE JÁ FAZ AUTOMATICAMENTE:                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ Cria tabela usuários (auth.users)                       │
│  ✅ Gerencia tokens de acesso                               │
│  ✅ Gerencia sessões ativas                                 │
│  ✅ Renovação automática tokens                             │
│                                                             │
│  Não precisa configurar nada disso!                         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  O QUE PRECISAMOS CRIAR:                                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📋 Tabela Perfis Usuários (user_profiles)                  │
│                                                             │
│  Campos armazenados:                                        │
│  • Nome completo                                            │
│  • CPF                                                      │
│  • Email                                                    │
│  • Telefone                                                 │
│  • Role (admin/gestor/instrutor/aluno)                      │
│  • Aeroclube vinculado                                      │
│  • Data criação/atualização                                 │
│                                                             │
│  Conectada automaticamente com auth.users                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  SEGURANÇA (Row Level Security - RLS):                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Regra 1: Usuário vê próprio perfil                         │
│  • João só vê perfil do João                                │
│  • Maria só vê perfil da Maria                              │
│                                                             │
│  Regra 2: Admin vê todos perfis                             │
│  • Admin vê João, Maria, todos                              │
│                                                             │
│  Aplicado automaticamente no banco de dados                 │
└─────────────────────────────────────────────────────────────┘

### Fluxo Login (Flutter Mobile)

1. INICIALIZAÇÃO APP:
   ┌──────────────────────────────┐
   │ 📱 App Flutter inicia        │
   │                              │
   │ Conecta com Supabase:        │
   │ • URL projeto                │
   │ • Chave API pública          │
   │                              │
   │ ✅ Conexão estabelecida      │
   └──────────────────────────────┘

2. USUÁRIO FAZ LOGIN:
   ┌──────────────────────────────┐
   │ 🔐 Tela Login                │
   │                              │
   │ Email: carlos@email.com      │
   │ Senha: ********              │
   │                              │
   │ [ Entrar ] →                 │
   └──────────────────────────────┘

3. APP ENVIA PARA SUPABASE:
   ┌──────────────────────────────┐
   │ 📤 Autenticando...           │
   │                              │
   │ Supabase valida credenciais  │
   │ Gera token JWT               │
   │ Cria sessão                  │
   └──────────────────────────────┘

4. APP RECEBE TOKEN:
   ┌──────────────────────────────┐
   │ ✅ Login bem-sucedido!       │
   │                              │
   │ Token JWT recebido           │
   │ Válido por: 1 hora           │
   │                              │
   │ Token usado em TODAS         │
   │ requisições ao backend       │
   └──────────────────────────────┘

5. APP BUSCA PERFIL COMPLETO:
   ┌──────────────────────────────┐
   │ 👤 Buscando perfil...        │
   │                              │
   │ SELECT * FROM user_profiles  │
   │ WHERE id = user_id           │
   │                              │
   │ Retorna:                     │
   │ • Nome: Carlos Silva         │
   │ • Role: Instrutor            │
   │ • Aeroclube: Curitiba        │
   └──────────────────────────────┘

6. TOKEN RENOVAÇÃO AUTOMÁTICA:
   ┌──────────────────────────────┐
   │ 🔄 Renovação Inteligente     │
   │                              │
   │ App monitora token:          │
   │ • Se próximo de expirar      │
   │ • Renova automaticamente     │
   │ • Usuário nem percebe        │
   │                              │
   │ Sessão contínua garantida    │
   └──────────────────────────────┘

### N8N Valida JWT (Backend)

1. REQUISIÇÃO CHEGA NO N8N:
   ┌──────────────────────────────┐
   │ 📥 N8N recebe requisição     │
   │                              │
   │ Exemplo:                     │
   │ GET /api/alunos              │
   │                              │
   │ Header:                      │
   │ Authorization: Bearer {token}│
   └──────────────────────────────┘

2. N8N EXTRAI TOKEN:
   ┌──────────────────────────────┐
   │ 🔍 Extraindo token...        │
   │                              │
   │ Pega do header:              │
   │ Authorization: Bearer XXX    │
   │                              │
   │ Token: eyJhbGciOi...         │
   └──────────────────────────────┘

3. N8N VALIDA TOKEN:
   ┌──────────────────────────────┐
   │ ✅ Validando...              │
   │                              │
   │ Verifica:                    │
   │ ✓ Assinatura correta?        │
   │ ✓ Não expirou?               │
   │ ✓ Formato válido?            │
   │                              │
   │ Usa chave secreta Supabase   │
   └──────────────────────────────┘

4. SE TOKEN VÁLIDO:
   ┌──────────────────────────────┐
   │ ✅ Token OK!                 │
   │                              │
   │ Extrai dados token:          │
   │ • ID usuário                 │
   │ • Email                      │
   │ • Expiração                  │
   └──────────────────────────────┘

5. N8N BUSCA PERFIL COMPLETO:
   ┌──────────────────────────────┐
   │ 👤 Buscando perfil...        │
   │                              │
   │ SELECT * FROM user_profiles  │
   │ WHERE id = {user_id}         │
   │                              │
   │ Retorna:                     │
   │ • Role: instrutor            │
   │ • Aeroclube: ABC             │
   │ • Permissões                 │
   └──────────────────────────────┘

6. N8N RETORNA DADOS:
   ┌──────────────────────────────┐
   │ 📤 Retorno para workflow     │
   │                              │
   │ Dados disponíveis:           │
   │ • authenticated: true        │
   │ • user_id: XXX               │
   │ • role: instrutor            │
   │ • aeroclube_id: YYY          │
   │                              │
   │ Workflow continua normal     │
   └──────────────────────────────┘

7. SE TOKEN INVÁLIDO:
   ┌──────────────────────────────┐
   │ ❌ Erro Autenticação!        │
   │                              │
   │ Motivos possíveis:           │
   │ • Token expirado             │
   │ • Assinatura inválida        │
   │ • Token falsificado          │
   │ • Formato incorreto          │
   │                              │
   │ Retorna erro 401:            │
   │ "Token inválido"             │
   │                              │
   │ App força novo login         │
   └──────────────────────────────┘
```

### Roles & Permissões (RBAC)

```yaml
admin:
  - Acesso total sistema
  - CRUD todos recursos
  - Configurações globais
  - Logs auditoria
  - Integrações APIs

gestor:
  - CRUD alunos/instrutores
  - CRUD aeronaves
  - Agendamento aulas
  - Relatórios aeroclube
  - Manutenções
  - Não acessa: config sistema, outros aeroclubes

instrutor:
  - Ver seus alunos
  - Realizar voos
  - Avaliar alunos
  - Ver histórico próprio
  - Editar agenda própria
  - Não acessa: CRUD geral, financeiro

aluno:
  - Ver próprio perfil
  - Ver próprios voos
  - Ver avaliações recebidas
  - Ver CIV Digital
  - Upload documentos pessoais
  - Ver próximas aulas
  - Não acessa: dados outros alunos, gestão
```

---

## 💾 DATABASE SCHEMA (PostgreSQL v2.0)

### Visão Geral

```yaml
Total Tabelas: 25+

Principais:
  - aeroclubes (1)
  - users (1) - EXPANDIDO ⭐
  - aircraft (1)
  - courses / phases / missions (3)
  - evaluation_templates (1) - NOVO ⭐
  - flights (1)
  - flight_plans (1) - NOVO ⭐
  - flight_photos (1)
  - evaluations (1)
  - telemetry (1) - PARTICIONADA ⭐
  - aircraft_maintenance (1)
  - documents (1) - NOVO ⭐
  - notifications (1) - NOVO ⭐
  - messages (1) - NOVO ⭐

Logs (5 tabelas): ⭐ NOVO
  - logs_acessos (particionada)
  - logs_alteracoes (particionada)
  - logs_sincronizacao
  - logs_civ_anac
  - logs_erros (particionada)

Features:
  - PostGIS (geoespacial)
  - Particionamento (telemetry + logs por mês)
  - Triggers automáticos (hobbs, updated_at, logs)
  - Views úteis (progresso_alunos, performance_instrutores)
  - RLS (Row Level Security via Supabase)
  - Full-text search (users.full_name)
```

### Destaques v2 do Banco de Dados

```
1. TABELA USERS COMPLETA:
   ┌──────────────────────────────────────┐
   │ Todos campos necessários em 1 tabela │
   │                                      │
   │ • Dados pessoais completos           │
   │ • 3 telefones + emergência           │
   │ • Endereço completo (9 campos)       │
   │ • Campos específicos instrutor       │
   │   (CHT, CANAC, validades)            │
   │ • Campos específicos aluno           │
   │   (matrícula, curso, fase)           │
   │                                      │
   │ 1 tabela = todos perfis              │
   │ Campos dinâmicos por role            │
   └──────────────────────────────────────┘

2. TELEMETRIA PARTICIONADA POR MÊS:
   ┌──────────────────────────────────────┐
   │ Divide dados por mês automaticamente │
   │                                      │
   │ • telemetry_2025_01 (janeiro)        │
   │ • telemetry_2025_02 (fevereiro)      │
   │ • telemetry_2025_03 (março)          │
   │ ...                                  │
   │                                      │
   │ Por quê: Performance                 │
   │ 10M linhas 1 tabela = lento          │
   │ 12 tabelas 800k cada = rápido        │
   │                                      │
   │ Sistema cria partições sozinho       │
   └──────────────────────────────────────┘

3. LOGS COMPLETOS (5 TABELAS):
   ┌──────────────────────────────────────┐
   │ Rastreabilidade 100%                 │
   │                                      │
   │ • logs_acessos: Quem acessou o quê   │
   │ • logs_alteracoes: Audit trail       │
   │ • logs_sincronizacao: Sync mobile    │
   │ • logs_civ_anac: Envios ANAC         │
   │ • logs_erros: Erros sistema          │
   │                                      │
   │ Conformidade: LGPD + ANAC            │
   │ Retenção: 5 anos                     │
   └──────────────────────────────────────┘

4. TRIGGERS AUTOMÁTICOS:
   ┌──────────────────────────────────────┐
   │ Banco executa ações sozinho          │
   │                                      │
   │ • Voo finaliza → Atualiza Hobbs      │
   │ • Hobbs muda → Calcula manutenção    │
   │ • Qualquer alteração → Registra log  │
   │ • Timestamp atualiza automático      │
   │                                      │
   │ Zero intervenção manual              │
   │ Dados sempre consistentes            │
   └──────────────────────────────────────┘

5. VIEWS ÚTEIS:
   ┌──────────────────────────────────────┐
   │ Consultas complexas pré-montadas     │
   │                                      │
   │ • Próximas manutenções (urgência)    │
   │ • Progresso alunos (% conclusão)     │
   │ • Performance instrutores (stats)    │
   │                                      │
   │ Acesso rápido sem SQL complexo       │
   └──────────────────────────────────────┘
---
````

## 🌐 WEB APP - 4 PORTAIS COMPLETOS ⭐ NOVO

### Arquitetura Páginas

```
app.avionica.com
│
├─ / (Landing pública)
│  ├─ Home
│  ├─ Sobre
│  ├─ Preços
│  └─ Contato
│
├─ /login (Página única - redireciona por role)
│
└─ /dashboard (Autenticado)
   │
   ├─ 📊 PORTAL ADMIN
   │  ├─ /dashboard/admin
   │  │  ├─ Overview sistema
   │  │  ├─ Estatísticas globais
   │  │  ├─ Health checks
   │  │  └─ Alertas críticos
   │  │
   │  ├─ /aeroclubes
   │  │  ├─ Lista todos aeroclubes
   │  │  ├─ CRUD aeroclube
   │  │  └─ Configurações por aeroclube
   │  │
   │  ├─ /usuarios
   │  │  ├─ Lista todos usuários
   │  │  ├─ CRUD usuários
   │  │  ├─ Ativação/Suspensão
   │  │  └─ Resetar senhas
   │  │
   │  ├─ /logs
   │  │  ├─ Logs acessos
   │  │  ├─ Logs alterações (audit)
   │  │  ├─ Logs sync mobile
   │  │  ├─ Logs CIV ANAC
   │  │  ├─ Logs erros
   │  │  └─ Filtros avançados
   │  │
   │  ├─ /integrações
   │  │  ├─ API ANAC (config)
   │  │  ├─ Supabase (config)
   │  │  ├─ Storage S3
   │  │  ├─ Email (SMTP)
   │  │  └─ SMS (Twilio)
   │  │
   │  ├─ /configuracoes
   │  │  ├─ Parâmetros sistema
   │  │  ├─ Backup/restore
   │  │  ├─ Manutenção
   │  │  └─ Updates
   │  │
   │  └─ /relatórios
   │     ├─ Uso sistema (todas aeroclubes)
   │     ├─ Performance servidores
   │     ├─ Faturamento
   │     └─ Métricas negócio
   │
   ├─ 🏢 PORTAL GESTOR
   │  ├─ /dashboard/gestor
   │  │  ├─ KPIs aeroclube
   │  │  ├─ Voos hoje
   │  │  ├─ Aeronaves status
   │  │  ├─ Próximas manutenções
   │  │  ├─ Alertas (CMA vencendo, etc)
   │  │  └─ Gráficos desempenho
   │  │
   │  ├─ /alunos
   │  │  ├─ Lista completa
   │  │  ├─ CRUD aluno
   │  │  ├─ Perfil detalhado
   │  │  ├─ Histórico voos
   │  │  ├─ Progressão curso
   │  │  ├─ Documentos
   │  │  ├─ Financeiro (se habilitado)
   │  │  └─ Mensagens
   │  │
   │  ├─ /instrutores
   │  │  ├─ Lista completa
   │  │  ├─ CRUD instrutor
   │  │  ├─ Perfil detalhado
   │  │  ├─ Carga horária
   │  │  ├─ Performance (estatísticas)
   │  │  ├─ Especialidades
   │  │  ├─ Validades (CMA, CHT)
   │  │  └─ Escala mensal
   │  │
   │  ├─ /aeronaves
   │  │  ├─ Lista completa
   │  │  ├─ CRUD aeronave
   │  │  ├─ Status tempo real
   │  │  ├─ Hobbs atual
   │  │  ├─ Histórico manutenções
   │  │  ├─ Próximas manutenções
   │  │  ├─ Utilização (gráficos)
   │  │  ├─ Custos operacionais
   │  │  └─ Documentos
   │  │
   │  ├─ /aulas
   │  │  ├─ 📅 Calendário mensal/semanal ⭐
   │  │  ├─ Agendar nova aula ⭐
   │  │  │  ├─ Selecionar aluno
   │  │  │  ├─ Selecionar instrutor
   │  │  │  ├─ Selecionar aeronave
   │  │  │  ├─ Data/hora
   │  │  │  ├─ Fase/missão
   │  │  │  ├─ Upload plano voo PDF ⭐
   │  │  │  └─ Observações
   │  │  ├─ Editar aula agendada
   │  │  ├─ Cancelar/remarcar
   │  │  ├─ Histórico aulas
   │  │  └─ Conflitos (validação)
   │  │
   │  ├─ /voos (histórico) ⭐ EXPANDIDO
   │  │  ├─ Lista completa
   │  │  ├─ Filtros múltiplos
   │  │  │  ├─ Data/período
   │  │  │  ├─ Aluno
   │  │  │  ├─ Instrutor
   │  │  │  ├─ Aeronave
   │  │  │  ├─ Status CIV
   │  │  │  └─ Resultado (aprovado/reprovado)
   │  │  ├─ Ver detalhes voo
   │  │  ├─ Link replay telemetria ⭐
   │  │  ├─ Ver avaliação FAP
   │  │  ├─ Ver fotos
   │  │  ├─ Download CIV PDF
   │  │  └─ Export CSV/Excel
   │  │
   │  ├─ /live-tracking ⭐ NOVO
   │  │  ├─ Mapa tempo real
   │  │  ├─ Voos ativos agora
   │  │  ├─ Selecionar voo específico
   │  │  ├─ Sixpack digital ao vivo
   │  │  ├─ Telemetria em tempo real
   │  │  ├─ Rota percorrida
   │  │  ├─ Alertas automáticos
   │  │  └─ Multi-tracking (várias aeronaves)
   │  │
   │  ├─ /manutencoes
   │  │  ├─ Lista todas manutenções
   │  │  ├─ Agendar manutenção
   │  │  ├─ CRUD manutenção
   │  │  ├─ Histórico por aeronave
   │  │  ├─ Alertas próximas
   │  │  ├─ Custos (mão obra + peças)
   │  │  └─ Relatórios
   │  │
   │  ├─ /relatorios ⭐ EXPANDIDO
   │  │  ├─ Dashboard BI
   │  │  ├─ Performance Aeroclube
   │  │  │  ├─ Total voos (período)
   │  │  │  ├─ Horas voadas
   │  │  │  ├─ Taxa ocupação aeronaves
   │  │  │  ├─ Consumo combustível
   │  │  │  └─ ROI por aeronave
   │  │  ├─ Progressão Alunos
   │  │  │  ├─ Por fase
   │  │  │  ├─ Taxa aprovação
   │  │  │  ├─ Média tempo formação
   │  │  │  └─ Evasão
   │  │  ├─ Desempenho Instrutores
   │  │  │  ├─ Horas voadas
   │  │  │  ├─ Taxa aprovação alunos
   │  │  │  ├─ Média notas FAP
   │  │  │  └─ Comparativo
   │  │  ├─ Financeiro (se habilitado)
   │  │  │  ├─ Receitas
   │  │  │  ├─ Despesas
   │  │  │  ├─ Lucro
   │  │  │  └─ Projeções
   │  │  ├─ Regulatórios ANAC
   │  │  │  ├─ CIVs enviados
   │  │  │  ├─ Conformidade
   │  │  │  ├─ Alertas
   │  │  │  └─ Auditoria
   │  │  └─ Export
   │  │     ├─ PDF
   │  │     ├─ Excel
   │  │     ├─ CSV
   │  │     └─ PowerPoint
   │  │
   │  └─ /configuracoes
   │     ├─ Dados aeroclube
   │     ├─ Preferências
   │     ├─ Notificações
   │     └─ Integrações
   │
   ├─ 👨‍✈️ PORTAL INSTRUTOR
   │  ├─ /dashboard/instrutor
   │  │  ├─ Resumo pessoal
   │  │  ├─ ⭐ Próxima aula (hoje) ⭐
   │  │  ├─ Meus alunos (resumo)
   │  │  ├─ Horas voadas (mês/ano)
   │  │  ├─ Performance (estatísticas)
   │  │  └─ Alertas (validades)
   │  │
   │  ├─ /agenda ⭐ NOVO
   │  │  ├─ Calendário completo
   │  │  ├─ Ver próximas aulas
   │  │  ├─ Criar nova aula ⭐
   │  │  │  ├─ Selecionar aluno
   │  │  │  ├─ Selecionar aeronave
   │  │  │  ├─ Data/hora
   │  │  │  ├─ Fase/missão
   │  │  │  ├─ Upload plano voo PDF ⭐
   │  │  │  └─ Observações
   │  │  ├─ Editar aula
   │  │  ├─ Cancelar aula
   │  │  ├─ Disponibilidade semanal
   │  │  └─ Sincronizar com mobile
   │  │
   │  ├─ /meus-alunos
   │  │  ├─ Lista completa
   │  │  ├─ Perfil detalhado
   │  │  ├─ Progresso individual
   │  │  ├─ Histórico voos
   │  │  ├─ Gráfico evolução notas
   │  │  ├─ Anotações privadas ⭐
   │  │  ├─ Próximas aulas
   │  │  └─ Enviar mensagem
   │  │
   │  ├─ /meus-voos
   │  │  ├─ Lista completa
   │  │  ├─ Filtros (data, aluno, aeronave)
   │  │  ├─ Ver detalhes
   │  │  ├─ Link replay telemetria
   │  │  ├─ Ver avaliação FAP
   │  │  └─ Reenviar CIV (se erro)
   │  │
   │  ├─ /relatorios
   │  │  ├─ Meu desempenho
   │  │  ├─ Horas voadas
   │  │  ├─ Taxa aprovação alunos
   │  │  ├─ Média notas FAP
   │  │  ├─ Comparativo outros instrutores
   │  │  └─ Export PDF
   │  │
   │  ├─ /certificacoes
   │  │  ├─ CHT (validade)
   │  │  ├─ CMA (validade)
   │  │  ├─ Habilitações
   │  │  ├─ Especialidades
   │  │  ├─ Upload documentos
   │  │  └─ Alertas vencimento
   │  │
   │  └─ /perfil
   │     ├─ Dados pessoais
   │     ├─ Contatos
   │     ├─ Endereço
   │     ├─ Alterar senha
   │     ├─ Foto perfil
   │     └─ Preferências
   │
   └─ 👨‍🎓 PORTAL ALUNO ⭐ OBRIGATÓRIO MVP
      ├─ /dashboard/aluno
      │  ├─ Bem-vindo personalizado
      │  ├─ Próxima aula agendada ⭐
      │  ├─ Progresso curso (%)
      │  ├─ Gráfico evolução notas
      │  ├─ Horas voadas vs previstas
      │  ├─ Último voo (resumo)
      │  └─ Notificações/avisos
      │
      ├─ /meus-voos ⭐ PRINCIPAL
      │  ├─ Lista completa histórico
      │  ├─ Filtros (data, instrutor, resultado)
      │  ├─ Ver detalhes voo
      │  │  ├─ Data, duração, Hobbs
      │  │  ├─ Instrutor
      │  │  ├─ Aeronave
      │  │  ├─ Missão realizada
      │  │  ├─ ⭐ Notas FAP detalhadas ⭐
      │  │  ├─ Observações instrutor
      │  │  ├─ Pontos fortes
      │  │  ├─ Pontos melhorar
      │  │  └─ Fotos (pré/pós)
      │  ├─ 🎬 Replay Telemetria 3D ⭐
      │  │  ├─ Mapa 3D interativo
      │  │  ├─ Visualizar trajeto completo
      │  │  ├─ Playback controles
      │  │  ├─ Sixpack sincronizado
      │  │  ├─ Gráficos performance
      │  │  ├─ Anotações instrutor
      │  │  └─ Compartilhar link
      │  └─ Export histórico (PDF)
      │
      ├─ /progressao ⭐ MOTIVACIONAL
      │  ├─ Fase atual
      │  ├─ % Conclusão curso
      │  ├─ Horas voadas / Total necessárias
      │  ├─ Missões completadas
      │  ├─ Próximas missões
      │  ├─ Gráfico evolução notas (temporal)
      │  ├─ Competências adquiridas
      │  ├─ Previsão formatura
      │  └─ Conquistas (gamification - futuro)
      │
      ├─ /civ-digital ⭐ REGULATÓRIO
      │  ├─ Ver todos voos registrados ANAC
      │  ├─ Status CIV (enviado/pendente/erro)
      │  ├─ Protocolos ANAC
      │  ├─ Baixar PDF CIV oficial
      │  ├─ Consultar portal ANAC (link)
      │  ├─ Histórico completo
      │  └─ Alertas (se erro envio)
      │
      ├─ /documentos ⭐ IMPORTANTE
      │  ├─ Upload documentos
      │  │  ├─ CMA (com validade)
      │  │  ├─ RG/CPF
      │  │  ├─ Comprovante residência
      │  │  ├─ Certificados anteriores
      │  │  └─ Outros
      │  ├─ Download documentos
      │  ├─ Status validação
      │  ├─ Alertas vencimento
      │  └─ Histórico uploads
      │
      ├─ /proximas-aulas
      │  ├─ Calendário próximas aulas
      │  ├─ Detalhes aula
      │  │  ├─ Data/hora
      │  │  ├─ Instrutor
      │  │  ├─ Aeronave
      │  │  ├─ Missão planejada
      │  │  └─ Observações
      │  ├─ Cancelar aula (com antecedência)
      │  └─ Adicionar ao Google Calendar
      │
      ├─ /financeiro (se habilitado)
      │  ├─ Faturas abertas
      │  ├─ Pagamentos realizados
      │  ├─ Histórico cobrança
      │  ├─ Próximos vencimentos
      │  ├─ Download boletos
      │  └─ Relatórios anuais
      │
      ├─ /mensagens
      │  ├─ Inbox (recebidas)
      │  ├─ Enviadas
      │  ├─ Nova mensagem
      │  │  ├─ Para instrutor
      │  │  ├─ Para secretaria
      │  │  └─ Anexos
      │  └─ Notificações push
      │
      └─ /perfil
         ├─ Dados pessoais
         ├─ Contatos
         ├─ Endereço
         ├─ Contato emergência
         ├─ Alterar senha
         ├─ Foto perfil
         ├─ Preferências notificações
         └─ Privacidade
```

```
┌─────────────────────────────────────────────────────────────┐
│  🎬 REPLAY VOO - VOO-2025-00847                             │
│  João Pedro Santos • 05/11/2025 • 1.4h • ✅ Aprovado       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │                                                       │ │
│  │  🗺️ MAPA 3D INTERATIVO (Cesium.js)                   │ │
│  │                                                       │ │
│  │  [Visualização 3D com terreno real]                  │ │
│  │  [Trajeto completo marcado em azul]                  │ │
│  │  [Modelo 3D aeronave se movendo]                     │ │
│  │  [Marcadores eventos importantes]                    │ │
│  │                                                       │ │
│  │  Câmera:                                             │ │
│  │  ○ Follow (segue aeronave)                           │ │
│  │  ○ Cockpit (visão piloto)                            │ │
│  │  ● Free (controle livre)                             │ │
│  │                                                       │ │
│  │  Layers:                                             │ │
│  │  ☑ Trajeto completo                                  │ │
│  │  ☑ Aeródromos                                        │ │
│  │  ☑ Altitude (cores)                                  │ │
│  │  ☐ Espaço aéreo (CTR/TMA)                            │ │
│  │                                                       │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  📊 SIXPACK DIGITAL SINCRONIZADO                      │ │
│  │  ┌─────────┬─────────┬─────────┬─────────┐           │ │
│  │  │ VELOC.  │ ALTÍM.  │ HORIZ.  │ BÚSSOLA │           │ │
│  │  │ 145 kt  │ 2850 ft │ ARTIF.  │  087°   │           │ │
│  │  └─────────┴─────────┴─────────┴─────────┘           │ │
│  │  ┌─────────┬─────────┬─────────────────────┐         │ │
│  │  │ VARIÔM. │ COORD.  │ [Destaque limites]  │         │ │
│  │  │ +236fpm │ CURVA   │ Roll >30° = ⚠️      │         │ │
│  │  └─────────┴─────────┴─────────────────────┘         │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  📈 GRÁFICOS ANÁLISE                                  │ │
│  │  ┌─ Altitude x Tempo ───────────────────────────────┐ │ │
│  │  │    3000ft ┼╱‾‾‾‾‾‾‾‾‾╲                           │ │
│  │  │    2000ft ┼          ╲                          │ │
│  │  │    1000ft ┼           ╲___                      │ │
│  │  │         0 └────────────────────────────         │ │
│  │  │           0m    20m    40m    60m    80m        │ │
│  │  └───────────────────────────────────────────────┘ │ │
│  │  ┌─ Roll/Pitch x Tempo ─────────────────────────────┐ │ │
│  │  │   +30° ┼  ╱╲  ╱╲                ⚠️ Roll >30°    │ │
│  │  │     0° ┼──  ──  ────────────────               │ │
│  │  │   -30° ┼                                       │ │
│  │  └───────────────────────────────────────────────┘ │ │
│  │  ┌─ Velocidade x Tempo ─────────────────────────────┐ │ │
│  │  │  150kt ┼‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾                   │ │
│  │  │  100kt ┼                                       │ │
│  │  │   50kt ┼                         ╲_            │ │
│  │  └───────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  ⏯️ CONTROLES PLAYBACK                                 │ │
│  │  ◄◄  ⏸️  ▶️  ►►  [════════●══════════] 00:45 / 1:23:45│ │
│  │                                                       │ │
│  │  Velocidade: [0.5x] [1x] [2x] [5x] [10x]             │ │
│  │                                                       │ │
│  │  Pular para:                                          │ │
│  │  • [Decolagem]  • [Curva 1]  • [Curva 2]  • [Pouso]  │ │
│  │                                                       │ │
│  │  Loop: [00:30 - 00:45] ⟲                              │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  📝 ANOTAÇÕES & EVENTOS                                │ │
│  │  ┌───────────────────────────────────────────────────┐ │
│  │  │ 00:12:34 - ⚠️ Roll excessivo (35°)                │ │
│  │  │            Instrutor: "Corrigir inclinação"       │ │
│  │  │            [ Pular para este momento ]            │ │
│  │  ├───────────────────────────────────────────────────┤ │
│  │  │ 00:23:45 - ✅ Pouso excelente                     │ │
│  │  │            Instrutor: "Ótima técnica!"            │ │
│  │  │            [ Pular para este momento ]            │ │
│  │  └───────────────────────────────────────────────────┘ │
│  │                                                       │ │
│  │  [ + Nova Anotação ]                                  │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  🔗 COMPARTILHAR & EXPORT                              │ │
│  │  • Copiar link timestamp: [Copiar Link 00:12:34]      │ │
│  │  • Download telemetria: [CSV] [JSON]                  │ │
│  │  • Gerar vídeo replay: [MP4] ⏳ 3 min render          │ │
│  │  • Export relatório: [PDF com gráficos]               │ │
│  │  • Link público (7 dias): [Gerar Link]                │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Stack Técnico Replay:**

```yaml
Mapa 3D:
  - Cesium.js (open source)
  - Terreno: Cesium World Terrain
  - Modelo aeronave: glTF 3D (Cessna 152)
  - Câmeras: Follow / Cockpit / Free

Gráficos:
  - Recharts (React)
  - Synced com playback timestamp
  - Destaque valores críticos automático

Playback:
  - React hooks custom
  - Controles HTML5 style
  - Velocidades: 0.5x até 10x
  - Seek / Loop seção

Export Vídeo:
  - FFmpeg.wasm (client-side)
  - Renderiza no navegador
  - MP4 H.264
  - ~3 min para 1h voo

Performance:
  - Lazy load telemetria (chunks)
  - WebWorker para processamento
  - Canvas offscreen rendering
```

---

## 📱 MOBILE APP - FUNCIONALIDADES COMPLETAS

### Storage Local Otimizado ⭐ NOVO

```
/data/data/com.avionica.mobile/
│
├─ databases/
│  ├─ app.db (SQLite - metadata geral)
│  ├─ telemetry_flight_001.db ⭐ 1 DB por voo
│  ├─ telemetry_flight_002.db
│  └─ telemetry_flight_003.db
│
├─ files/
│  ├─ cache/ (dados aeroclube)
│  │  ├─ students.json
│  │  ├─ aircraft.json
│  │  ├─ instructors.json
│  │  ├─ missions.json
│  │  ├─ evaluation_templates.json
│  │  └─ last_sync.json
│  │
│  ├─ flights/
│  │  ├─ pending_sync/ (não sincronizados)
│  │  │  ├─ flight_001/
│  │  │  │  ├─ metadata.json
│  │  │  │  ├─ telemetry.db → symlink
│  │  │  │  ├─ evaluation.json
│  │  │  │  ├─ flight_plan.pdf
│  │  │  │  └─ photos/
│  │  │  │     ├─ pre_instructor.jpg (JPEG 85%)
│  │  │  │     ├─ pre_student.jpg
│  │  │  │     ├─ post_instructor.jpg
│  │  │  │     └─ post_student.jpg
│  │  │  └─ flight_002/
│  │  │
│  │  └─ synced/ (últimos 3 para cache)
│  │     ├─ flight_summary_001.json (metadata apenas)
│  │     ├─ flight_summary_002.json
│  │     └─ flight_summary_003.json
│  │
│  ├─ maps_offline/
│  │  ├─ tiles/ (Google Maps cache)
│  │  └─ regions.json
│  │
│  └─ logs/
│     ├─ 2025-11-05.log
│     └─ ... (últimos 7 dias)
│
└─ shared_prefs/
   ├─ user_session.json
   └─ app_settings.json
```

**Por que 1 DB por voo?** ⭐

```yaml
Vantagens:
  ✅ Isolamento completo (corrupção não afeta outros)
  ✅ Fácil deletar (1 arquivo)
  ✅ Rápido acesso (índices menores)
  ✅ Backup individual simples
  ✅ Tamanho previsível (~2-3MB por voo)

vs. 1 DB global:
  ❌ Cresce indefinidamente
  ❌ Lentidão após muitos voos
  ❌ Difícil deletar voos antigos
  ❌ Corrupção afeta tudo
  ❌ Backup complexo
```

### Limites & Limpeza Automática

```dart
class StorageManager {
  static const int MAX_STORAGE_GB = 5;
  static const int WARNING_THRESHOLD_GB = 4;
  static const int MAX_PENDING_FLIGHTS = 20;
  static const int CACHE_SYNCED_FLIGHTS = 3;
  static const int LOG_RETENTION_DAYS = 7;
  
  Future<void> checkStorageBeforeFlight() async {
    final stats = await getStorageStats();
    
    // Validações
    if(stats.totalSizeGB > WARNING_THRESHOLD_GB) {
      showWarning("Armazenamento baixo: ${stats.totalSizeGB.toStringAsFixed(1)}GB");
      throw StorageFullException();
    }
    
    if(stats.pendingFlightsCount >= MAX_PENDING_FLIGHTS) {
      showError("Limite de $MAX_PENDING_FLIGHTS voos não sincronizados.");
      throw TooManyPendingFlightsException();
    }
  }
  
  Future<void> cleanup() async {
    // 1. Deletar voos sincronizados (manter só 3)
    await _cleanupSyncedFlights();
    
    // 2. Deletar logs >7 dias
    await _cleanupLogs();
    
    // 3. Limpar pasta temp
    await _cleanupTemp();
    
    // 4. Comprimir fotos >1MB
    await _compressOversizedPhotos();
  }
}
```

### Flutter Capabilities ⭐ NOVO

**SSID WiFi:**

```dart
import 'package:network_info_plus/network_info_plus.dart';

Future<String?> getCurrentWifiSSID() async {
  final info = NetworkInfo();
  final wifiName = await info.getWifiName();
  return wifiName?.replaceAll('"', ''); // Remove aspas iOS
}

// Uso
final ssid = await getCurrentWifiSSID();
if(ssid == "AVIONICA") {
  // Conectado ao ESP32
  await connectWebSocket("ws://192.168.4.1:81");
} else if(ssid != null) {
  // Conectado ao WiFi aeroclube - iniciar sync
  await syncPendingFlights();
}
```

**Device ID:**

```dart
import 'package:device_info_plus/device_info_plus.dart';

Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? "";
  }
  
  return "";
}

// Salvar no login e enviar em todas requests
final deviceId = await getDeviceId();
dio.options.headers['X-Device-ID'] = deviceId;
```

**Live 4G Upload:**

```dart
class LiveTelemetryUploader {
  Timer? _uploadTimer;
  
  void startLiveUploading() {
    _uploadTimer = Timer.periodic(Duration(seconds: 5), (_) {
      if(hasInternetConnection && !isConnectedToESP) {
        uploadBufferedData();
      }
    });
  }
  
  Future<void> uploadBufferedData() async {
    // Comprimir buffer (gzip)
    final json = jsonEncode(_buffer);
    final compressed = gzip.encode(utf8.encode(json));
    
    // ~2KB/pacote, ~1.4MB/hora
    await api.post('/api/flights/live-telemetry', 
      data: compressed,
      headers: {'Content-Encoding': 'gzip'},
    );
    
    _buffer.clear();
  }
}
```

---

## 🎓 CAMPOS ICAO - EXPLICAÇÃO ⭐ NOVO

**ICAO = International Civil Aviation Organization**

### Plano de Voo ICAO Campos

```yaml
Aircraft Identification:
  - Matrícula: PT-ABC
  - Callsign: PT123

Flight Rules:
  - V: VFR (Visual Flight Rules)
  - I: IFR (Instrument Flight Rules)
  - Y: IFR depois VFR
  - Z: VFR depois IFR

Type of Aircraft:
  - C172/L: Cessna 172 / Landplane

Equipment:
  - S: Standard comm/nav
  - C: Transponder Mode C

Aeródromos (4 letras ICAO):
  - SBBI: Bacacheri (Curitiba)
  - SBCT: Afonso Pena (Curitiba)
  - SBSP: Congonhas (São Paulo)

Speed/Level:
  - N0095: 95 knots (velocidade)
  - VFR: Visual flight rules

Route:
  - Direto: SBCT
  - Via pontos: SBBI DCT SBCT
  - Airways: W4 SBCT

EET (Estimated Elapsed Time):
  - 0115: 1h15min

Other Information:
  - DOF/251105: Date of Flight 25/11/05
  - REG/PTABC: Registration
  - PBN/B2: Performance Based Navigation
  - etc.
```

### No Sistema Aviônica

**3 formas upload:**

1. **PDF Upload + OCR** → extrai campos automaticamente
2. **Form manual** → preenche campos ICAO
3. **Sem plano** → voo local (não obrigatório treino)

---

## ✅ CHECKLIST DIGITAL COMPLETO (Cessna 152)

### 37 Itens Obrigatórios

```yaml
PREFLIGHT INSPECTION (22 itens):
  Documentos (5):
    - Certificado Matrícula
    - Certificado Aeronavegabilidade
    - Apólice Seguro RETA
    - Manual Operação
    - Diário Bordo 📸
  
  Exterior (16):
    - Fuselagem, asas, flaps
    - Ailerons, profundor, leme
    - Trem pouso (3x)
    - Pitot/estático
    - etc.
  
  Motor (7):
    - Nível óleo 📸 [input: 6.5 qts]
    - Combustível Esq [input: 40L]
    - Combustível Dir [input: 40L]
    - Dreno combustível 📸
    - etc.

BEFORE ENGINE START (8 itens):
  - Assentos travados
  - Cintos afivelados
  - Controles livres
  - Fuel valve ON
  - etc.

ENGINE START (7 itens):
  - Área livre
  - Mixture RICH
  - Throttle 1/4"
  - Magnetos START
  - etc.

BEFORE TAKEOFF (7 itens):
  - RPM 1700
  - Magneto check
  - Carb heat check
  - Flaps configurado
  - etc.

Total: 37 itens
Fotos obrigatórias: 3
Inputs numéricos: 3
```

**Ver JSON completo:** [ANALISE_COMPLETA_RESPOSTAS.md (seção 6)](computer:///mnt/user-data/outputs/ANALISE_COMPLETA_RESPOSTAS.md)

---

## 🔐 CIV DIGITAL - INTEGRAÇÃO ANAC

### O que é CIV Digital?

**CIV = Caderneta Individual de Voo (digital)**

```yaml
Lei: Resolução ANAC nº 678/2022
Obrigatório: Desde 01/12/2022
Prazo envio: Até 24h após voo
Formato: XML assinado (ICP-Brasil)
```

### Dados Mínimos ANAC

```yaml
Obrigatórios:
  - CPF instrutor + aluno
  - CANAC ambos
  - Matrícula aeronave
  - Data/hora/duração voo
  - Aeródromo origem/destino
  - Tipo instrução (PP, PC, etc)
  - Fase/Missão currículo
  - Nota final
  - Resultado (aprovado/reprovado)
  - Assinatura digital ambos

Diferenciais Aviônica:
  - Telemetria completa 20Hz
  - Fotos pré/pós voo
  - Hash arquivo telemetria
  - GPS track completo
```

### Fluxo Completo

```
Voo Finalizado
    ↓
Backend gera XML CIV
    ↓
Assina digitalmente (ICP-Brasil)
    ↓
POST https://api.anac.gov.br/v2/civ/registrar
    ↓
ANAC valida assinatura
    ↓
ANAC registra oficialmente
    ↓
← 200 OK {protocolo: "CIV-2025-..."}
    ↓
Backend salva protocolo
    ↓
Notifica instrutor + aluno
    ↓
✅ Disponível portal ANAC
```

**Ver exemplo XML completo:** [CIV_DIGITAL_EXEMPLO.xml](computer:///mnt/user-data/outputs/CIV_DIGITAL_EXEMPLO.xml)  
**Ver explicação visual:** [CIV_DIGITAL_EXPLICADO.md](computer:///mnt/user-data/outputs/CIV_DIGITAL_EXPLICADO.md)

---

## ⚡ BACKEND WORKFLOWS (N8N)

### Principais Workflows

```yaml
1. Flight Sync Processor:
   - Webhook: POST /api/flights/sync
   - Valida JWT
   - Valida dados voo
   - Salva PostgreSQL
   - Upload fotos S3
   - Comprimir telemetria
   - Trigger: CIV Generator

2. CIV Generator & ANAC Sender:
   - Busca dados voo completo
   - Gera XML CIV
   - Assina digitalmente
   - POST API ANAC
   - Salva protocolo
   - Log envio
   - Notificar usuários
   - Retry 3x se erro

3. Live Telemetry Receiver:
   - Webhook: POST /api/flights/live-telemetry
   - Descomprime gzip
   - Valida flight_id
   - Salva Redis (TTL 60s)
   - Broadcast WebSocket
   - Log recebimento

4. Aircraft Hobbs Updater:
   - Trigger: Voo finalizado
   - Atualizar aircraft.hobbs_atual
   - Calcular próxima manutenção
   - Alertar se <10h
   - Log alteração

5. Document Expiry Checker:
   - Cron: Diário 06:00
   - Verificar validades CMA/CHT
   - Alertar se <30 dias
   - Email + Push notification
   - Log alertas

6. Sync Cache Mobile:
   - Webhook: GET /api/cache/sync
   - Retornar JSON:
     - students (aeroclube)
     - aircraft (aeroclube)
     - instructors (aeroclube)
     - missions (curso)
     - evaluation_templates
   - Cache Redis 1h

7. Reports Generator:
   - Trigger: Request relatório
   - Query PostgreSQL agregado
   - Gerar PDF/Excel
   - Upload S3
   - Retornar URL
   - TTL 7 dias
```

---

## 📊 RELATÓRIOS & BI

### Dashboards Disponíveis

```yaml
Admin:
  - Overview sistema (todas aeroclubes)
  - Uso servidores
  - Métricas negócio
  - Faturamento

Gestor:
  - Performance aeroclube
  - Taxa ocupação aeronaves
  - Progressão alunos (geral)
  - Desempenho instrutores
  - Consumo combustível
  - ROI por aeronave
  - Relatórios ANAC

Instrutor:
  - Meu desempenho
  - Meus alunos evolução
  - Horas voadas
  - Taxa aprovação

Aluno:
  - Meu progresso curso
  - Gráfico evolução notas
  - Horas voadas vs previstas
```

### Export Formatos

```
- PDF (relatório formatado)
- Excel (.xlsx)
- CSV (dados brutos)
- PowerPoint (apresentação)
- JSON (API)
```

---

## 🚀 DEPLOY & INFRAESTRUTURA

### Stack Deploy

```yaml
Frontend Web:
  - Vercel (Next.js)
  - ou Docker + Nginx
  - CDN: Cloudflare
  - SSL: Let's Encrypt

Backend:
  - N8N: Docker self-hosted
  - PostgreSQL: Supabase (managed)
  - Redis: Upstash ou self-hosted
  - Storage: Supabase Storage ou AWS S3

Mobile:
  - Google Play Store
  - Apple App Store
  - OTA Updates: CodePush

Monitoramento:
  - Sentry (erros)
  - PostHog (analytics)
  - Uptime Robot (status)
```

### Ambientes

```yaml
Development:
  - Local Docker Compose
  - Supabase local
  - Mock ANAC API

Staging:
  - 1 aeroclube teste
  - ANAC sandbox
  - Dados anonimizados

Production:
  - Multi-tenant
  - ANAC produção
  - Backup automático 3x/dia
```

---

## 📝 PRÓXIMOS PASSOS

### Documentos Faltantes

```
1. ✅ SYSTEM_OVERVIEW v2.0 (este arquivo)
2. ⏳ DATA_FLOW_DIAGRAMS.md (Mermaid)
3. ⏳ MOBILE_OVERVIEW.md (detalhes Flutter)
4. ⏳ BACKEND_OVERVIEW.md (N8N workflows)
5. ⏳ WEB_OVERVIEW.md (Next.js páginas)
6. ⏳ HARDWARE_OVERVIEW.md (ESP32 integração)
7. ⏳ API_DOCUMENTATION.md (endpoints)
8. ⏳ DEPLOYMENT_GUIDE.md (infra)
```

### Prioridades Desenvolvimento

```
Sprint 1 (2 semanas):
  1. Corrigir ESP32 (JSON campos faltantes)
  2. Setup Supabase Auth
  3. Implementar PostgreSQL v2
  4. N8N workflow básico (sync)

Sprint 2 (2 semanas):
  5. Mobile: Telas principais (15)
  6. Mobile: Conexão ESP32
  7. Mobile: Gravação local
  8. Mobile: Avaliação FAP

Sprint 3 (2 semanas):
  9. Web: Portal Gestor (CRUD)
  10. Web: Live Tracking
  11. Backend: CIV ANAC (sandbox)
  12. Testes integração

Sprint 4 (2 semanas):
  13. Web: Replay 3D (MVP)
  14. Web: Portal Aluno
  15. Mobile: Agenda instrutor
  16. Testes aeroclube piloto

Sprint 5+ (iterações):
  17. Refinamentos UX
  18. Performance otimização
  19. ANAC produção
  20. Expansão features
```

---

## ⚠️ CONSTRAINTS & PREMISSAS

### Técnicas

```yaml
Mobile:
  - Offline obrigatório (voo sem internet)
  - Storage mínimo: 5GB disponível
  - Android 8+ / iOS 13+
  - Tablet prioritário (screen size)

Telemetria:
  - Latência <50ms (20Hz)
  - Pacote: 768 bytes
  - Perda pacotes: <1%

Backend:
  - Uptime: 99.9%
  - Latência API: <200ms
  - Concurrent users: 1000+

Database:
  - Particionamento telemetry obrigatório
  - Retenção: 5 anos mínimo
  - Backup: 3x/dia

Storage:
  - Fotos: JPEG 85%
  - Telemetria: Gzip
  - Total: ~10GB/aeroclube/mês
```

### Regulatórias

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

### Negócio (MVP)

```yaml
Incluído MVP:
  ✅ Portal instrutor mobile
  ✅ Portal gestor web
  ✅ Portal admin web
  ✅ Portal aluno web
  ✅ CIV Digital ANAC
  ✅ Live tracking 4G
  ✅ Replay telemetria 3D
  ✅ Agenda aulas
  ✅ Plano voo upload

Pós-MVP:
  ❌ Portal aluno mobile nativo
  ❌ Gestão financeira completa
  ❌ EAD integrado
  ❌ Áudio/vídeo cockpit
  ❌ Chat tempo real
  ❌ Gamificação
  ❌ Multi-idioma
  ❌ Simulador integrado
```

---

## 📞 CONTATO & SUPORTE

```yaml
Documentação: https://docs.avionica.com
API Docs: https://api.avionica.com/docs
Status: https://status.avionica.com
Suporte: suporte@avionica.com
WhatsApp: +55 41 99999-9999
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
RBAC: Regulamento Brasileiro Aviação Civil
SPU: Sensor Processing Unit (ESP32)
VFR: Visual Flight Rules (voo visual)
```

---

**✅ SYSTEM OVERVIEW v2.0 - COMPLETO**

**Status:** 📄 Documento Mestre Definitivo  
**Próximo:** Criar wireframes ou documentos técnicos detalhados

**Arquivos Relacionados:**
- [CIV_DIGITAL_EXPLICADO.md](computer:///mnt/user-data/outputs/CIV_DIGITAL_EXPLICADO.md)
- [DATABASE_SCHEMA_V2.sql](computer:///mnt/user-data/outputs/DATABASE_SCHEMA_V2.sql)
- [ANALISE_COMPLETA_RESPOSTAS.md](computer:///mnt/user-data/outputs/ANALISE_COMPLETA_RESPOSTAS.md)