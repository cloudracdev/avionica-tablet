# 🏗️ ARQUITETURA ATUAL DO QFLY - Estado AS-IS

**Versão:** 2.0.0  
**Data:** 04/11/2025  
**Status:** FUNCIONAL (28 warnings, código operacional)

---

## 📋 ÍNDICE

1. [Visão Geral](#visão-geral)
2. [Estrutura de Pastas](#estrutura-de-pastas)
3. [Camadas da Aplicação](#camadas-da-aplicação)
4. [Fluxo de Dados](#fluxo-de-dados)
5. [Padrões Utilizados](#padrões-utilizados)
6. [Tecnologias](#tecnologias)
7. [Pontos de Entrada](#pontos-de-entrada)

---

## 🎯 VISÃO GERAL

O QFLY é um **sistema de instrução aeronáutica para tablet** que se conecta a um ESP32 via WebSocket para exibir instrumentos de voo em tempo real (Six-Pack).

### **Conceito Central:**
```
ESP32 (sensores) → WebSocket → Flutter App → 6 Instrumentos na tela
                      ↓
              [Smoothing + Calibração]
                      ↓
              [UI: CustomPainters]
```

### **Estado Atual:**
- ✅ **Funcional:** App roda e exibe instrumentos
- ✅ **Organizado:** Estrutura de pastas clara
- ⚠️ **Warnings:** 28 lints (não bloqueantes)
- ❌ **Mockado:** Telas de login/seleção não funcionais
- ❌ **Monolítico:** `sixpack_screen.dart` com 643 linhas
- ❌ **Type-unsafe:** Usa `Map<String, double>` ao invés de `FlightData`

---

## 📁 ESTRUTURA DE PASTAS

```
lib/
├── main.dart                          # Entry point
├── core/                              # Fundação do app
│   ├── constants/
│   │   ├── app_constants.dart         # Constantes gerais (WebSocket, limites)
│   │   ├── filter_constants.dart      # Constantes de filtros EMA
│   │   └── instrument_constants.dart  # Dimensões físicas dos instrumentos
│   ├── theme/                         # Tema visual (pouco usado)
│   └── utils/
│       └── logger.dart                # Sistema de logging estruturado
│
├── models/
│   └── flight_data.dart               # ⚠️ Model criado mas NÃO USADO
│
├── services/                          # Lógica de negócio
│   ├── calibration/
│   │   └── calibration_service.dart   # Calibração de instrumentos
│   ├── data_processing/
│   │   └── smoothing_service.dart     # Filtro EMA + dead zones
│   └── websocket/
│       └── websocket_service.dart     # Conexão com ESP32
│
├── painters/                          # CustomPainters dos instrumentos
│   ├── altimetro_painter.dart
│   ├── artificial_horizon_painter.dart
│   ├── bussola_painter.dart
│   ├── coordenador_painter.dart
│   ├── variometro_painter.dart
│   └── velocimetro_painter.dart
│
├── widgets/                           # Widgets dos instrumentos
│   ├── common/
│   │   └── base_instrumento.dart      # Widget base compartilhado
│   ├── instruments/
│   │   ├── altimetro_widget.dart
│   │   ├── artificial_horizon.dart
│   │   ├── bussola_widget.dart
│   │   ├── coordenador_widget.dart
│   │   ├── variometro_widget.dart
│   │   └── velocimetro_widget.dart
│   └── calibration_dialog.dart        # Dialog de calibração
│
└── screens/                           # Telas do app
    ├── login_screen.dart              # 🚫 MOCKADO (não valida)
    ├── selecao_screen.dart            # 🚫 MOCKADO (menu fake)
    ├── origem_destino_screen.dart     # 🚫 MOCKADO (não salva)
    ├── avaliacao_screen.dart          # 🚫 MOCKADO
    ├── connection_screen.dart         # Conexão WebSocket
    ├── pre_flight_calibration_screen.dart  # Calibração pré-voo
    ├── sixpack_screen.dart            # ⚠️ PRINCIPAL (643 linhas!)
    ├── telemetry_screen.dart          # Telemetria básica
    └── resumo_screen.dart             # Resumo do voo
```

---

## 🧱 CAMADAS DA APLICAÇÃO

### **1. PRESENTATION LAYER (UI)**
**Responsabilidade:** Renderizar instrumentos e capturar interações

**Componentes:**
- **Screens:** Telas completas (`*_screen.dart`)
- **Widgets:** Componentes reutilizáveis (`*_widget.dart`)
- **Painters:** Renderização custom (`*_painter.dart`)

**Estado:** ⚠️ **Misturado** - Lógica de negócio dentro das telas

---

### **2. BUSINESS LOGIC LAYER**
**Responsabilidade:** Processar dados e aplicar regras de negócio

**Componentes:**
- **SmoothingService:** Filtro EMA + dead zones
- **CalibrationService:** Offsets de calibração
- **WebSocketService:** Gerenciar conexão

**Estado:** ⚠️ **Parcial** - Existe mas está espalhado

---

### **3. DATA LAYER**
**Responsabilidade:** Acesso e manipulação de dados

**Componentes:**
- **WebSocketService:** Recebe dados do ESP32
- **FlightData:** ❌ **Criado mas não usado!**

**Estado:** ❌ **Inexistente** - Sem Repository pattern, sem persistência

---

## 🔄 FLUXO DE DADOS (ATUAL)

### **Fluxo Completo:**

```
1. ESP32 envia JSON via WebSocket (50Hz)
   ↓
2. WebSocketService.dataStream emite Map<String, dynamic>
   ↓
3. SixPackScreen escuta o stream (setState)
   ↓
4. Converte dynamic → Map<String, double>
   ↓
5. SmoothingService.smoothData() aplica EMA
   ↓
6. CalibrationService aplica offsets
   ↓
7. Calcula variômetro localmente (deltaAltitude/deltaTime)
   ↓
8. setState() → rebuild de TODA a tela
   ↓
9. Cada Widget recebe novos valores via construtor
   ↓
10. CustomPaint chama Painter.paint()
    ↓
11. Painter desenha instrumento com Canvas
```

### **Formato dos Dados:**

**ESP32 envia (JSON):**
```json
{
  "velocidade": 120.5,
  "altitude": 1500.0,
  "heading": 270.0,
  "pitch": 5.0,
  "roll": -3.0,
  "variometro": 2.5,
  "temperatura": 15.0,
  "pressao": 101325.0,
  "lat": -25.4284,
  "lng": -49.2733,
  "gyro_x": 0.1, "gyro_y": 0.2, "gyro_z": 0.3,
  "acel_x": 0.05, "acel_y": -0.02, "acel_z": 1.0,
  "lsm_gx": 1.2, "lsm_gy": -0.5, "lsm_gz": 0.8,
  "lsm_ax": 0.1, "lsm_ay": -0.05, "lsm_az": 1.0,
  "satelites": 12,
  "hdop": 0.9
}
```

**App usa (Map<String, double>):**
```dart
{
  'velocidade': 120.5,
  'altitude': 1500.0,
  'heading': 270.0,
  'pitch': 5.0,
  'roll': -3.0,
  'vario': 2.5,  // Calculado localmente!
  'temperatura': 15.0,
  'pressao': 101325.0,
  'lat': -25.4284,
  'lng': -49.2733,
  'acel_x': 0.1,
  'acel_y': -0.05
}
```

---

## 🎨 PADRÕES UTILIZADOS

### **1. CustomPainter Pattern** ✅
**Onde:** Todos os 6 instrumentos  
**Por quê:** Performance (GPU-accelerated drawing)  
**Status:** ✅ **Implementado corretamente**

```dart
// Separação clara: Widget → Painter
AltimetroWidget → AltimetroPainter
```

### **2. Service Pattern** ⚠️
**Onde:** Calibration, Smoothing, WebSocket  
**Por quê:** Encapsular lógica de negócio  
**Status:** ⚠️ **Parcial** - Serviços existem mas não há injeção de dependência

### **3. Stream Pattern** ✅
**Onde:** WebSocket → SixPackScreen  
**Por quê:** Reatividade  
**Status:** ✅ **Funciona** mas causa rebuilds desnecessários

### **4. State Management** ❌
**Onde:** Nenhum  
**Atual:** `setState()` em todo lugar  
**Status:** ❌ **Manual e ineficiente**

---

## 🔧 TECNOLOGIAS

### **Flutter & Dart**
- **Flutter:** 3.x (Material 3)
- **Dart:** 3.x
- **Platform:** Android/iOS (tablet)

### **Dependências Principais:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  web_socket_channel: ^2.4.0  # WebSocket client
  # Sem state management
  # Sem HTTP client
  # Sem persistência local
```

### **Sensores (ESP32):**
- **L3G4200D:** Giroscópio (gyro_x, gyro_y, gyro_z)
- **ADXL345:** Acelerômetro (acel_x, acel_y, acel_z)
- **LSM6DS3:** Giroscópio + Acelerômetro (lsm_gx, lsm_ax, etc)
- **BMP280:** Pressão + Temperatura
- **GPS:** Latitude, Longitude, Satélites, HDOP

---

## 🚪 PONTOS DE ENTRADA

### **1. main.dart → LoginScreen**
```dart
void main() {
  runApp(const MyApp());
}

// MyApp → MaterialApp → LoginScreen
```

**Navegação:**
```
LoginScreen (mockado)
  ↓ [botão ENTRAR]
SelecaoScreen (mockado - 3 botões)
  ↓ [botão VOO INSTRUÇÃO]
OrigemDestinoScreen (mockado)
  ↓ [botão CONTINUAR]
ConnectionScreen (funcional)
  ↓ [conecta WebSocket]
PreFlightCalibrationScreen (funcional)
  ↓ [calibra instrumentos]
SixPackScreen (PRINCIPAL - 643 linhas!)
  ↓ [voa com instrumentos]
ResumoScreen (mostra estatísticas)
```

### **2. Fluxo Alternativo: TelemetryScreen**
```dart
// Acesso direto via código (não tem botão no app)
Navigator.push(context, TelemetryScreen());
```

---

## 📊 MÉTRICAS ATUAIS

### **Linhas de Código:**
- **Total:** ~5.000 linhas
- **Maior arquivo:** `sixpack_screen.dart` (643 linhas) ⚠️
- **Painters:** ~150 linhas cada ✅
- **Widgets:** ~80 linhas cada ✅
- **Services:** ~100 linhas cada ✅

### **Warnings:**
- **Total:** 28 (era 79, reduzimos 65%)
- **Críticos:** 0
- **Info:** 28 (deprecated, super_parameters, etc)

### **Testes:**
- **Unitários:** 0 ❌
- **Widget:** 0 ❌
- **Integração:** 0 ❌
- **Coverage:** 0% ❌

### **Performance:**
- **Frame rate:** 30-60 FPS (sem medição)
- **Update rate:** 50 Hz (ESP32)
- **Rebuild rate:** 50 Hz (ineficiente!) ⚠️

---

## 🎯 PRINCIPAIS CARACTERÍSTICAS

### **✅ PONTOS FORTES:**

1. **Organização de pastas clara e lógica**
2. **Separação Painter/Widget bem feita**
3. **Constants centralizados**
4. **Logger estruturado implementado**
5. **Smoothing e Calibração funcionam bem**
6. **CustomPainters com boa performance**

### **❌ PONTOS FRACOS:**

1. **sixpack_screen.dart gigante (643 linhas)**
   - Mistura UI + lógica + estado
   - Difícil de testar
   - Rebuild completo a cada update

2. **FlightData não usado**
   - Model criado mas esquecido
   - Continua usando Map<String, double>
   - Sem type-safety

3. **State management manual**
   - setState() em todo lugar
   - Sem Provider/Riverpod/Bloc
   - Performance subótima

4. **Zero testes**
   - Refatorar = medo de quebrar
   - Sem garantias de qualidade

5. **Telas mockadas**
   - Login não valida
   - Dados não persistem
   - Features incompletas

6. **Sem error handling robusto**
   - Try-catch básico
   - Sem retry logic
   - Sem feedback ao usuário

---

## 📚 DOCUMENTOS RELACIONADOS

- **FILE_GUIDE_CURRENT.md** - Guia detalhado de cada arquivo
- **FLOW_DIAGRAMS_CURRENT.mmd** - Diagramas visuais
- **PROBLEMS_IDENTIFIED.md** - Problemas e soluções propostas

---

## 📝 NOTAS IMPORTANTES

### **Por que sixpack_screen tem 643 linhas?**
Porque faz TUDO:
- Escuta WebSocket
- Converte tipos
- Aplica smoothing
- Aplica calibração
- Calcula variômetro
- Mantém estatísticas
- Gerencia navegação
- Renderiza 6 instrumentos
- Controla orientação
- Mostra dialogs

**Deveria ter:** ~150 linhas (só UI)

### **Por que não usa FlightData?**
Foi criado na refatoração recente mas a migração não foi concluída.  
Ainda usa Map por inércia do código antigo.

### **Como os dados fluem tão rápido (50Hz)?**
O ESP32 envia 50 frames/segundo via WebSocket.  
A cada frame, todo o SixPackScreen rebuilda (ineficiente).  
CustomPainters são eficientes então compensa.

---

**Próximo:** [FILE_GUIDE_CURRENT.md](FILE_GUIDE_CURRENT.md)