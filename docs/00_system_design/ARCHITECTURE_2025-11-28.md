# 🏛️ ARCHITECTURE - QFLY Aviônica Mobile

**Versão:** 1.0  
**Data:** 28/11/2025  
**Status:** MVP em desenvolvimento

---

## 📊 VISÃO GERAL
```
┌─────────────────────────────────────────────────────────────┐
│                    QFLY AVIÔNICA MOBILE                      │
│                    Flutter + Clean Architecture              │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
   ┌─────────┐          ┌─────────┐          ┌─────────┐
   │   UI    │          │ STATE   │          │  DATA   │
   │ Screens │◄────────►│Providers│◄────────►│  Layer  │
   │ Widgets │          │Riverpod │          │   DB    │
   └─────────┘          └─────────┘          └─────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              ▼
                    ┌──────────────────┐
                    │    SERVICES      │
                    │ WebSocket/Auth   │
                    │ Cache/Sync/Valid │
                    └──────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
         ┌────────┐     ┌─────────┐     ┌─────────┐
         │ ESP32  │     │Supabase │     │ SQLite  │
         │WebSocket│     │  Auth   │     │  Local  │
         └────────┘     └─────────┘     └─────────┘
```

---

## 📁 ESTRUTURA DE PASTAS
```
lib/
├── core/                    # 🔧 Fundação do app
│   ├── config/              # Configurações (Supabase, .env)
│   ├── constants/           # Constantes globais
│   ├── esp32/               # Protocolo ESP32
│   ├── router/              # GoRouter navigation
│   └── utils/               # Logger, helpers
│
├── models/                  # 📦 Entidades de domínio
│   └── user_model.dart      # UserModel, enums
│
├── data/                    # 💾 Camada de dados
│   ├── database/            # SQLite config
│   │   ├── migrations/      # Schema versioning
│   │   └── models/          # Entities DB
│   └── repositories/        # Data access
│
├── services/                # ⚙️ Lógica de negócio
│   ├── auth/                # Autenticação Supabase
│   ├── cache/               # Hive cache local
│   ├── calibration/         # Calibração sensores ESP32
│   ├── data_processing/     # Processamento telemetria
│   ├── sync/                # Sync queue offline→cloud
│   ├── validation/          # Validadores de dados
│   └── websocket/           # Conexão ESP32 WebSocket
│
├── providers/               # 🔄 State Management (Riverpod)
│   ├── auth_provider.dart              # Estado autenticação
│   ├── connection_watchdog_provider.dart # Monitor conexão
│   ├── flight_stats_provider.dart      # Estatísticas voo
│   ├── mock_mode_provider.dart         # Modo simulação
│   ├── telemetry_provider.dart         # Dados telemetria
│   └── websocket_provider.dart         # Estado WebSocket
│
├── screens/                 # 📱 Telas
│   ├── login_screen.dart
│   ├── connection_screen.dart
│   ├── selecao_screen.dart
│   ├── origem_destino_screen.dart
│   ├── calibration_screen.dart
│   ├── sixpack_screen.dart
│   ├── avaliacao_screen.dart
│   └── telemetry_test_screen.dart
│
├── widgets/                 # 🧩 Componentes UI
│   ├── altimetro_widget.dart
│   ├── velocimetro_widget.dart
│   └── ...
│
├── painters/                # 🎨 Custom Painters
│   ├── altimetro_painter.dart
│   ├── velocimetro_painter.dart
│   ├── variometro_painter.dart
│   ├── coordenador_painter.dart
│   └── ...
│
├── controllers/             # 🎮 Controllers
│   └── sixpack_controller.dart
│
└── main.dart                # 🚀 Entry point
```

---

## 🔄 FLUXO DE DADOS

### 1️⃣ Autenticação
```
LoginScreen → AuthProvider → AuthService → Supabase
     │              │              │
     └──────────────┴──────────────┘
                    │
              UserModel (perfil, role)
```

### 2️⃣ Telemetria ESP32
```
ESP32 (WiFi AP)
     │
     ▼ WebSocket 20Hz
WebSocketService → WebSocketProvider
     │
     ▼ Stream<Map>
TelemetryProvider → DataProcessingService
     │
     ▼ TelemetryData
SixpackScreen → Painters (6 instrumentos)
     │
     ▼ SQLite
FlightDatabase (offline-first)
```

### 3️⃣ Sync Cloud
```
FlightDatabase (local)
     │
     ▼ WiFi disponível
SyncQueueService
     │
     ▼ POST /api/flights/sync
Supabase (PostgreSQL)
     │
     ▼ Trigger
N8N Workflows → CIV ANAC
```

---

## 🛠️ TECNOLOGIAS

| Camada | Tecnologia | Versão |
|--------|------------|--------|
| UI | Flutter | 3.35.6 |
| State | Riverpod | 2.4.9 |
| Navigation | GoRouter | 17.0.0 |
| Auth | Supabase | 2.10.3 |
| DB Local | SQLite | 2.4.2 |
| Cache | Hive | 2.2.3 |
| WebSocket | web_socket_channel | 2.4.0 |
| Env | flutter_dotenv | 6.0.0 |

---

## 🔐 SEGURANÇA

| Item | Implementação |
|------|---------------|
| Secrets | .env + flutter_dotenv |
| Auth | Supabase JWT |
| DB | SQLite local (device) |
| API | RLS (Row Level Security) |

---

## 📊 MÉTRICAS CÓDIGO

| Métrica | Valor |
|---------|-------|
| Arquivos | ~60 |
| Linhas | ~11.150 |
| Testes | 237 |
| Cobertura | 63.7% |
| Warnings | 0 |

---

## 🎯 PRINCÍPIOS

- ✅ **Clean Architecture** - Separação de camadas
- ✅ **SOLID** - Single responsibility
- ✅ **Offline-First** - SQLite local
- ✅ **Testável** - Injeção de dependência via Riverpod
- ✅ **Type-Safe** - Null safety completo

---

## 📱 TELAS (MVP)

| Rota | Screen | Descrição |
|------|--------|-----------|
| /login | LoginScreen | Autenticação |
| /connection | ConnectionScreen | Conectar ESP32 |
| /selecao | SelecaoScreen | Selecionar aluno/aeronave |
| /origem-destino | OrigemDestinoScreen | Definir rota |
| /calibration | CalibrationScreen | Calibrar sensores |
| /sixpack | SixPackScreen | Instrumentos tempo real |
| /avaliacao | AvaliacaoScreen | Avaliar voo (FAP) |

---

## 🔗 INTEGRAÇÕES
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   ESP32     │────►│   MOBILE    │────►│  SUPABASE   │
│  Hardware   │WiFi │   Flutter   │4G   │   Backend   │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │     N8N     │
                                        │  Workflows  │
                                        └─────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │  ANAC CIV   │
                                        │   Digital   │
                                        └─────────────┘
```

---

**Última atualização:** 28/11/2025
