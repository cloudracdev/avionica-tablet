# TECH STACK COMPLETO - Sistema Aviônica

**Stack:** Full-Stack IoT + Cloud + Mobile + Web  
**Decisões:** Baseadas em maturidade, comunidade, e curva de aprendizado

---

## 📱 APP MOBILE (TABLET)

### Flutter 3.16+
**Por quê:** Cross-platform (Android + iOS), performance nativa, hot reload

```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.0
  provider: ^6.1.0
  
  # Networking
  dio: ^5.4.0
  web_socket_channel: ^2.4.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  isar: ^3.1.0  # Alternativa performática
  
  # Maps & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  
  # Permissions
  permission_handler: ^11.1.0
  
  # Connectivity
  connectivity_plus: ^5.0.2
  
  # Utils
  intl: ^0.18.1
  shared_preferences: ^2.2.2
```

---

## 🖥️ WEB APP

### Next.js 14 (React)
**Por quê:** SSR, SEO, App Router, TypeScript

```json
{
  "dependencies": {
    "next": "14.0.4",
    "react": "^18.2.0",
    "typescript": "^5.3.0",
    
    "# State Management": "",
    "@reduxjs/toolkit": "^2.0.0",
    "redux-persist": "^6.0.0",
    
    "# UI": "",
    "tailwindcss": "^3.4.0",
    "@radix-ui/react-*": "*",
    "shadcn/ui": "*",
    
    "# Data Fetching": "",
    "@tanstack/react-query": "^5.0.0",
    "axios": "^1.6.0",
    
    "# Maps": "",
    "mapbox-gl": "^3.0.0",
    "react-map-gl": "^7.1.0",
    
    "# Charts": "",
    "recharts": "^2.10.0",
    
    "# Forms": "",
    "react-hook-form": "^7.49.0",
    "zod": "^3.22.0"
  }
}
```

---

## ⚙️ BACKEND

### Node.js 20 LTS + Express
**Por quê:** Comunidade gigante, assíncrono, fácil integração

```json
{
  "dependencies": {
    "express": "^4.18.0",
    "typescript": "^5.3.0",
    "@types/node": "^20.0.0",
    
    "# Auth": "",
    "jsonwebtoken": "^9.0.0",
    "bcryptjs": "^2.4.3",
    "passport": "^0.7.0",
    "passport-jwt": "^4.0.0",
    
    "# Database": "",
    "pg": "^8.11.0",
    "typeorm": "^0.3.0",
    
    "# Cache": "",
    "redis": "^4.6.0",
    "ioredis": "^5.3.0",
    
    "# Validation": "",
    "joi": "^17.11.0",
    "class-validator": "^0.14.0",
    
    "# WebSocket": "",
    "socket.io": "^4.6.0",
    
    "# Utils": "",
    "dotenv": "^16.3.0",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "morgan": "^1.10.0"
  }
}
```

**Alternativa:** NestJS (mais opinativo, TypeScript-first)

---

## 🗄️ DATABASES

### PostgreSQL 15
**Por quê:** SQL robusto, JSONB, GIS (PostGIS)

```sql
-- Schema exemplo
CREATE TABLE flights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL,
  instructor_id UUID NOT NULL,
  aircraft_id UUID NOT NULL,
  planned_route JSONB,
  actual_route JSONB,
  started_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE telemetry (
  id BIGSERIAL PRIMARY KEY,
  flight_id UUID NOT NULL,
  timestamp TIMESTAMPTZ NOT NULL,
  data JSONB NOT NULL,  -- {lat, lng, alt, pitch, roll, ...}
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para queries rápidas
CREATE INDEX idx_telemetry_flight_time 
ON telemetry(flight_id, timestamp DESC);
```

### Redis 7
**Para:** Cache, sessions, rate limiting, pub/sub

```js
// Uso típico
await redis.set(`flight:${id}:cache`, JSON.stringify(data), 'EX', 300);
await redis.publish(`flight:${id}:updates`, JSON.stringify(telemetry));
```

---

## ☁️ CLOUD & INFRA

### AWS (Recomendado para produção)

```
├─ EC2 / ECS Fargate   → Backend APIs
├─ RDS PostgreSQL      → Database principal
├─ ElastiCache Redis   → Cache & Sessions
├─ S3                  → Telemetry files, vídeos
├─ CloudFront          → CDN
├─ Route 53            → DNS
├─ ALB                 → Load Balancer
├─ SES                 → Emails
└─ CloudWatch          → Monitoring
```

**Custo estimado:** R$ 2k-5k/mês (MVP)

### Alternativa: Firebase (Mais fácil para MVP)

```
├─ Firestore           → NoSQL (em vez de Postgres)
├─ Cloud Functions     → Backend serverless
├─ Storage             → Files
├─ Hosting             → Frontend
├─ Auth                → Autenticação pronta
└─ Analytics           → Métricas
```

**Custo:** R$ 500-1k/mês (MVP)

---

## 🤖 HARDWARE (SPU)

### Opção A: Arduino Nano 33 IoT Sense (MVP)

```cpp
Hardware:
├─ CPU: ARM Cortex M0+ @ 48MHz
├─ RAM: 32KB
├─ Flash: 256KB
├─ WiFi: Nina W102
├─ Bluetooth: BLE 5.0
├─ Sensores built-in:
│  ├─ LSM9DS1 (IMU: accel + gyro + mag)
│  ├─ LPS22HB (Barômetro)
│  ├─ HTS221 (Temp + Humidity)
│  └─ APDS9960 (Proximity)
├─ GPS: Módulo externo (NEO-6M)
└─ 4G: Módulo externo (SIM800L)

Custo: R$ 300 (sem GPS/4G) + R$ 150 extras
```

### Opção B: ESP32-S3 (Melhor custo-benefício)

```cpp
Hardware:
├─ CPU: Xtensa dual-core @ 240MHz
├─ RAM: 512KB
├─ Flash: 8MB
├─ WiFi: 802.11 b/g/n
├─ Bluetooth: BLE 5.0
├─ Sensores: Externos via I2C/SPI
│  ├─ MPU6050 (IMU)
│  ├─ BMP280 (Barômetro)
│  ├─ HMC5883L (Magnetômetro)
│  └─ NEO-6M (GPS)
└─ 4G: SIM800L

Custo: R$ 80 + R$ 150 sensores = R$ 230 total
```

**Recomendação:** ESP32-S3 (mais barato, mais poderoso)

---

## 🎓 EAD

### Moodle 4.x LTS
**Por quê:** Open-source, usado por milhões, extensível

```php
// Stack Moodle
├─ PHP 8.1
├─ MySQL 8.0 / PostgreSQL 15
├─ Apache 2.4 / Nginx
├─ Redis (cache)
└─ Plugins custom:
   ├─ local_avionica (integração)
   └─ mod_facerecognition (IA)
```

### Plugins Necessários:
```
├─ WooCommerce Integration (e-commerce)
├─ BigBlueButton (videoconferência)
├─ H5P (conteúdo interativo)
└─ Certificate (certificados)
```

---

## 🛒 E-COMMERCE

### WooCommerce (WordPress)
**Por quê:** Integra nativamente com Moodle

```php
Stack:
├─ WordPress 6.x
├─ WooCommerce 8.x
├─ LearnDash / LearnPress (LMS)
└─ Payment Gateways:
   ├─ Stripe
   ├─ PagSeguro
   └─ Mercado Pago
```

---

## 🔧 DEVOPS

### CI/CD: GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy Backend
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm test
      - run: docker build -t api .
      - run: docker push ecr/api
      - run: aws ecs update-service
```

### Containerização: Docker

```dockerfile
# Backend Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

### Orquestração: Kubernetes (Futuro)

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    spec:
      containers:
      - name: api
        image: avionica/api:latest
        ports:
        - containerPort: 3000
```

---

## 📊 MONITORING

### Observabilidade

```
├─ Logs: ELK Stack (Elasticsearch, Logstash, Kibana)
├─ Metrics: Prometheus + Grafana
├─ APM: New Relic / Datadog
├─ Errors: Sentry
└─ Uptime: UptimeRobot
```

---

## 🧪 TESTES

### Backend (Node.js)
```json
{
  "devDependencies": {
    "jest": "^29.7.0",
    "supertest": "^6.3.0",
    "@types/jest": "^29.5.0"
  }
}
```

### Frontend (React)
```json
{
  "devDependencies": {
    "@testing-library/react": "^14.0.0",
    "@testing-library/jest-dom": "^6.1.0",
    "vitest": "^1.0.0"
  }
}
```

### E2E
```json
{
  "devDependencies": {
    "playwright": "^1.40.0",
    "cypress": "^13.0.0"
  }
}
```

---

## 🔐 SEGURANÇA

### Autenticação
```
JWT (Access + Refresh Tokens)
├─ Access: 15 min (short-lived)
└─ Refresh: 7 days (rotate on use)
```

### Criptografia
```
├─ Senhas: bcrypt (cost factor 10)
├─ Dados: AES-256
└─ Conexões: TLS 1.3
```

### Rate Limiting
```js
// express-rate-limit
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 100 // limit each IP
});
app.use('/api/', limiter);
```

---

## 📚 DOCUMENTAÇÃO

### API: Swagger/OpenAPI

```yaml
openapi: 3.0.0
info:
  title: Avionica API
  version: 1.0.0
paths:
  /flights:
    get:
      summary: List flights
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
```

### Código: JSDoc / TypeDoc

```typescript
/**
 * Creates a new flight record
 * @param data - Flight creation data
 * @returns Created flight with ID
 * @throws {ValidationError} If data is invalid
 */
async function createFlight(data: CreateFlightDto): Promise<Flight> {
  // ...
}
```

---

## 💻 AMBIENTES DE DESENVOLVIMENTO

### Desenvolvimento Local

```bash
# Backend
cd backend
npm install
npm run dev  # localhost:3000

# Frontend
cd frontend
npm install
npm run dev  # localhost:3001

# Database
docker-compose up postgres redis
```

### Ambientes Cloud

```
├─ dev.avionica.com      → Desenvolvimento (auto-deploy)
├─ staging.avionica.com  → Homologação (manual)
└─ avionica.com          → Produção (manual + approval)
```

---

## 🎯 DECISÕES FINAIS (STACK MVP)

```
✅ ESCOLHIDO PARA MVP:

MOBILE:    Flutter
WEB:       Next.js 14 (React + TypeScript)
BACKEND:   Node.js 20 + Express + TypeScript
DATABASE:  PostgreSQL 15
CACHE:     Redis 7
STORAGE:   AWS S3 (ou Firebase Storage)
HOSTING:   AWS ECS (ou Vercel + Heroku)
HARDWARE:  ESP32-S3 + sensores
CI/CD:     GitHub Actions
MONITORING: Sentry + CloudWatch
```

**Por quê estas escolhas?**
- ✅ Comunidade gigante (fácil achar ajuda)
- ✅ Você já conhece (Flutter, Node.js)
- ✅ Custo-benefício (open-source, cloud escalável)
- ✅ Performance (async, compilado)
- ✅ Produtividade (hot reload, TypeScript, ferramental)

---

## 🚀 SETUP INICIAL (TUTORIAL)

### 1. Backend Setup

```bash
# Criar projeto
mkdir avionica-backend && cd avionica-backend
npm init -y
npm install express typescript @types/node @types/express
npm install -D ts-node-dev

# tsconfig.json
npx tsc --init

# src/index.ts
import express from 'express';
const app = express();
app.get('/health', (req, res) => res.json({ok: true}));
app.listen(3000, () => console.log('API running on :3000'));

# Rodar
npm run dev
```

### 2. Frontend Setup

```bash
# Criar projeto Next.js
npx create-next-app@latest avionica-web --typescript --tailwind

cd avionica-web
npm run dev
```

### 3. Mobile Setup

```bash
# Criar projeto Flutter
flutter create avionica_app
cd avionica_app

# Rodar
flutter run
```

---

**Criado em:** 04/11/2025  
**Versão:** 1.0