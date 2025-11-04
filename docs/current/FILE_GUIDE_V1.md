# GUIA DE ARQUIVOS - QFLY Sistema de Instrução Aeronáutica

**Propósito:** Entender O QUE cada arquivo faz e POR QUÊ existe

---

## 📋 ÍNDICE

1. [Entry Point](#entry-point)
2. [Core (Núcleo)](#core-núcleo)
3. [Models (Modelos de Dados)](#models-modelos-de-dados)
4. [Services (Serviços)](#services-serviços)
5. [Screens (Telas)](#screens-telas)
6. [Widgets (Componentes)](#widgets-componentes)
7. [Painters (Renderização)](#painters-renderização)

---

## 🚀 ENTRY POINT

### `lib/main.dart` (22 linhas)

**O que faz:**
- Inicializa o aplicativo Flutter
- Configura tema Material3
- Define LoginScreen como tela inicial

**Código-chave:**
```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(...),
      home: const LoginScreen(),  // ← Primeira tela
    );
  }
}
```

**Quando é executado:** Ao iniciar o app

**Dependências:** LoginScreen, AppConstants

---

## 🎯 CORE (NÚCLEO)

### `lib/core/constants/app_constants.dart` (160 linhas)

**O que faz:**
- Armazena TODAS as constantes do aplicativo
- URLs, limites, strings de UI, configurações

**Constantes importantes:**
```dart
static const String defaultWebSocketUrl = 'ws://192.168.4.1:81';
static const int instrumentUpdateRate = 30; // Hz
static const double maxPitch = 90.0;
static const double maxRoll = 180.0;
static const String appName = 'QFLY - Sistema de Instrução';
```

**Por que existe:** Centralizar valores mágicos, facilitar mudanças globais

**Usado por:** Todas as telas e services

---

### `lib/core/constants/instrument_constants.dart` (220 linhas)

**O que faz:**
- Dimensões físicas dos instrumentos
- Escalas, tamanhos, posições relativas

**Constantes por instrumento:**
```dart
// Horizonte Artificial
static const double horizonPitchScale = 3.0;          // px/grau
static const double horizonAirplaneWingspan = 0.5;   // % do raio

// Coordenador
static const double coordenadorBallSensitivity = 1.0;
static const double coordenadorBallMaxOffset = 0.3;
```

**Por que existe:** Separar valores visuais da lógica de renderização

**Usado por:** Todos os Painters

---

### `lib/core/utils/logger.dart` (85 linhas)

**O que faz:**
- Sistema de logging centralizado e estruturado
- Níveis: debug, info, warning, error
- Filtragem por tag
- Formatação com timestamp

**Como usar:**
```dart
Logger.debug('Pitch: $pitch°', 'SixPack');
Logger.error('Falha ao conectar', error, stackTrace, 'WebSocket');
```

**Por que existe:** Substituir print() por logs profissionais e filtráveis

**Usado por:** sixpack_screen, websocket_service

---

## 📦 MODELS (MODELOS DE DADOS)

### `lib/models/flight_data.dart` (230 linhas)

**O que faz:**
- Define modelo imutável de dados de voo
- Type-safe alternative para Map<String, double>
- Métodos: fromMap, toMap, copyWith

**Estrutura:**
```dart
class FlightData {
  final double velocidade;
  final double altitude;
  final double heading;
  final double pitch;
  final double roll;
  final double vario;
  final double temperatura;
  final double pressao;
  final double lat;
  final double lng;
  final double accelX;
  final double accelY;
  final DateTime timestamp;
}
```

**⚠️ PROBLEMA:** Criado mas NÃO USADO! Código ainda usa Map<String, double>

**Por que existe:** Melhorar type-safety e autocomplete

**Deveria ser usado por:** SmoothingService, CalibrationService, SixPackScreen

---

## 🔧 SERVICES (SERVIÇOS)

### `lib/services/websocket/websocket_service.dart` (68 linhas)

**O que faz:**
- Conecta ao ESP32 via WebSocket
- Recebe stream de dados JSON
- Gerencia conexão/desconexão

**API Pública:**
```dart
void connect(String ipAddress)     // Conecta
void disconnect()                  // Desconecta
void sendData(String message)     // Envia comando
Stream<Map<String, dynamic>> get dataStream  // Stream de dados
bool get isConnected              // Status
```

**Fluxo:**
```
1. connect('192.168.4.1') 
2. WebSocket conecta em ws://192.168.4.1:81
3. Recebe JSON do ESP32
4. Decodifica e emite no dataStream
5. Listeners recebem Map<String, dynamic>
```

**Usado por:** SixPackScreen (principal), TelemetryScreen

**Depende de:** web_socket_channel

---

### `lib/services/calibration/calibration_service.dart` (80 linhas)

**O que faz:**
- Armazena offsets de calibração
- Corrige leituras dos sensores

**Offsets:**
```dart
double _headingOffset = 0.0;   // Diferença real vs leitura
double _pitchOffset = 0.0;     // Nível zero
double _rollOffset = 0.0;      // Nível zero
double _altitudeOffset = 0.0;  // QFE/QNH
```

**Métodos de Calibração:**
```dart
// Exemplo: Bússola mostra 90° mas está em 95°
calibrateHeading(95.0, 90.0);  // offset = +5°

// Zerar pitch (avião nivelado)
zeroPitch(currentPitch);  // offset = -currentPitch
```

**Métodos de Aplicação:**
```dart
double heading = applyCalibratedHeading(rawHeading);
// heading = rawHeading + _headingOffset (com wrap 0-360°)
```

**Usado por:** SixPackScreen

**Criado em:** PreFlightCalibrationScreen

---

### `lib/services/data_processing/smoothing_service.dart` (190 linhas)

**O que faz:**
- Suaviza ruído dos sensores
- Aplica filtro EMA (Exponential Moving Average)
- Usa dead zone para ignorar pequenas variações

**Algoritmo EMA:**
```
S_t = α * Y_t + (1-α) * S_{t-1}

Onde:
S_t = valor suavizado no tempo t
Y_t = valor bruto no tempo t
α = alpha (0-1): quanto de peso dar ao novo valor
  - α alto (0.5): mais responsivo, menos suave
  - α baixo (0.1): mais suave, menos responsivo
```

**Algoritmo Dead Zone:**
```
if |novo_valor - valor_atual| < threshold:
    return valor_atual  // Ignora mudança
else:
    aplica EMA
```

**Exemplo:**
```dart
// Altitude variando entre 99.8m e 100.2m (ruído)
// Com dead zone de 0.5m → mostra 100.0m estável

// Pitch mudou de 5.0° para 5.1° (mudança real pequena)
// Com alpha=0.25 → suaviza para 5.025°
```

**Método Principal:**
```dart
Map<String, double> smoothData(Map<String, double> rawData) {
  // Aplica EMA + dead zone em todos os parâmetros
  // Retorna Map suavizado
}
```

**Tratamento Especial:**
- **Heading (0-360°):** Usa smoothCircular (evita salto 359° → 0°)
- **Primeira leitura:** Retorna raw sem filtrar

**Usado por:** SixPackScreen (a cada 50ms)

---

## 🖥️ SCREENS (TELAS)

### `lib/screens/sixpack_screen.dart` ⚠️ (643 LINHAS - PROBLEMA!)

**RESPONSABILIDADES (10!):**

1. **Recepção de Dados** - Escuta WebSocket
2. **Conversão** - dynamic → double
3. **Suavização** - Chama SmoothingService
4. **Calibração** - Chama CalibrationService
5. **Cálculo Variômetro** - Lógica local de Δaltitude/Δtime
6. **Estatísticas** - Rastreia max/min
7. **UI** - Renderiza 6 instrumentos
8. **Navegação** - Controla PageView
9. **Orientação** - Gerencia landscape/portrait
10. **Logging** - 6 Logger.debug()

**ESTADO (22 variáveis!):**
```dart
// Dados brutos suavizados
double _rawV, _rawA, _rawH, _rawP, _rawR;

// Dados calibrados exibidos
double velocidade, altitude, heading, pitch, roll, vario;
double temperatura, pressao, lat, lng;

// Coordenador
double gyroZ, accelX, accelY;

// Estatísticas
DateTime? _inicioVoo;
double _velocidadeMax, _altitudeMax;
double _pitchMax, _pitchMin;
double _rollMax, _rollMin;
double _varioMax, _varioMin;
double _temperaturaMax, _temperaturaMin;
```

**POR QUE É UM PROBLEMA:**
- ❌ Viola Single Responsibility Principle
- ❌ Difícil de testar (lógica misturada com UI)
- ❌ Impossível reutilizar partes
- ❌ Alto acoplamento (3 services diretos)
- ❌ 643 linhas = muito para manter

**COMO DEVERIA SER:**
```
sixpack_screen.dart (150L) - Só UI
    ↓
flight_controller.dart (100L) - Lógica
    ↓
statistics_service.dart (80L) - Stats
```

---

## 🧩 WIDGETS (COMPONENTES)

Todos os widgets de instrumentos seguem o mesmo padrão:

```dart
class InstrumentoWidget extends StatelessWidget {
  final double valor;
  
  Widget build(BuildContext context) {
    return BaseInstrumento(
      title: 'NOME',
      value: '$valor unidade',
      child: CustomPaint(
        painter: InstrumentoPainter(valor),
      ),
    );
  }
}
```

**6 Widgets (~80 linhas cada):**
1. ArtificialHorizon (pitch, roll)
2. Coordenador (roll, accelX, accelY, gyroZ)
3. Altimetro (altitude)
4. Velocimetro (velocidade)
5. Bussola (heading)
6. Variometro (vario)

---

## 🎨 PAINTERS (RENDERIZAÇÃO)

Todos herdam de CustomPainter:

```dart
class Painter extends CustomPainter {
  final double valor;
  
  @override
  void paint(Canvas canvas, Size size) {
    // Desenha com Canvas API
  }
  
  @override
  bool shouldRepaint(Painter old) {
    return valor != old.valor;
  }
}
```

**6 Painters (~280 linhas média):**
1. ArtificialHorizonPainter - Céu/terra rotativo, pitch scale
2. CoordenadorPainter - Avião + bolinha inclinômetro
3. AltimetroPainter - 2 ponteiros (centenas, milhares)
4. VelocimetroPainter - Ponteiro + arcos coloridos
5. BussolaPainter - Rosa dos ventos giratória
6. VariometroPainter - Escala vertical -15 a +15

---

## 📊 MÉTRICAS

```
ARQUIVO                        LINHAS    COMPLEXIDADE
======================================================
sixpack_screen.dart               643    🔴 MUITO ALTA
smoothing_service.dart            190    Alta
pre_flight_calibration_screen     350    Alta
artificial_horizon_painter        300    Alta
altimetro_painter                 300    Alta
variometro_painter                300    Alta
coordenador_painter               280    Alta
bussola_painter                   270    Média
login_screen.dart                 260    Média
velocimetro_painter               250    Média
flight_data.dart                  230    Baixa
instrument_constants              220    Baixa
app_constants                     160    Baixa
telemetry_screen                  150    Média
calibration_dialog                100    Média
logger.dart                        85    Média
calibration_service                80    Baixa
base_instrumento                   70    Baixa
websocket_service                  68    Média
main.dart                          22    Baixa
======================================================
TOTAL                           ~6500
```

---

**Documento criado em:** 04/11/2025  
**Versão:** 1.0