# 🚀 SETUP DEV GUIDE - QFLY Aviônica

**Versão:** 1.0  
**Data:** 28/11/2025  
**Plataforma:** macOS / Windows / Linux

---

## 📋 ÍNDICE

1. [Pré-Requisitos](#1-pré-requisitos)
2. [Instalação Flutter](#2-instalação-flutter)
3. [Clonar Projeto](#3-clonar-projeto)
4. [Configurar Ambiente](#4-configurar-ambiente)
5. [Configurar Android](#5-configurar-android)
6. [Configurar iOS](#6-configurar-ios)
7. [VS Code Setup](#7-vs-code-setup)
8. [Rodar Testes](#8-rodar-testes)
9. [Rodar Aplicativo](#9-rodar-aplicativo)
10. [Conectar ESP32](#10-conectar-esp32)
11. [Git Workflow](#11-git-workflow)
12. [Build Produção](#12-build-produção)
13. [Troubleshooting](#13-troubleshooting)

---

## 1️⃣ PRÉ-REQUISITOS

### Ferramentas Obrigatórias

| Ferramenta | Versão Mínima | Download |
|------------|---------------|----------|
| Flutter | 3.35+ | https://flutter.dev/docs/get-started/install |
| Dart | 3.9+ | (incluso no Flutter) |
| Git | 2.40+ | https://git-scm.com |
| Android Studio | 2024+ | https://developer.android.com/studio |
| Xcode (macOS) | 15+ | App Store |

### Verificar Instalação
```bash
flutter --version
# Flutter 3.35.6 • channel stable

dart --version
# Dart SDK version: 3.9.2

git --version
# git version 2.40+

adb --version
# Android Debug Bridge version 1.0.41
```

---

## 2️⃣ INSTALAÇÃO FLUTTER

### macOS
```bash
# Homebrew
brew install flutter

# Ou manual
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/development/flutter/bin"
```

### Verificar
```bash
flutter doctor
```

✅ Todos items devem estar verdes (exceto opcionais como Chrome, Visual Studio).

---

## 3️⃣ CLONAR PROJETO
```bash
git clone https://github.com/[seu-repo]/qfly-avionica.git
cd qfly-avionica/tablet
```

### Instalar Dependências
```bash
flutter pub get
```

### Dependências do Projeto
```yaml
# 🔄 State Management
flutter_riverpod: ^2.4.9

# 🌐 Network
web_socket_channel: ^2.4.0
http: ^1.1.2

# 📊 Data
sqflite: ^2.4.2
hive: ^2.2.3
hive_flutter: ^1.1.0
supabase_flutter: ^2.10.3

# 🧭 Navigation
go_router: ^17.0.0

# 🔐 Environment
flutter_dotenv: ^6.0.0
```

---

## 4️⃣ CONFIGURAR AMBIENTE

### 4.1 Criar arquivo .env
```bash
cp .env.example .env
```

### 4.2 Editar .env
```env
SUPABASE_URL=https://pqbwhulxexwignymqpfv.supabase.co
SUPABASE_ANON_KEY=sua-anon-key-aqui
```

### 4.3 Obter credenciais Supabase

1. Acesse https://app.supabase.com
2. Selecione projeto QFLY
3. Settings → API
4. Copie `URL` e `anon key`

⚠️ **IMPORTANTE:** O arquivo `.env` já está no `.gitignore`. NUNCA commitar secrets!

### 4.4 Verificar .gitignore
```bash
cat .gitignore | grep env
# Deve mostrar:
# .env
# .env.*
# !.env.example
```

---

## 5️⃣ CONFIGURAR ANDROID

### 5.1 Android Studio Setup

1. Abra Android Studio
2. SDK Manager → SDK Platforms
   - ✅ Android 14 (API 34)
   - ✅ Android 13 (API 33)
3. SDK Manager → SDK Tools
   - ✅ Android SDK Build-Tools
   - ✅ Android SDK Command-line Tools
   - ✅ Android Emulator
   - ✅ Android SDK Platform-Tools

### 5.2 Configuração Atual (build.gradle.kts)
```kotlin
android {
    namespace = "com.example.tablet"
    compileSdk = flutter.compileSdkVersion
    
    defaultConfig {
        applicationId = "com.example.tablet"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}
```

⚠️ **PRODUÇÃO:** Alterar `applicationId` para `com.qfly.avionica`

### 5.3 Conectar Device Android
```bash
# Ativar no device:
# Configurações → Sobre → Tocar 7x em "Número da versão"
# Configurações → Opções do desenvolvedor → Depuração USB: ON

# Verificar conexão
adb devices
# R9XN6002LTE    device

flutter devices
```

---

## 6️⃣ CONFIGURAR iOS

### 6.1 Xcode Setup

1. Instalar Xcode da App Store
2. Aceitar licença:
```bash
sudo xcodebuild -license accept
```

3. Instalar command line tools:
```bash
xcode-select --install
```

### 6.2 CocoaPods
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### 6.3 Configuração Atual

**Info.plist:**
```xml
<key>CFBundleDisplayName</key>
<string>QFLY</string>

<key>CFBundleName</key>
<string>QFLY</string>
```

**Podfile:**
```ruby
platform :ios, '13.0'  # iOS mínimo
```

### 6.4 Signing (Desenvolvimento)

1. Abra `ios/Runner.xcworkspace` no Xcode
2. Runner → Signing & Capabilities
3. Team: Selecione sua Apple ID
4. Bundle Identifier: `com.qfly.avionica`

### 6.5 Confiar Desenvolvedor no iPhone

1. Conecte iPhone
2. Xcode → Window → Devices and Simulators
3. No iPhone: Ajustes → Geral → Gerenciamento de Dispositivo → Confiar

---

## 7️⃣ VS CODE SETUP

### 7.1 Extensions Obrigatórias

| Extension | ID |
|-----------|-----|
| Flutter | Dart-Code.flutter |
| Dart | Dart-Code.dart-code |
| Error Lens | usernamehw.errorlens |

### 7.2 Extensions Recomendadas

| Extension | ID |
|-----------|-----|
| GitLens | eamodio.gitlens |
| Material Icon Theme | PKief.material-icon-theme |
| Bracket Pair Colorizer | CoenraadS.bracket-pair-colorizer-2 |

### 7.3 settings.json
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.rulers": [80]
  }
}
```

---

## 8️⃣ RODAR TESTES

### 8.1 Todos os Testes
```bash
flutter test
```

### 8.2 Teste Específico
```bash
flutter test test/unit/database/flight_database_service_test.dart
```

### 8.3 Com Cobertura
```bash
flutter test --coverage
# Gera: coverage/lcov.info
```

### 8.4 Verificar Warnings
```bash
flutter analyze
# 0 issues found
```

### 8.5 Configuração Testes (dart_test.yaml)
```yaml
# Evita conflitos de I/O em testes de database
concurrency: 1
```

### Métricas Atuais

| Métrica | Valor |
|---------|-------|
| Testes | 237 |
| Warnings | 0 |
| Cobertura | 63.7% |

---

## 9️⃣ RODAR APLICATIVO

### 9.1 Listar Devices
```bash
flutter devices
```

### 9.2 Android
```bash
flutter run -d <device-id>
# Ex: flutter run -d R9XN6002LTE
```

### 9.3 iOS
```bash
cd ios && pod install && cd ..
flutter run -d iphone
```

### 9.4 Chrome (Debug Rápido)
```bash
flutter run -d chrome
```

### 9.5 Credenciais Teste

| Campo | Valor |
|-------|-------|
| Email | `instrutor@teste.com` |
| Senha | `123456` |

---

## 🔟 CONECTAR ESP32

### 10.1 SSID Padrão
```
SSID: CODIGO-qfly-AP
IP: 192.168.4.1
WebSocket: ws://192.168.4.1:81
```

### 10.2 Fluxo Conexão

1. ESP32 ligado → Cria WiFi Access Point
2. Tablet conecta no WiFi `CODIGO-qfly-AP`
3. App conecta WebSocket `ws://192.168.4.1:81`
4. ESP32 envia telemetria 20Hz (JSON)

### 10.3 JSON Telemetria
```json
{
  "timestamp": 1730905820123,
  "seq": 1245,
  "gps": {
    "lat": -25.4284,
    "lng": -49.2733,
    "alt_msl": 850.5,
    "speed_kts": 85.2
  },
  "attitude": {
    "pitch": -2.5,
    "roll": 5.0,
    "yaw": 120
  }
}
```

### 10.4 Modo Mock (Sem ESP32)

O app tem `mock_mode_provider.dart` para testar sem hardware.

---

## 1️⃣1️⃣ GIT WORKFLOW

### 11.1 Branches

| Branch | Uso |
|--------|-----|
| `main` | Produção estável |
| `develop` | Desenvolvimento |
| `feature/*` | Novas features |
| `fix/*` | Correções |

### 11.2 Fluxo
```bash
# Nova feature
git checkout develop
git pull
git checkout -b feature/nome-feature

# Trabalhar...
git add -A
git commit -m "feat: descrição"

# Push
git push -u origin feature/nome-feature

# PR → develop → main
```

### 11.3 Commit Convention
```
feat: nova funcionalidade
fix: correção de bug
docs: documentação
refactor: refatoração
test: testes
chore: manutenção
```

---

## 1️⃣2️⃣ BUILD PRODUÇÃO

### 12.1 Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 12.2 Android Bundle (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### 12.3 iOS (App Store)
```bash
flutter build ios --release
# Depois: Xcode → Product → Archive
```

### ⚠️ Antes de Produção

- [ ] Alterar `applicationId` (Android)
- [ ] Configurar signing key (Android)
- [ ] Configurar App Store Connect (iOS)
- [ ] Alterar .env para produção

---

## 1️⃣3️⃣ TROUBLESHOOTING

### Flutter Travando
```bash
killall -9 dart
killall -9 flutter
flutter clean
flutter pub get
```

### Android Não Aparece
```bash
adb kill-server
adb start-server
adb devices
```

Se mostrar `unauthorized`:
1. No device: popup "Permitir depuração USB?"
2. Marcar "Sempre permitir"
3. Tocar "OK"

### iOS CocoaPods Erro
```bash
cd ios
pod deintegrate
pod install --repo-update
cd ..
```

### iOS Sandbox Error
```bash
cd ios
pod install
cd ..
flutter run -d iphone
```

### Testes Falhando (SQLite)
```bash
# Rodar com concurrency=1
flutter test --concurrency=1

# Ou verificar dart_test.yaml
cat dart_test.yaml
```

### .env Não Carrega
```bash
# Verificar se .env existe na raiz
ls -la .env

# Verificar assets no pubspec.yaml
cat pubspec.yaml | grep -A2 "assets:"
# Deve mostrar:
#   assets:
#     - .env
```

### Build Muito Lento
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📁 ESTRUTURA DO PROJETO
```
tablet/
├── android/                # Config Android
│   └── app/
│       └── build.gradle.kts
├── ios/                    # Config iOS
│   ├── Podfile
│   └── Runner/
│       └── Info.plist
├── lib/                    # Código fonte
│   ├── core/               # Config, constants, utils
│   ├── data/               # Database, repositories
│   ├── models/             # Entidades
│   ├── providers/          # State (Riverpod)
│   ├── screens/            # Telas
│   ├── services/           # Lógica de negócio
│   ├── widgets/            # Componentes UI
│   └── main.dart           # Entry point
├── test/                   # Testes unitários
├── docs/                   # Documentação
├── .env                    # Secrets (NÃO COMMITAR)
├── .env.example            # Template
├── .gitignore              # Arquivos ignorados
├── pubspec.yaml            # Dependências
└── dart_test.yaml          # Config testes (concurrency: 1)
```

---

## 🔗 LINKS ÚTEIS

| Recurso | Link |
|---------|------|
| Flutter Docs | https://docs.flutter.dev |
| Riverpod | https://riverpod.dev |
| Supabase | https://supabase.com/docs |
| GoRouter | https://pub.dev/packages/go_router |
| Projeto Supabase | https://app.supabase.com |

---

## 📞 DOCUMENTAÇÃO RELACIONADA

| Doc | Descrição |
|-----|-----------|
| `ARCHITECTURE_2025-11-28.md` | Arquitetura do projeto |
| `API_BACKEND_N8N_2025-11-28.md` | API N8N Workflows |
| `SYSTEM_OVERVIEW_V3.md` | Visão geral sistema |

---

**Última atualização:** 28/11/2025
