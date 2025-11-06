# 📋 SYSTEM OVERVIEW - AVIÔNICA MVP

**Versão:** 1.0  
**Data:** 05/11/2025  
**Status:** Documento Mestre - Base para todos os outros  
**Autor:** Equipe Aviônica

---

## 🎯 VISÃO EXECUTIVA

### Propósito
Sistema end-to-end para **digitalização completa** da instrução de voo em aeroclubes brasileiros, integrando **hardware real de telemetria** com **software de gestão e avaliação objetiva**.

### Diferencial Competitivo
```
🏆 Concorrência (SAGA, Alis, Plane It):
   → Software apenas (sem hardware)
   → Avaliação subjetiva (texto/notas)
   → Sem evidência física de performance

✨ Aviônica:
   → Hardware SPU (telemetria REAL 20Hz)
   → Avaliação objetiva (dados sensores)
   → Evidência física verificável
   → Sixpack digital tempo real
```

### Números-Chave MVP
- **3 sistemas software** + 1 hardware integrado
- **1 perfil usuário mobile**: Instrutor (tablet)
- **Offline-first**: 100% funcional sem internet em voo
- **Sync automático**: WiFi aeroclube → Cloud
- **Regulatório**: Integração CIV Digital (API ANAC obrigatória)

---

## 🏗️ ARQUITETURA MACRO - 4 SISTEMAS

```
┌─────────────────────────────────────────────────────────────────┐
│                    🌐 SISTEMA AVIÔNICA MVP                       │
└─────────────────────────────────────────────────────────────────┘

┌──────────────┐    WebSocket     ┌──────────────┐
│   ESP32 SPU  │◄────── WiFi ────►│ MOBILE APP   │
│              │      20Hz JSON    │  (Tablet)    │
│ • Sensores   │                   │              │
│ • GPS        │                   │ • Offline 1° │
│ • Telemetria │                   │ • Sixpack    │
│ • 20Hz       │                   │ • Avaliação  │
└──────────────┘                   └──────┬───────┘
                                          │
                                     WiFi │ Sync
                                          │
                                   ┌──────▼────────┐
                                   │   BACKEND     │
                                   │  N8N + PG     │
                                   │               │
                                   │ • Workflows   │
                                   │ • Database    │
                                   │ • API REST    │
                                   │ • CIV ANAC    │
                                   └──────┬────────┘
                                          │
                                     HTTPS│ API
                                          │
                                   ┌──────▼────────┐
                                   │   WEB APP     │
                                   │  Next.js 14   │
                                   │               │
                                   │ • Dashboard   │
                                   │ • Gestão      │
                                   │ • Relatórios  │
                                   │ • Replay      │
                                   └───────────────┘
```

---

## 🔄 FLUXO COMPLETO DE UM VOO

### 📝 PRÉ-VOO (Mobile Offline)

```
[Instrutor no Tablet]
    ↓
1. Login + Selecionar Aluno
    ↓
2. Criar/Selecionar Plano de Voo
   • Campos ICAO (opcional)
   • Upload PDF + OCR (opcional)
   • Download mapa offline (opcional)
   • Sem plano = voo local
    ↓
3. 📸 Foto Instrutor + Aluno (comprovação)
    ↓
4. Checklist Digital Pré-Voo
    ↓
5. Registrar Dados Iniciais Aeronave:
   ┌────────────────────────────┐
   │ • Hobbs meter início       │
   │ • Combustível litros       │
   │ • Horário decolagem        │
   │ • Nível óleo               │
   │ • Observações              │
   └────────────────────────────┘
    ↓
6. Conectar SPU (WebSocket ws://192.168.4.1:81)
    ↓
7. Calibração Instrumentos
   • Zero pitch/roll
   • Ajuste bússola
   • Validar GPS signal
    ↓
✅ PRONTO PARA VOO
```

### ✈️ DURANTE VOO (Telemetria Real-Time)

```
┌─────────────────────────────────────────────────────────┐
│  ESP32 SPU                    TABLET INSTRUTOR          │
│                                                          │
│  Sensores (20Hz)              Sixpack Digital           │
│  ↓                            ↓                         │
│  • GPS                        • Velocímetro             │
│  • Bússola                    • Altímetro               │
│  • Barômetro                  • Horizonte Artificial    │
│  • Acelerômetro               • Bússola                 │
│  • Giroscópio                 • Variômetro              │
│  • Temperatura                • Coordenador Curva       │
│  ↓                            ↓                         │
│  JSON Payload (768 bytes)     Visualização Tempo Real   │
│  └──► WebSocket ──────────────► Update UI              │
│        A cada 50ms                                      │
│                               Gravação Local:           │
│                               • SQLite/Hive             │
│                               • Todos pacotes           │
│                               • Sem internet            │
└─────────────────────────────────────────────────────────┘

🔌 Desconexão WiFi?
   → SPU continua gravando memória interna
   → Tablet continua gravando localmente
   → Reconexão = sincronização automática
```

### 📊 PÓS-VOO (Avaliação + Sync)

```
[Pouso Confirmado]
    ↓
1. Registrar Dados Finais:
   ┌────────────────────────────┐
   │ • Hobbs meter final        │
   │ • Combustível abastecido   │
   │ • Horário pouso            │
   │ • Problemas/anormalidades  │
   └────────────────────────────┘
    ↓
2. 📸 Foto Instrutor + Aluno (pós-voo)
    ↓
3. ⭐ AVALIAÇÃO DIGITAL COMPLETA (FAP):
   ┌────────────────────────────────────┐
   │ Ficha Avaliação Piloto (padrão MCA 58-3) │
   │                                    │
   │ Por Fase/Missão:                   │
   │ ┌──────────────────────────────┐   │
   │ │ Item 1: Decolagem      [1-5] │   │
   │ │ Item 2: Subida         [1-5] │   │
   │ │ Item 3: Voo Nivelado   [1-5] │   │
   │ │ Item 4: Curvas         [1-5] │   │
   │ │ Item 5: Descida        [1-5] │   │
   │ │ Item 6: Pouso          [1-5] │   │
   │ └──────────────────────────────┘   │
   │                                    │
   │ Observações (texto livre)          │
   │ Assinatura digital:                │
   │   ✍️ Instrutor                     │
   │   ✍️ Aluno                         │
   └────────────────────────────────────┘
    ↓
4. Salvar TUDO Localmente
   • Voo completo (.json)
   • Telemetria completa (.db)
   • Fotos (4 imagens comprimidas)
   • Avaliação (.json)
   • Plano de voo (.pdf se houver)
    ↓
5. ⏳ Aguardar WiFi Disponível
    ↓
6. 🔄 SINCRONIZAÇÃO AUTOMÁTICA:
   ┌─────────────────────────────┐
   │ Tablet → Backend            │
   │                             │
   │ POST /api/flights/sync      │
   │ {                           │
   │   flight: {...},            │
   │   telemetry: [...],         │
   │   evaluation: {...},        │
   │   photos: [base64, ...],    │
   │   flight_plan: {...}        │
   │ }                           │
   │                             │
   │ ← 200 OK {flight_id: xxx}   │
   └─────────────────────────────┘
    ↓
7. ✅ Confirmação Backend Recebeu
    ↓
8. 🗑️ LIMPEZA STORAGE LOCAL:
   • Deletar dados sincronizados
   • Manter cache últimos 3 voos
   • Liberar espaço tablet
    ↓
✅ VOO FINALIZADO E ARMAZENADO
```

---

## 📦 PAYLOAD ESP32 → TABLET

### JSON Structure (768 bytes @ 20Hz)
```json
{
  // Six-Pack Principal
  "velocidade": 145.2,           // km/h (GPS)
  "altitude": 853.4,              // metros (barômetro)
  "altitude_ft": 2800.5,          // pés
  "heading": 087,                 // graus (0-360)
  "pitch": -2.3,                  // graus (nariz up/down)
  "roll": 15.7,                   // graus (asa left/right)
  "variometro": 1.2,              // m/s (subida/descida)
  "variometro_ft": 236.2,         // pés/min
  
  // Coordenador de Curva
  "coordcurva": -3.1,             // diferença angular
  
  // Dados Ambientais
  "temperatura": 28.5,            // °C
  "pressao": 90812,               // Pa (Pascals)
  
  // GPS
  "lat": -25.4035174,
  "lng": -49.2940581,
  "satelites": 12,
  "hdop": 0.95,                   // precisão GPS
  
  // Giroscópio L3G4200D
  "gyro_x": 245,                  // raw values
  "gyro_y": -89,
  "gyro_z": 1024,
  
  // Acelerômetro ADXL345
  "acel_x": 0.12,                 // g's
  "acel_y": -0.05,
  "acel_z": 1.02,
  
  // LSM6DS3 (backup/redundância)
  "lsm_ax": 0.11,
  "lsm_ay": -0.04,
  "lsm_az": 1.01,
  "lsm_gx": 2.34,
  "lsm_gy": -1.12,
  "lsm_gz": 0.78,
  
  // Metadata
  "timestamp": 1730824567890,     // epoch ms
  "spu_id": "SPU-001-A5B2"        // identificador único
}
```

**Frequência:** 20 pacotes/segundo = **1.200 pacotes/minuto** = **72.000 pacotes/hora**

**Tamanho estimado telemetria 1h voo:**
- 72.000 pacotes × 768 bytes = ~55 MB JSON bruto
- Comprimido (gzip): ~8-12 MB
- Armazenamento PostgreSQL: JSONB comprimido

---

## 🗄️ BACKEND - PROCESSAMENTO & ARMAZENAMENTO

### N8N Workflows Principais

**1️⃣ Workflow: Receber Telemetria em Voo**
```
Trigger: POST /api/flights/telemetry
   ↓
Validate JWT Token
   ↓
Parse JSON Payload
   ↓
Bulk Insert PostgreSQL
   → Table: telemetry (JSONB compressed)
   ↓
Update flight status = "in_progress"
   ↓
Return: 200 OK
```

**2️⃣ Workflow: Sincronizar Voo Completo**
```
Trigger: POST /api/flights/sync
   ↓
Validate Payload Structure
   ↓
Begin Transaction:
   │
   ├─► Insert: flights table
   │      → Retorna flight_id
   │
   ├─► Insert: telemetry (bulk)
   │
   ├─► Insert: evaluations
   │
   ├─► Upload: photos → S3/Supabase Storage
   │      → Retorna photo_urls
   │
   ├─► Insert: photos (metadata + URLs)
   │
   ├─► Insert: flight_plans (se houver)
   │
   ├─► Update: aircraft
   │      → Hobbs atual, horas voadas
   │
   ├─► Update: students
   │      → Total horas, último voo
   │
   └─► Calculate: statistics
          → Médias, agregações
   ↓
Commit Transaction
   ↓
🔗 Trigger: Integração CIV ANAC
   ↓
Send Notification (opcional)
   ↓
Return: {
  "flight_id": "uuid-xxx",
  "status": "synced",
  "civ_status": "pending"
}
```

**3️⃣ Workflow: Integração CIV ANAC**
```
Trigger: Após voo sincronizado
   ↓
Buscar dados voo no PostgreSQL
   ↓
Formatar dados padrão ANAC:
   {
     "canac_instrutor": "XXX",
     "canac_aluno": "YYY",
     "aeronave_matricula": "PT-ABC",
     "data_hora_inicio": "...",
     "data_hora_fim": "...",
     "horas_voadas": 1.5,
     "tipo_voo": "INSTRUCAO",
     "observacoes": "..."
   }
   ↓
POST https://sistemas.anac.gov.br/saci/api/civ
   Headers: {
     Authorization: "Bearer {token_oauth_govbr}"
   }
   ↓
ANAC responde:
   • 200 OK → CIV registrado
   • Instrutor = lançado automaticamente
   • Aluno = rascunho (aguarda confirmação)
   ↓
Update: flights table
   → civ_status = "registered"
   → civ_anac_id = "xxx"
   ↓
Log resultado
   ↓
Send Email Aluno (confirmação pendente)
```

### Database Schema (PostgreSQL)

**Tabelas Principais:**
```sql
users
  ├─ id (PK)
  ├─ email (unique)
  ├─ role (enum: admin, instrutor, aluno)
  ├─ name
  ├─ canac
  └─ photo_url

students
  ├─ id (PK)
  ├─ user_id (FK → users)
  ├─ cpf
  ├─ documents (JSONB)
  ├─ total_hours
  ├─ status (enum: ativo, suspenso, formado)
  └─ last_flight_at

instructors
  ├─ id (PK)
  ├─ user_id (FK → users)
  ├─ license_number
  ├─ specialties (array)
  └─ total_flights

aircraft
  ├─ id (PK)
  ├─ registration (unique, ex: PT-ABC)
  ├─ model
  ├─ hobbs_current (decimal)
  ├─ fuel_capacity
  ├─ next_maintenance_hobbs
  └─ status (enum: ativo, manutencao, inativo)

flights
  ├─ id (PK, UUID)
  ├─ instructor_id (FK)
  ├─ student_id (FK)
  ├─ aircraft_id (FK)
  ├─ started_at (timestamp)
  ├─ ended_at (timestamp)
  ├─ hobbs_start (decimal)
  ├─ hobbs_end (decimal)
  ├─ fuel_start (decimal)
  ├─ fuel_added (decimal)
  ├─ flight_plan_json (JSONB, nullable)
  ├─ status (enum: planned, in_progress, completed, synced)
  ├─ civ_status (enum: pending, registered, confirmed)
  └─ civ_anac_id (string, nullable)

telemetry ⚠️ TABELA GIGANTE
  ├─ id (PK, bigint auto)
  ├─ flight_id (FK, indexed)
  ├─ timestamp (bigint, epoch ms)
  ├─ data_json (JSONB compressed)
  └─ INDEX: (flight_id, timestamp)
  
  💡 Particionamento por flight_id ou data

evaluations
  ├─ id (PK)
  ├─ flight_id (FK, unique)
  ├─ phase (string, ex: "Fase I")
  ├─ mission_number (int)
  ├─ scores_json (JSONB)
  │    → {"decolagem": 4, "subida": 3, ...}
  ├─ observations (text)
  ├─ grade (decimal, média geral)
  ├─ instructor_signature (text)
  ├─ student_signature (text)
  └─ created_at

photos
  ├─ id (PK)
  ├─ flight_id (FK)
  ├─ type (enum: pre_instructor, pre_student, 
  │              post_instructor, post_student)
  ├─ url (string, S3/Supabase)
  ├─ timestamp
  └─ metadata (JSONB)

flight_plans
  ├─ id (PK)
  ├─ flight_id (FK, unique)
  ├─ icao_fields_json (JSONB, nullable)
  ├─ map_file_url (string, nullable)
  └─ created_at

maintenance_logs
  ├─ id (PK)
  ├─ aircraft_id (FK)
  ├─ date
  ├─ type (enum: preventiva, corretiva)
  ├─ description (text)
  ├─ mechanic_canac
  └─ next_maintenance_hobbs
```

---

## 🌐 WEB APP - GESTÃO & RELATÓRIOS

### Páginas Principais

**1. Dashboard (/)** 📊
```
┌──────────────────────────────────────────────┐
│  📅 Hoje: 15 voos agendados | 8 completados  │
├──────────────────────────────────────────────┤
│  ✈️ Aeronaves Ativas: 5/7                    │
│  ⚠️ Alertas:                                 │
│    • PT-ABC: Manutenção em 15h              │
│    • PT-XYZ: Combustível baixo              │
├──────────────────────────────────────────────┤
│  📈 Últimos 30 dias:                         │
│    • 127 voos realizados                     │
│    • 189.5 horas voadas                      │
│    • Taxa ocupação: 68%                      │
│    • Consumo combustível: 2.847L             │
├──────────────────────────────────────────────┤
│  🎯 Top Alunos (progressão):                 │
│    1. João Silva - Fase II - 92% aprovação   │
│    2. Maria Santos - Fase I - 87% aprovação  │
└──────────────────────────────────────────────┘
```

**2. Gestão Alunos (/students)** 👨‍🎓
- CRUD completo
- Busca/filtros avançados
- Histórico voos (timeline)
- Documentos (upload/download)
- Status progressão (Fase I/II/III)
- Gráfico evolução notas

**3. Gestão Instrutores (/instructors)** 👨‍✈️
- CRUD completo
- Especialidades/certificações
- Carga horária mensal
- Performance (média avaliações alunos)

**4. Gestão Aeronaves (/aircraft)** ✈️
- CRUD completo
- Status tempo real
- Hobbs meter atual
- Histórico manutenções
- Previsão próxima manutenção
- Utilização (horas/mês)

**5. Histórico Voos (/flights)** 📋
- Lista completa voos
- Filtros múltiplos:
  - Data/período
  - Aluno
  - Instrutor
  - Aeronave
  - Status
- Export CSV/PDF
- Link para replay

**6. Replay Telemetria (/flights/:id/replay)** 🎬
```
┌────────────────────────────────────────────────┐
│  🗺️ Mapa 2D (Mapbox/Google Maps)              │
│                                                │
│     [Trajeto completo com marcadores]          │
│     • Início (verde)                          │
│     • Fim (vermelho)                          │
│     • Eventos (amarelo)                       │
│                                                │
│  ⏯️ Playback Controls:                         │
│     ◄◄  ⏸️  ▶️  ►►  [========●====]          │
│     0:00 / 1:23:45  Speed: 1x 2x 5x 10x       │
│                                                │
│  📊 Dados Tempo Real (sincronizado):           │
│     Alt: 2850ft  Speed: 145kt  Heading: 087°  │
│     Pitch: -2.3°  Roll: 15.7°  Vario: +236fpm │
└────────────────────────────────────────────────┘
```

**7. Relatórios (/reports)** 📑
- Performance aluno (gráficos evolução)
- Consumo combustível (por aeronave/período)
- Utilização aeronaves (taxa ocupação)
- Horas voadas (instrutor/aluno/total)
- Relatórios ANAC (padrão regulatório)
- Export múltiplos formatos

**8. Configurações (/settings)** ⚙️
- Dados aeroclube
- Integração API ANAC (OAuth)
- Backup/restore
- Logs sistema
- Usuários/permissões

---

## 🔐 AUTENTICAÇÃO & AUTORIZAÇÃO

### JWT Token Strategy
```
Login:
  POST /api/auth/login
  { email, password }
  ↓
  ← 200 OK {
      token: "eyJhbG...",
      refresh_token: "...",
      user: { id, name, role, ... }
    }

Requests subsequentes:
  Header: Authorization: Bearer {token}
  
Token expira: 24h
Refresh token: 30 dias

Roles:
  • admin      → Acesso total
  • instrutor  → Acesso mobile + web (limitado)
  • aluno      → Somente visualização (pós-MVP)
```

---

## 📱 MOBILE - ESTRATÉGIA OFFLINE-FIRST

### Storage Local (SQLite/Hive)

**Estrutura:**
```
local_flights/
  ├─ metadata.json (lista voos pendentes sync)
  ├─ flight_001/
  │    ├─ info.json (dados voo)
  │    ├─ telemetry.db (SQLite com todos pacotes)
  │    ├─ evaluation.json
  │    ├─ photos/
  │    │    ├─ pre_instructor.jpg (comprimido)
  │    │    ├─ pre_student.jpg
  │    │    ├─ post_instructor.jpg
  │    │    └─ post_student.jpg
  │    └─ flight_plan.pdf (se houver)
  ├─ flight_002/
  └─ ...

cache/
  ├─ students.json (lista alunos do aeroclube)
  ├─ aircraft.json (lista aeronaves)
  ├─ missions.json (currículo ANAC)
  └─ last_sync.json (timestamp última sync)
```

### Sync Strategy

**Quando sincronizar:**
1. Automático: WiFi conectou + voos pendentes
2. Manual: Botão "Sincronizar Agora"
3. Background: Ao abrir app (se WiFi disponível)

**Processo:**
```
Para cada voo pendente:
  1. Verificar conectividade
  2. Comprimir telemetry (gzip)
  3. Comprimir fotos (JPEG quality 85%)
  4. Montar payload completo
  5. POST /api/flights/sync
  6. Aguardar confirmação (retry 3x)
  7. Se sucesso:
     → Marcar como synced
     → Deletar dados locais
     → Atualizar cache
  8. Se falha:
     → Manter local
     → Tentar próxima vez
```

**Limpeza automática:**
- Após sync sucesso: deletar imediatamente
- Exceção: manter últimos 3 voos (cache rápido)
- Storage limite: 2GB (alerta se atingir 1.5GB)

---

## 🚀 CASOS DE USO PRINCIPAIS

### Caso 1: Primeiro Voo de Aluno Novo
```
1. [Web] Gestor cria cadastro aluno
2. [Web] Aluno aparece em lista do aeroclube
3. [Mobile] Instrutor abre app (baixa cache via WiFi)
4. [Mobile] Seleciona aluno novo → Fase I, Missão 1
5. [Mobile] Executa voo completo (offline)
6. [Mobile] Avalia aluno (FAP digital)
7. [Mobile] Conecta WiFi → sync automático
8. [Backend] Processa tudo → registra CIV ANAC
9. [Web] Gestor vê voo no histórico + replay
10. [Email] Aluno recebe confirmação CIV (confirmar no ANAC)
```

### Caso 2: Alerta Manutenção Aeronave
```
1. [Backend] Cron job diário verifica Hobbs aeronaves
2. [Backend] PT-ABC está a 8h da manutenção preventiva
3. [Backend] Dispara notificação
4. [Web] Dashboard mostra alerta vermelho
5. [Web] Gestor vê detalhes → agenda manutenção
6. [Web] Marca aeronave status = "manutenção"
7. [Mobile] Instrutor tenta selecionar PT-ABC → bloqueado
8. [Mobile] Mensagem: "Aeronave em manutenção até DD/MM"
```

### Caso 3: Replay para Debriefing
```
1. [Web] Instrutor acessa /flights/xxx/replay
2. [Web] Mapa carrega trajeto completo
3. [Web] Instrutor clica evento específico (ex: curva ruim)
4. [Web] Playback pula para aquele timestamp
5. [Web] Dados tempo real mostram:
   → Roll excessivo: 35° (limite 30°)
   → Altitude perdida: -150ft
   → Coordenador curva: desalinhado
6. [Web] Instrutor anota observação (salva no sistema)
7. [Próxima aula] Revisar este ponto específico
```

---

## ⚠️ CONSTRAINTS & PREMISSAS

### Técnicas
- **Offline mobile:** Obrigatório (voo sem internet)
- **Latência telemetria:** <50ms (20Hz)
- **Armazenamento local:** Mínimo 2GB disponível
- **Backend:** 99.9% uptime (sync não pode falhar)
- **Database:** Particionamento telemetry obrigatório (escala)

### Regulatórias
- **CIV Digital:** Integração ANAC OBRIGATÓRIA (desde 01/12/2022)
- **Diário Bordo:** Considerar parceria Plane It (homologação pronta)
- **FAP:** Seguir padrão MCA 58-3 (notas 1-5, Grau 3 = aprovação)
- **Retenção dados:** Mínimo 5 anos (RBAC 141)

### Negócio (MVP)
- **Sem app aluno separado** (instrutor apenas)
- **Sem áudio/vídeo** (foco telemetria + fotos)
- **Sem gestão financeira** (integração pós-MVP)
- **Sem EAD integrado** (foco voo prático)
- **1 aeroclube piloto** (validação 3 meses)
- **3-5 aeroclubes** (após 6 meses)

---

## 🎯 PRÓXIMOS DOCUMENTOS

**Agora que temos SYSTEM_OVERVIEW pronto, criar:**

1. **DATA_FLOW_DIAGRAMS.md** (diagramas Mermaid detalhados)
2. **MOBILE_OVERVIEW.md** (visão macro mobile)
3. **BACKEND_OVERVIEW.md** (visão macro backend)
4. **WEB_OVERVIEW.md** (visão macro web)
5. **HARDWARE_OVERVIEW.md** (integração ESP32 detalhada)

---

## 📝 CHANGELOG

- **v1.0** (05/11/2025): Documento inicial criado
  - Arquitetura macro 4 sistemas
  - Fluxo completo voo (pré/durante/pós)
  - Payload ESP32 especificado
  - Backend workflows N8N
  - Database schema
  - Web app páginas
  - Casos de uso principais
  - Constraints e premissas

---

**Status:** ✅ Documento Mestre Completo - Base para planejamento detalhado

**Próximo passo:** Criar DATA_FLOW_DIAGRAMS.md com diagramas visuais Mermaid