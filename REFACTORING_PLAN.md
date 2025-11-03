# 🚀 PLANO DE REFATORAÇÃO - QFLY Sistema de Instrumentos

## 📊 DIAGNÓSTICO ATUAL

### ❌ Problemas Identificados

**1. Arquitetura Monolítica**
   - Widgets + Painters no mesmo arquivo (dificulta manutenção)
   - Lógica de negócio misturada com UI
   - Sem separação de responsabilidades (Single Responsibility Principle violado)

**2. Magic Numbers & Hardcoding**
   - Valores como `0.15`, `0.3`, `3.0` espalhados sem contexto
   - Cores, tamanhos e configurações hardcoded
   - Dificulta ajustes e testes A/B

**3. Documentação Inconsistente**
   - Comentários em PT-BR misturado com código em inglês
   - Sem dartdoc padrão
   - Falta explicação de algoritmos (EMA, Dead Zone)

**4. Testabilidade Baixa**
   - Services acoplados
   - Difícil mockar dependências
   - Sem testes unitários

**5. Escalabilidade Limitada**
   - Adicionar novo instrumento = modificar múltiplos arquivos
   - Sem interfaces/abstrações
   - Alto risco de regressão

---

## 🎯 OBJETIVOS DA REFATORAÇÃO

### ✅ O Que Vamos Alcançar

1. **Código Limpo (Clean Code)**
   - SOLID principles aplicados
   - Funções pequenas (max 20 linhas)
   - Nomes descritivos em inglês

2. **Manutenibilidade**
   - Modificar um instrumento sem afetar outros
   - Adicionar novos instrumentos facilmente
   - Debug simplificado

3. **Performance**
   - Otimizar repaints desnecessários
   - Cache de cálculos pesados
   - Reduzir alocações de memória

4. **Documentação Profissional**
   - Dartdoc em todos os public members
   - Diagramas de arquitetura
   - Exemplos de uso

5. **Testabilidade**
   - Cobertura de testes > 80%
   - Services totalmente testáveis
   - Mocks e fixtures organizados

---

## 🏗️ NOVA ESTRUTURA PROPOSTA

```
lib/
├── 📂 core/
│   ├── constants/
│   │   ├── instrument_constants.dart    # Tamanhos, cores, limites físicos
│   │   ├── filter_constants.dart        # Alpha, dead zones, thresholds
│   │   └── app_constants.dart           # Configurações gerais
│   ├── theme/
│   │   └── instrument_theme.dart        # Tema centralizado dos instrumentos
│   └── utils/
│       └── math_utils.dart              # Funções matemáticas reutilizáveis
│
├── 📂 models/
│   ├── flight_data.dart                 # Modelo principal de dados de voo
│   ├── sensor_reading.dart              # Leitura bruta dos sensores
│   ├── calibration_data.dart            # Dados de calibração
│   └── instrument_config.dart           # Configuração de cada instrumento
│
├── 📂 services/
│   ├── data_processing/
│   │   ├── smoothing_service.dart       # Refatorado e documentado
│   │   ├── ema_filter.dart              # Filtro EMA isolado
│   │   └── dead_zone_filter.dart        # Dead zone isolado
│   ├── calibration/
│   │   ├── calibration_service.dart     # Refatorado
│   │   └── offset_calculator.dart       # Cálculo de offsets
│   └── websocket/
│       └── data_stream_service.dart     # Comunicação ESP32
│
├── 📂 widgets/
│   ├── instruments/
│   │   ├── artificial_horizon_widget.dart    # UI only
│   │   ├── coordenador_widget.dart           # UI only
│   │   ├── altimeter_widget.dart             # UI only
│   │   ├── airspeed_widget.dart              # UI only
│   │   ├── heading_widget.dart               # UI only
│   │   └── variometer_widget.dart            # UI only
│   └── common/
│       ├── instrument_container.dart         # Container padrão
│       └── instrument_label.dart             # Label reutilizável
│
├── 📂 painters/
│   ├── artificial_horizon_painter.dart       # Separado da UI
│   ├── coordenador_painter.dart              # Separado da UI
│   ├── altimeter_painter.dart
│   ├── airspeed_painter.dart
│   ├── heading_painter.dart
│   └── variometer_painter.dart
│
├── 📂 screens/
│   ├── login_screen.dart
│   ├── sixpack_screen.dart                   # Tela principal refatorada
│   └── calibration_screen.dart
│
└── main.dart
```

---

## 📅 CRONOGRAMA DETALHADO

### 🔷 FASE 1: Estrutura Base (Estimativa: 15min)

**Objetivo:** Criar esqueleto do projeto

**Tarefas:**
1. Criar estrutura de pastas completa
2. Criar arquivo `constants/instrument_constants.dart`
3. Criar arquivo `constants/filter_constants.dart`
4. Criar `models/flight_data.dart` (modelo base)
5. Criar `README.md` e `ARCHITECTURE.md`

**Entregáveis:**
- ✅ Estrutura de pastas criada
- ✅ Arquivos vazios com TODOs
- ✅ README inicial

**Critérios de Sucesso:**
- Estrutura compila sem erros
- Todos os arquivos têm header de copyright/license

---

### 🔷 FASE 2: Constants & Models (Estimativa: 20min)

**Objetivo:** Eliminar magic numbers e criar models

**Tarefas:**

**2.1 - Constants (10min)**
```dart
// instrument_constants.dart
class InstrumentConstants {
  // Horizon
  static const double horizonPitchScale = 3.0;  // pixels per degree
  static const double horizonRadius = 1.0;      // relative to container
  
  // Coordenador
  static const double coordenadorBallSensitivity = 1.0;
  static const double coordenadorBallMaxOffset = 0.3;
}

// filter_constants.dart
class FilterConstants {
  // EMA Alpha values (0-1, higher = more responsive)
  static const double alphaVelocidade = 0.15;
  static const double alphaAltitude = 0.5;
  static const double alphaHeading = 0.15;
  
  // Dead zones (minimum change to register)
  static const double deadZoneVelocidade = 0.2;  // km/h
  static const double deadZoneAltitude = 0.5;    // meters
}
```

**2.2 - Models (10min)**
```dart
// flight_data.dart
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
  
  const FlightData({...});
  
  // Factory constructors
  factory FlightData.fromJson(Map<String, dynamic> json) {...}
  Map<String, dynamic> toJson() {...}
  
  // CopyWith for immutability
  FlightData copyWith({...}) {...}
}
```

**Entregáveis:**
- ✅ Todos os magic numbers movidos para constants
- ✅ Models com immutability
- ✅ JSON serialization

**Critérios de Sucesso:**
- Zero magic numbers nos arquivos de negócio
- Models com testes unitários passando
- Documentação dartdoc completa

---

### 🔷 FASE 3: Services Refatorados (Estimativa: 30min)

**Objetivo:** Separar lógica e tornar testável

**3.1 - Smoothing Service (15min)**

**Antes (monolítico):**
```dart
class SmoothingService {
  double _smoothVelocidade = 0;
  double _smoothAltitude = 0;
  // ... 12 variáveis privadas
  
  Map<String, double> smoothData(Map<String, double> rawData) {
    // 150+ linhas de código
  }
}
```

**Depois (modular):**
```dart
// ema_filter.dart
class EMAFilter {
  double _lastValue;
  final double alpha;
  
  EMAFilter({required this.alpha, double initialValue = 0});
  
  double filter(double newValue) {
    _lastValue = alpha * newValue + (1 - alpha) * _lastValue;
    return _lastValue;
  }
}

// dead_zone_filter.dart
class DeadZoneFilter {
  final double threshold;
  
  bool shouldUpdate(double newValue, double currentValue) {
    return (newValue - currentValue).abs() >= threshold;
  }
}

// smoothing_service.dart (orquestrador)
class SmoothingService {
  final Map<String, EMAFilter> _filters;
  final Map<String, DeadZoneFilter> _deadZones;
  
  SmoothingService({
    required Map<String, FilterConfig> configs,
  }) : _filters = {...}, _deadZones = {...};
  
  FlightData smoothData(FlightData rawData) {
    // Aplica filtros de forma limpa
    return FlightData(
      velocidade: _applyFilter('velocidade', rawData.velocidade),
      altitude: _applyFilter('altitude', rawData.altitude),
      // ...
    );
  }
  
  double _applyFilter(String key, double value) {
    if (_deadZones[key]!.shouldUpdate(value, _filters[key]!.lastValue)) {
      return _filters[key]!.filter(value);
    }
    return _filters[key]!.lastValue;
  }
}
```

**3.2 - Calibration Service (10min)**
```dart
// offset_calculator.dart
class OffsetCalculator {
  static double calculateLinear(double reference, double measured) {
    return reference - measured;
  }
  
  static double calculateCircular(double reference, double measured) {
    double diff = reference - measured;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff;
  }
}

// calibration_service.dart
class CalibrationService {
  final Map<String, double> _offsets = {};
  
  void calibrate(String parameter, double reference, double measured) {
    _offsets[parameter] = parameter == 'heading'
        ? OffsetCalculator.calculateCircular(reference, measured)
        : OffsetCalculator.calculateLinear(reference, measured);
  }
  
  double applyCalibration(String parameter, double rawValue) {
    if (!_offsets.containsKey(parameter)) return rawValue;
    
    double calibrated = rawValue + _offsets[parameter]!;
    
    // Normalize circular values
    if (parameter == 'heading') {
      while (calibrated < 0) calibrated += 360;
      while (calibrated >= 360) calibrated -= 360;
    }
    
    return calibrated;
  }
}
```

**3.3 - Testes Unitários (5min)**
```dart
// smoothing_service_test.dart
void main() {
  group('SmoothingService', () {
    test('should smooth velocity correctly', () {
      final service = SmoothingService(configs: {...});
      final result = service.smoothData(FlightData(...));
      expect(result.velocidade, closeTo(expected, 0.01));
    });
    
    test('should respect dead zone', () {...});
    test('should handle first reading', () {...});
  });
}
```

**Entregáveis:**
- ✅ Services refatorados e testáveis
- ✅ Cada filtro isolado em classe própria
- ✅ Testes unitários com cobertura > 80%

**Critérios de Sucesso:**
- Services < 100 linhas cada
- Funções < 20 linhas
- Todos os testes passando

---

### 🔷 FASE 4: Widgets + Painters (Estimativa: 35min)

**Objetivo:** Separar UI de lógica de desenho

**4.1 - Artificial Horizon (15min)**

**Antes:**
```dart
// artificial_horizon.dart (220 linhas)
class ArtificialHorizon extends StatelessWidget {
  // Widget + Painter juntos
}
```

**Depois:**
```dart
// widgets/instruments/artificial_horizon_widget.dart
class ArtificialHorizonWidget extends StatelessWidget {
  final double pitch;
  final double roll;
  
  @override
  Widget build(BuildContext context) {
    return InstrumentContainer(
      title: 'HORIZONTE ARTIFICIAL',
      color: InstrumentTheme.horizonColor,
      child: CustomPaint(
        painter: ArtificialHorizonPainter(
          pitch: pitch,
          roll: roll,
          config: InstrumentConfig.horizon,
        ),
      ),
      footer: InstrumentLabel('P:${pitch.toInt()}° R:${roll.toInt()}°'),
    );
  }
}

// painters/artificial_horizon_painter.dart
class ArtificialHorizonPainter extends CustomPainter {
  final double pitch;
  final double roll;
  final HorizonConfig config;
  
  // Métodos privados organizados
  void _drawSky(Canvas canvas, Size size) {...}
  void _drawGround(Canvas canvas, Size size) {...}
  void _drawPitchScale(Canvas canvas, Size size) {...}
  void _drawAirplane(Canvas canvas, Size size) {...}
  void _drawRollMarks(Canvas canvas, Size size) {...}
}
```

**4.2 - Coordenador (15min)**
Similar ao Horizon, separar Widget + Painter

**4.3 - Common Widgets (5min)**
```dart
// widgets/common/instrument_container.dart
class InstrumentContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? footer;
  final Color color;
  
  // Centraliza formatação padrão
}
```

**Entregáveis:**
- ✅ Widgets separados dos Painters
- ✅ Widgets < 50 linhas (só UI)
- ✅ Painters com métodos privados bem divididos

**Critérios de Sucesso:**
- Zero lógica de negócio nos Widgets
- Painters com métodos < 30 linhas
- Reusabilidade de componentes

---

### 🔷 FASE 5: Documentação & Validação (Estimativa: 20min)

**Objetivo:** Garantir qualidade e transferência de conhecimento

**5.1 - Dartdoc (10min)**
```dart
/// Applies Exponential Moving Average (EMA) filtering to sensor data.
///
/// EMA is a type of infinite impulse response filter that applies weighting
/// factors which decrease exponentially. The weighting for each older datum
/// decreases exponentially, never reaching zero.
///
/// Formula: `S_t = α * Y_t + (1 - α) * S_{t-1}`
///
/// Where:
/// - `S_t` is the smoothed value at time t
/// - `Y_t` is the raw value at time t
/// - `α` is the smoothing factor (0 < α < 1)
///
/// Example:
/// ```dart
/// final filter = EMAFilter(alpha: 0.3, initialValue: 0);
/// final smoothed = filter.filter(100.5); // First smoothed value
/// ```
class EMAFilter {
  // ...
}
```

**5.2 - Architecture Diagram (5min)**
```markdown
# ARCHITECTURE.md

## Data Flow

ESP32 → WebSocket → DataStreamService → SmoothingService → CalibrationService → Widgets

## Responsabilidades

- **Models**: Estrutura de dados imutável
- **Services**: Processamento e lógica de negócio
- **Widgets**: UI declarativa (stateless quando possível)
- **Painters**: Renderização customizada
- **Constants**: Single source of truth para configurações
```

**5.3 - Validação (5min)**
- ✅ Rodar analyzer (`dart analyze`)
- ✅ Rodar formatter (`dart format .`)
- ✅ Executar testes (`flutter test`)
- ✅ Validar hot reload funcionando
- ✅ Comparar performance (usar DevTools)

**Entregáveis:**
- ✅ Dartdoc em 100% dos public members
- ✅ ARCHITECTURE.md com diagramas
- ✅ CHANGELOG.md documentando mudanças
- ✅ Todos os testes passando
- ✅ Zero warnings no analyzer

---

## 📈 CRITÉRIOS DE SUCESSO GLOBAL

### ✅ Métricas de Qualidade

| Métrica | Antes | Meta | Como Medir |
|---------|-------|------|------------|
| Linhas por arquivo | 200+ | < 150 | `cloc lib/` |
| Cobertura de testes | 0% | > 80% | `flutter test --coverage` |
| Warnings | ~5 | 0 | `dart analyze` |
| Magic numbers | ~50 | 0 | Code review manual |
| Docs públicas | ~10% | 100% | `dartdoc` + review |
| Tempo hot reload | ~3s | < 1s | DevTools |

### ✅ Validações Técnicas

1. **Performance**
   - FPS mantém > 55 em dispositivos médios
   - Rebuilds desnecessários < 5% (usar DevTools)
   - Memory leaks = 0

2. **Manutenibilidade**
   - Adicionar novo instrumento < 30min
   - Modificar filtro sem quebrar testes
   - Onboarding de dev < 2h

3. **Qualidade**
   - Analyzer score = 100/100
   - Pub.dev likes > 80/100 (se publicado)
   - Zero deprecated APIs

---

## ⚠️ RISCOS E MITIGAÇÕES

### 🔴 Risco Alto: Quebrar Funcionalidade Existente
**Mitigação:**
- Criar testes de regressão antes de refatorar
- Refatorar em branches separadas
- Deploy incremental (feature flags)

### 🟡 Risco Médio: Performance Degradar
**Mitigação:**
- Benchmark antes/depois (DevTools)
- Profile em dispositivos reais
- Cache agressivo de cálculos

### 🟢 Risco Baixo: Overengineering
**Mitigação:**
- YAGNI: só criar abstração quando necessário
- Review arquitetura a cada fase
- Manter KISS (Keep It Simple)

---

## 🎯 PRÓXIMOS PASSOS

### Após Refatoração Completa:

1. **CI/CD**
   - GitHub Actions para testes automáticos
   - Code coverage reports
   - Automated deploy

2. **Monitoring**
   - Firebase Crashlytics
   - Performance metrics
   - User analytics

3. **Features**
   - Modo offline com cache
   - Replay de voos gravados
   - Integração com APIs de meteorologia

---

## 📞 CONTATOS E RECURSOS

**Documentação:**
- [Flutter Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)

**Tools:**
- `dart analyze` - Linter
- `dart format` - Formatter
- `flutter test` - Test runner
- `dart doc` - Documentation generator

---

**Versão:** 1.0  
**Data:** 2025-11-03  
**Autor:** Equipe QFLY  
**Status:** 📋 Planejamento → 🔨 Execução