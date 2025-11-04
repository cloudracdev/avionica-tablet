# DIAGRAMAS DE FLUXO - QFLY (Estado Atual)

**Formato:** Mermaid (pode ser visualizado no GitHub, VS Code, ou https://mermaid.live)

---

## 📋 ÍNDICE

1. [Arquitetura Geral](#1-arquitetura-geral)
2. [Fluxo de Navegação](#2-fluxo-de-navegação)
3. [Fluxo de Dados (ESP32 → Tela)](#3-fluxo-de-dados-esp32--tela)
4. [Ciclo de Vida do SixPackScreen](#4-ciclo-de-vida-do-sixpackscreen)
5. [Pipeline de Processamento](#5-pipeline-de-processamento)
6. [Estrutura de Classes](#6-estrutura-de-classes)

---

## 1. ARQUITETURA GERAL

```mermaid
graph TD
    subgraph "APRESENTAÇÃO (UI)"
        A[Screens]
        B[Widgets]
        C[Painters]
    end
    
    subgraph "LÓGICA (Services)"
        D[WebSocketService]
        E[SmoothingService]
        F[CalibrationService]
    end
    
    subgraph "DADOS"
        G[Models - FlightData ⚠️ NÃO USADO]
        H[Map<String,double> ✓ USADO]
    end
    
    subgraph "EXTERNO"
        I[ESP32 Hardware]
    end
    
    I -->|WebSocket JSON| D
    D -->|Stream| A
    A -->|Usa| E
    A -->|Usa| F
    E -->|Retorna Map| A
    F -->|Aplica offsets| A
    A -->|Passa dados| B
    B -->|Renderiza com| C
    
    style A fill:#e1f5ff
    style D fill:#fff4e6
    style G fill:#ffebee
    style H fill:#e8f5e9
```

---

## 2. FLUXO DE NAVEGAÇÃO

```mermaid
graph TD
    START([App Inicia])
    START --> MAIN[main.dart]
    MAIN --> LOGIN[LoginScreen<br/>mockado]
    
    LOGIN -->|Clica ENTRAR| SELECAO[SelecaoScreen<br/>Escolhe modo]
    
    SELECAO -->|Voo Solo| ORIGEM1[OrigemDestinoScreen<br/>mockada]
    SELECAO -->|Voo Instrução| ORIGEM2[OrigemDestinoScreen<br/>mockada]
    SELECAO -->|Telemetria| TELEM[TelemetryScreen]
    
    ORIGEM1 --> CONN1[ConnectionScreen]
    ORIGEM2 --> CONN2[ConnectionScreen]
    TELEM --> CONN3[ConnectionScreen]
    
    CONN1 -->|WebSocket OK| PREFLIGHT[PreFlightCalibration<br/>Calibra instrumentos]
    CONN2 -->|WebSocket OK| PREFLIGHT
    CONN3 -->|WebSocket OK| PREFLIGHT
    
    PREFLIGHT -->|Calibrado| SIXPACK[SixPackScreen<br/>⚠️ 643 linhas<br/>CORE DO APP]
    
    SIXPACK -->|Finaliza voo| RESUMO[ResumoScreen<br/>Estatísticas]
    
    RESUMO -->|Avaliar?| AVAL[AvaliacaoScreen<br/>mockada]
    RESUMO -->|Novo voo| SELECAO
    
    AVAL --> SELECAO
    
    style SIXPACK fill:#ff9800,color:#000
    style LOGIN fill:#ffebee
    style ORIGEM1 fill:#ffebee
    style ORIGEM2 fill:#ffebee
    style AVAL fill:#ffebee
    style PREFLIGHT fill:#c8e6c9
    style SELECAO fill:#e1f5ff
```

**Legenda:**
- 🟠 Laranja: Arquivo muito grande (problema)
- 🔴 Vermelho: Mockado (sem backend)
- 🟢 Verde: Funcional crítico
- 🔵 Azul: Funcional normal

---

## 3. FLUXO DE DADOS (ESP32 → Tela)

```mermaid
sequenceDiagram
    participant ESP as ESP32 Hardware
    participant WS as WebSocketService
    participant SIX as SixPackScreen
    participant SMOOTH as SmoothingService
    participant CALIB as CalibrationService
    participant WIDGET as Widget Instrumento
    participant PAINT as CustomPainter
    
    Note over ESP: Sensores: MPU, BMP, GPS
    ESP->>WS: JSON via WebSocket<br/>{velocidade:120, altitude:1500, ...}
    
    WS->>SIX: Stream: Map<String,dynamic>
    
    Note over SIX: ETAPA 1: Conversão
    SIX->>SIX: dynamic → double<br/>Cria Map<String,double>
    
    Note over SIX: ETAPA 2: Suavização
    SIX->>SMOOTH: smoothData(rawMap)
    SMOOTH->>SMOOTH: Aplica EMA + Dead Zone
    SMOOTH-->>SIX: Map<String,double> suavizado
    
    Note over SIX: ETAPA 3: Calibração
    SIX->>CALIB: applyCalibratedAltitude(raw)
    CALIB-->>SIX: altitude corrigida
    SIX->>CALIB: applyCalibratedHeading(raw)
    CALIB-->>SIX: heading corrigido
    
    Note over SIX: ETAPA 4: Cálculos Locais
    SIX->>SIX: Calcula variômetro<br/>Δalt/Δtime
    SIX->>SIX: Atualiza estatísticas<br/>max/min
    
    Note over SIX: ETAPA 5: UI Update
    SIX->>SIX: setState()
    SIX->>WIDGET: Rebuild com novos dados
    WIDGET->>PAINT: CustomPaint(painter)
    
    Note over PAINT: Desenha instrumento
    PAINT->>PAINT: paint(canvas, size)
```

---

## 4. CICLO DE VIDA DO SIXPACKSCREEN

```mermaid
stateDiagram-v2
    [*] --> Criado: Navigator.push
    
    Criado --> Inicializando: initState()
    
    Note right of Inicializando
        1. Cria services
        2. Inicia cronômetro
        3. Permite rotação
        4. Subscribe WebSocket
    end note
    
    Inicializando --> Aguardando: Esperando dados
    
    Aguardando --> Processando: Dados chegam (50ms)
    
    Note right of Processando
        1. Converte dados
        2. Aplica smoothing
        3. Aplica calibração
        4. Calcula vario
        5. Atualiza stats
        6. setState()
    end note
    
    Processando --> Renderizando: build()
    
    Note right of Renderizando
        1. PageView 2 páginas
        2. 6 widgets instrumentos
        3. Cada widget → Painter
        4. Painter desenha Canvas
    end note
    
    Renderizando --> Aguardando: Aguarda próximo frame
    
    Aguardando --> Finalizando: Botão "Finalizar Voo"
    
    Finalizando --> Destruido: dispose()
    
    Note right of Finalizando
        1. Cancela subscription
        2. Coleta estatísticas
        3. Navigator.push(Resumo)
    end note
    
    Destruido --> [*]
```

---

## 5. PIPELINE DE PROCESSAMENTO (DETALHADO)

```mermaid
flowchart TB
    START([Dados chegam do ESP32])
    
    START --> CONV{Conversão<br/>dynamic → double}
    CONV --> RAW[Map<String,double><br/>rawData]
    
    RAW --> SMOOTH[SmoothingService.smoothData]
    
    subgraph "Smoothing Service"
        SMOOTH --> FIRST{Primeira<br/>leitura?}
        FIRST -->|Sim| RETURN1[Retorna raw<br/>sem filtrar]
        FIRST -->|Não| EMA[Aplica EMA<br/>S = α*Y + 1-α*S]
        EMA --> DZ{|novo-atual|<br/>< deadZone?}
        DZ -->|Sim| KEEP[Mantém valor atual]
        DZ -->|Não| UPDATE[Atualiza com EMA]
        KEEP --> RETURN2[Retorna smoothed]
        UPDATE --> RETURN2
    end
    
    RETURN1 --> SMOOTHED[Map smoothed]
    RETURN2 --> SMOOTHED
    
    SMOOTHED --> CALIB[CalibrationService]
    
    subgraph "Calibration Service"
        CALIB --> APPLYH[heading + offset<br/>wrap 0-360°]
        CALIB --> APPLYP[pitch + offset]
        CALIB --> APPLYR[roll + offset]
        CALIB --> APPLYA[altitude + offset]
    end
    
    APPLYH --> CALIBRATED[Dados calibrados]
    APPLYP --> CALIBRATED
    APPLYR --> CALIBRATED
    APPLYA --> CALIBRATED
    
    CALIBRATED --> VARIO{Calcular<br/>Variômetro?}
    
    VARIO -->|Passou 500ms| CALCV[Δalt = alt - alt_prev<br/>vario = Δalt/Δtime<br/>vario_smooth = EMA]
    VARIO -->|< 500ms| KEEPV[Mantém vario atual]
    
    CALCV --> STATS[Atualizar<br/>Estatísticas]
    KEEPV --> STATS
    
    STATS --> SETSTATE[setState]
    SETSTATE --> BUILD[build]
    BUILD --> UI[Renderiza 6 instrumentos]
    
    UI --> END([Aguarda próximo frame])
    
    style SMOOTH fill:#fff9c4
    style CALIB fill:#c5cae9
    style VARIO fill:#c8e6c9
    style UI fill:#e1f5ff
```

---

## 6. ESTRUTURA DE CLASSES (SIMPLIFICADA)

```mermaid
classDiagram
    class WebSocketService {
        -WebSocketChannel _channel
        -StreamController _dataController
        -bool _isConnected
        +connect(ipAddress)
        +disconnect()
        +Stream dataStream
    }
    
    class SmoothingService {
        -double _smoothVelocidade
        -double _smoothAltitude
        -bool _firstReading
        +smoothData(rawData) Map
        -_smooth(value, current, alpha, deadZone)
        -_smoothCircular(value, current, alpha, deadZone)
    }
    
    class CalibrationService {
        -double _headingOffset
        -double _pitchOffset
        -double _rollOffset
        -double _altitudeOffset
        +calibrateHeading(real, current)
        +zeroPitch(current)
        +zeroRoll(current)
        +zeroAltitude(current)
        +applyCalibratedHeading(raw) double
        +applyCalibratedPitch(raw) double
        +applyCalibratedRoll(raw) double
        +applyCalibratedAltitude(raw) double
    }
    
    class FlightData {
        +double velocidade
        +double altitude
        +double heading
        +double pitch
        +double roll
        +double vario
        +DateTime timestamp
        +fromMap(map)$ FlightData
        +toMap() Map
        +copyWith() FlightData
    }
    
    class SixPackScreen {
        ⚠️ 643 LINHAS - MUITO GRANDE
        -WebSocketService wsService
        -SmoothingService _smooth
        -CalibrationService _calib
        -22 variáveis de estado
        +initState()
        +build() Widget
        -_openCalibrationDialog()
    }
    
    class InstrumentoWidget {
        <<abstract>>
        +double valor
        +build() Widget
    }
    
    class ArtificialHorizon {
        +double pitch
        +double roll
        +build() Widget
    }
    
    class CustomPainter {
        <<Flutter>>
        +paint(canvas, size)
        +shouldRepaint() bool
    }
    
    class ArtificialHorizonPainter {
        +double pitch
        +double roll
        +paint(canvas, size)
        +shouldRepaint() bool
    }
    
    WebSocketService "1" --> "*" SixPackScreen : stream
    SixPackScreen "1" --> "1" SmoothingService : usa
    SixPackScreen "1" --> "1" CalibrationService : usa
    SixPackScreen "1" --> "6" InstrumentoWidget : renderiza
    InstrumentoWidget <|-- ArtificialHorizon : herda
    ArtificialHorizon "1" --> "1" ArtificialHorizonPainter : usa
    CustomPainter <|-- ArtificialHorizonPainter : herda
    FlightData -.-> SixPackScreen : deveria usar mas NÃO USA
    
    note for FlightData "⚠️ PROBLEMA: Criado mas não usado!<br/>Código usa Map em vez de FlightData"
    
    note for SixPackScreen "⚠️ PROBLEMA: God Object<br/>- 643 linhas<br/>- 10 responsabilidades<br/>- 22 variáveis de estado"
```

---

## 7. DEPENDÊNCIAS ENTRE ARQUIVOS

```mermaid
graph LR
    subgraph "Core"
        CONST[Constants]
        LOGGER[Logger]
    end
    
    subgraph "Services"
        WS[WebSocketService]
        SMOOTH[SmoothingService]
        CALIB[CalibrationService]
    end
    
    subgraph "Models"
        FD[FlightData<br/>⚠️ não usado]
    end
    
    subgraph "Screens"
        LOGIN[LoginScreen]
        SEL[SelecaoScreen]
        CONN[ConnectionScreen]
        PRE[PreFlightCalib]
        SIX[SixPackScreen<br/>643L ⚠️]
        RESUM[ResumoScreen]
    end
    
    subgraph "Widgets"
        BASE[BaseInstrumento]
        W1[ArtificialHorizon]
        W2[Coordenador]
        W3[Altimetro]
        W4[Velocimetro]
        W5[Bussola]
        W6[Variometro]
    end
    
    subgraph "Painters"
        P1[ArtificialHorizonPainter]
        P2[CoordenadorPainter]
        P3[AltimetroPainter]
        P4[VelocimetroPainter]
        P5[BussolaPainter]
        P6[VariometroPainter]
    end
    
    WS --> SIX
    SMOOTH --> SIX
    CALIB --> SIX
    CONST --> WS
    CONST --> SMOOTH
    CONST --> SIX
    LOGGER --> SIX
    LOGGER --> WS
    
    SIX --> W1
    SIX --> W2
    SIX --> W3
    SIX --> W4
    SIX --> W5
    SIX --> W6
    
    W1 --> BASE
    W2 --> BASE
    W3 --> BASE
    W4 --> BASE
    W5 --> BASE
    W6 --> BASE
    
    W1 --> P1
    W2 --> P2
    W3 --> P3
    W4 --> P4
    W5 --> P5
    W6 --> P6
    
    P1 --> CONST
    P2 --> CONST
    P3 --> CONST
    P4 --> CONST
    P5 --> CONST
    P6 --> CONST
    
    LOGIN --> SEL
    SEL --> CONN
    CONN --> PRE
    PRE --> SIX
    SIX --> RESUM
    
    style SIX fill:#ff9800,color:#000
    style FD fill:#ffebee
```

---

## 📊 ANÁLISE DOS DIAGRAMAS

### Pontos Positivos ✅
1. **Separação clara:** Painters isolados dos Widgets
2. **Services reutilizáveis:** WebSocket, Smoothing, Calibration
3. **Fluxo de dados unidirecional:** ESP32 → Service → Screen → Widget → Painter

### Pontos Negativos ⚠️
1. **SixPackScreen centraliza TUDO:** 643 linhas, 10 responsabilidades
2. **FlightData não usado:** Modelo criado mas ignored
3. **Alto acoplamento:** SixPackScreen depende diretamente de 3 services
4. **Sem abstração:** Services instanciados diretamente (sem DI)
5. **State management manual:** setState não escala

### Gargalos Identificados 🔴
1. **SixPackScreen.build()** - Reconstrui tudo a cada frame (30 FPS)
2. **Smoothing em loop** - Processa 12 parâmetros a cada 50ms
3. **Variômetro calculado localmente** - Deveria ser no ESP32 ou Service

---

## 🎯 CONCLUSÃO

Os diagramas mostram claramente:
- ✅ Estrutura de pastas bem organizada
- ✅ Separação Painter/Widget bem feita
- ⚠️ SixPackScreen é o bottleneck arquitetural
- ⚠️ Falta camada de abstração (Repository, State Management)
- ⚠️ FlightData deveria substituir Map<String,double>

**Prioridade máxima:** Refatorar SixPackScreen

---

**Para visualizar estes diagramas:**
1. GitHub: Renderiza automaticamente `.md` com Mermaid
2. VS Code: Instalar extensão "Markdown Preview Mermaid Support"
3. Online: Copiar código para https://mermaid.live

**Documento criado em:** 04/11/2025  
**Versão:** 1.0