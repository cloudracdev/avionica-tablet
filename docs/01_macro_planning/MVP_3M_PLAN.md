# 📋 AVIÔNICA MVP - CHECKLIST SCRUM MASTER

**🎯 Meta:** Sistema completo 4 portais + telemetria 20Hz + live tracking + replay 2D  
**👥 Time:** Bruno (14 sem) + Davi (12 sem, inicia 01/12)  
**📅 Prazo:** 17/11/2025 → 23/02/2026 (14 semanas)

---

## 🔥 SPRINT 1-2: FUNDAÇÃO (BRUNO SOLO)

**📅 Período:** 17/11/2025 (Dom) → 30/11/2025 (Sáb) | **2 semanas**  
**👤 Dev:** Bruno solo | **📊 Capacidade:** 30 SP  
**🎯 Objetivo:** Preparar ambiente completo para Davi entrar produzindo

### ✅ ENTREGAS BRUNO (30 SP)

#### 🖥️ Backend Setup (8 SP)
- [ ] Supabase projeto criado (free tier)
- [ ] PostgreSQL schema base (15 tabelas estrutura)
- [ ] N8N Docker local rodando (docker-compose.yml)
- [ ] Redis local setup (cache prep)
- [ ] S3/Storage config (fotos prep)

#### 📱 Mobile Refactor (15 SP)
- [ ] Refactor sixpack_screen.dart (643→250 linhas)
- [ ] Separar lógica UI (widgets puros)
- [ ] SQLite estrutura (1 DB por voo schema)
- [ ] WebSocket reconnect exponential backoff
- [ ] Reduzir warnings build (28→<10)
- [ ] FlightSession model type-safe (class)

#### 🔌 ESP32 Prep (4 SP)
- [ ] Protocolo JSON documentado (~700 bytes spec)
- [ ] SSID "CODIGO-qfly-AP" validado
- [ ] Calibração automática testada
- [ ] Manual setup hardware (draft)

#### 📚 Onboarding Davi (3 SP)
- [ ] README completo (setup <2h)
- [ ] Diagramas arquitetura (Mermaid/draw.io)
- [ ] Roteiro primeiras tarefas Davi
- [ ] Repo Git estruturado (branches, .gitignore)
- [ ] CI/CD básico (GitHub Actions: lint + analyze)

### 📊 KPIs Sprint 1-2
- [ ] Davi consegue rodar projeto <2h (testar 01/12)
- [ ] Mobile compila debug + release OK
- [ ] Warnings: 28 → <10 ✅
- [ ] sixpack_screen: <250 linhas ✅
- [ ] SQLite salva mock voo offline ✅

### 📝 Notas / Bloqueios
```
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
```

**✅ Sprint Review:** ___/___/___ | **Velocity Real:** ___ SP

---

## 📱 SPRINT 3: MOBILE CORE (DUPLA)

**📅 Período:** 01/12/2025 (Dom) → 14/12/2025 (Sáb) | **2 semanas**  
**👥 Devs:** Bruno + Davi | **📊 Capacidade:** 60 SP (30+30)  
**🎯 Objetivo:** Mobile funcional offline + Backend base + Portal Gestor estrutura

### ✅ ENTREGAS BRUNO (30 SP)

#### 🎮 Sixpack Produção (12 SP)
- [ ] Artificial Horizon (UI + animação)
- [ ] Altimeter (UI + animação)
- [ ] Airspeed Indicator (UI + animação)
- [ ] Heading Compass (UI + animação)
- [ ] Turn Coordinator (UI + animação)
- [ ] Variometer VSI (UI + animação)
- [ ] Animações 60fps smooth (profiling)
- [ ] Validação ranges cada sensor

#### 📡 Telemetria ESP32 (10 SP)
- [ ] WebSocket ws://192.168.4.1:81 conexão
- [ ] Parsing JSON 20Hz (~700 bytes)
- [ ] Validação dados recebidos
- [ ] Perda pacotes <1% handling
- [ ] Logs estruturados (debug mode)

#### 💾 Persistência SQLite (8 SP)
- [ ] FlightSession model completo
- [ ] Salvar telemetria comprimida (Gzip)
- [ ] Metadata voo (data, aeronave, instrutor)
- [ ] Migrations setup
- [ ] Teste offline salvar/carregar

### ✅ ENTREGAS DAVI (30 SP)

#### 🖥️ Backend Core (18 SP)
- [ ] Supabase Auth config (4 roles: admin, gestor, instrutor, aluno)
- [ ] PostgreSQL schema completo (15 tabelas prod)
- [ ] API REST base (5 endpoints: auth, voos, users)
- [ ] S3 Storage fotos (buckets + policies)
- [ ] Redis cache setup (conexão + TTL config)

#### 🔄 N8N Workflows (8 SP)
- [ ] Workflow #1: Sync voo mobile→cloud (webhook + PostgreSQL)
- [ ] Workflow #2: Email notificações (SendGrid/Resend)
- [ ] Docker compose prod-ready
- [ ] Testes workflows locais

#### 🌐 Web Scaffold (4 SP)
- [ ] Next.js 14 + TypeScript setup
- [ ] Layout base 4 portais (header, sidebar)
- [ ] Auth páginas (login 4 perfis)
- [ ] Routing protegido (middleware)

### 📊 KPIs Sprint 3
- [ ] Mobile: Sixpack 6 instrumentos 60fps ✅
- [ ] Mobile: Conecta ESP32 mock OK ✅
- [ ] Backend: Supabase Auth funcionando ✅
- [ ] Backend: API 5 endpoints testáveis ✅
- [ ] Web: Login 4 perfis funcional ✅

### 📝 Notas / Bloqueios
```
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
```

**✅ Sprint Review:** ___/___/___ | **Velocity Real:** ___ SP

---

## 🏢 SPRINT 4: BACKEND + PORTAL GESTOR (DUPLA)

**📅 Período:** 15/12/2025 (Dom) → 28/12/2025 (Sáb) | **2 semanas**  
**👥 Devs:** Bruno + Davi | **📊 Capacidade:** 60 SP (30+30)  
**🎯 Objetivo:** Mobile features essenciais + Portal Gestor completo

### ✅ ENTREGAS BRUNO (30 SP)

#### 📋 Features Essenciais (15 SP)
- [ ] Checklist digital (5 itens críticos)
- [ ] Fotos câmera (2-4 por voo, JPEG 85%)
- [ ] Avaliação FAP (6 categorias MCA 58-3)
- [ ] Formulário completo (notas 1-5)

#### ☁️ Sync Cloud (10 SP)
- [ ] Upload voo completo WiFi/4G (API call)
- [ ] Queue offline voos pendentes (SQLite)
- [ ] Progress indicator (circular + %)
- [ ] Retry automático falhas

#### 🔐 Auth Supabase (5 SP)
- [ ] Login/logout funcional
- [ ] Session persistence (Hive)
- [ ] Protected routes (auth guard)
- [ ] Roles check (instrutor/gestor)

### ✅ ENTREGAS DAVI (30 SP)

#### 🏢 Portal Gestor CRUD (20 SP)
- [ ] CRUD Alunos (list, create, edit, delete, view)
- [ ] CRUD Instrutores (list, create, edit, delete)
- [ ] CRUD Aeronaves (list, create, edit, delete)
- [ ] Dashboard básico (cards: total alunos, instrutores, voos)
- [ ] Agenda aulas estrutura (calendar view prep)

#### 🔄 Backend API (6 SP)
- [ ] Endpoint: POST /flights (criar voo)
- [ ] Endpoint: GET /flights (listar voos)
- [ ] Endpoint: GET /flights/:id (detalhes)
- [ ] Endpoint: GET /students (listar alunos)
- [ ] Filtros básicos (date range, instrutor)

#### 🗺️ Mapa Prep (4 SP)
- [ ] Leaflet lib integração (Next.js)
- [ ] Componente mapa base
- [ ] WebSocket client prep (live tracking)
- [ ] Redis cache prep (posições)

### 📊 KPIs Sprint 4
- [ ] Mobile: Voo offline completo funcional ✅
- [ ] Mobile: Sync automático WiFi/4G OK ✅
- [ ] Portal Gestor: CRUD completo ✅
- [ ] Portal Gestor: Dashboard visualizável ✅
- [ ] Backend: 5+ endpoints funcionais ✅

### 📝 Notas / Bloqueios
```
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
```

**✅ Sprint Review:** ___/___/___ | **Velocity Real:** ___ SP

---

## 🌐 SPRINT 5: 3 PORTAIS + ESP32 REAL (DUPLA)

**📅 Período:** 29/12/2025 (Dom) → 11/01/2026 (Sáb) | **2 semanas**  
**👥 Devs:** Bruno + Davi | **📊 Capacidade:** 60 SP (30+30)  
**🎯 Objetivo:** ESP32 real funcional + Portal Instrutor + Admin + Aluno base

### ✅ ENTREGAS BRUNO (30 SP)

#### 🔌 ESP32 REAL (18 SP)
- [ ] Remover TODOS mocks WebSocket
- [ ] Testar GPS NEO-M8M (10Hz→20Hz interpolado)
- [ ] Testar Barômetro BMP180 (altitude)
- [ ] Testar Bússola HMC5883L (heading)
- [ ] Testar Acelerômetro ADXL345 (3 eixos)
- [ ] Testar Giroscópio L3G4200D (3 eixos)
- [ ] Testar IMU LSM6DS3 (6DOF)
- [ ] Testar Temperatura BMP180
- [ ] Calibração automática validação
- [ ] WiFi loss handling robusto

#### 🚗 Testes CARRO (8 SP)
- [ ] Teste 1: 10 min simulação (coleta dados)
- [ ] Teste 2: 20 min simulação (validação ranges)
- [ ] Teste 3: 30 min simulação (stress test)
- [ ] Ajustes calibração baseado testes
- [ ] Logs estruturados análise

#### 📚 Docs Hardware (4 SP)
- [ ] Manual instalação ESP32 (PDF)
- [ ] Troubleshooting comum (5 cenários)
- [ ] Fotos montagem hardware

### ✅ ENTREGAS DAVI (30 SP)

#### 👨‍✈️ Portal Instrutor (12 SP)
- [ ] Login instrutor
- [ ] Lista próprios alunos (cards)
- [ ] Histórico voos aluno (tabela)
- [ ] Ver detalhes voo (telemetria raw)
- [ ] Avaliação FAP review (6 categorias)
- [ ] Dashboard progresso aluno (horas, gráfico)

#### 📊 Portal Admin (10 SP)
- [ ] Login admin
- [ ] Dashboard métricas sistema (cards)
- [ ] CRUD aeroclubes (list, create, edit)
- [ ] Gestão usuários global (list)
- [ ] Config sistema (env vars)

#### 👨‍🎓 Portal Aluno Base (8 SP)
- [ ] Login aluno
- [ ] Ver próprios voos (lista)
- [ ] Ver detalhes voo (basic)
- [ ] Ver avaliações recebidas (cards)
- [ ] Perfil básico (nome, foto)

### 📊 KPIs Sprint 5
- [ ] ESP32: 7 sensores reais funcionais ✅
- [ ] ESP32: 3 testes carro completados ✅
- [ ] Portal Instrutor: Funcional (ver alunos + voos) ✅
- [ ] Portal Admin: Funcional (gestão básica) ✅
- [ ] Portal Aluno: Funcional (ver voos) ✅

### 📝 Notas / Bloqueios
```
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
```

**✅ Sprint Review:** ___/___/___ | **Velocity Real:** ___ SP

---

## 🎬 SPRINT 6: LIVE TRACKING + REPLAY 2D (DUPLA)

**📅 Período:** 12/01/2026 (Dom) → 25/01/2026 (Sáb) | **2 semanas**  
**👥 Devs:** Bruno + Davi | **📊 Capacidade:** 60 SP (30+30)  
**🎯 Objetivo:** Live tracking 4G funcional + Replay 2D interativo

### ✅ ENTREGAS BRUNO (30 SP)

#### 📡 Live Tracking 4G (20 SP)
- [ ] Mobile envia telemetria 4G (20Hz via HTTPS)
- [ ] Fallback WiFi→4G automático
- [ ] Queue retry failures (exponential backoff)
- [ ] Bateria tablet monitoring + alertas
- [ ] Performance profiling (battery drain)

#### 🚗 Testes CARRO (10 SP)
- [ ] Teste 4: Live tracking 4G validação
- [ ] Teste 5: Stress test bateria
- [ ] Coletar bugs P0/P1
- [ ] Documentar edge cases

### ✅ ENTREGAS DAVI (30 SP)

#### 🗺️ Mapa Live Global (15 SP)
- [ ] Portal Admin: Leaflet mapa global
- [ ] WebSocket server broadcast (Socket.io)
- [ ] Redis cache posições tempo real (TTL 10s)
- [ ] Trail GPS PostgreSQL (geometry type)
- [ ] Sixpack virtual cada avião ao vivo
- [ ] Gráficos tempo real (Chart.js)

#### 🗺️ Mapa Live Escola (5 SP)
- [ ] Portal Gestor: Leaflet mapa escola
- [ ] Filtro aviões aeroclube
- [ ] Telemetria ao vivo escola

#### 🎬 Replay 2D (10 SP)
- [ ] Portal Instrutor: Leaflet replay
- [ ] Timeline telemetria sincronizada (slider)
- [ ] Gráficos análise (altitude, velocidade)
- [ ] Portal Aluno: Replay próprios voos (reutilizar componente)
- [ ] Export CSV dados voo

### 📊 KPIs Sprint 6
- [ ] Live tracking: Admin vê aviões ao vivo ✅
- [ ] Live tracking: Gestor vê aviões escola ✅
- [ ] Replay 2D: Instrutor revê voo completo ✅
- [ ] Replay 2D: Aluno vê próprios voos ✅
- [ ] Telemetria 4G: <50 MB/hora ✅

### 📝 Notas / Bloqueios
```
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
```

**✅ Sprint Review:** ___/___/___ | **Velocity Real:** ___ SP

---

## 🔒 SPRINT 7: CIV + DEPLOY + VALIDAÇÃO (DUPLA)

**📅 Período:** 26/01/2026 (Dom) → 08/02/2026 (Sáb) | **2 semanas**  
**👥 Devs:** Bruno + Davi | **📊 Capacidade:** 60 SP (30+30)  
**🎯 Objetivo:** CIV sandbox funcional + Deploy produção + Testes completos

### ✅ ENTREGAS BRUNO (30 SP)

#### 🧪 Validação Final (15 SP)
- [ ] Testes regressão manual (10 cenários críticos)
- [ ] Edge cases (sem internet, bateria baixa, WiFi loss)
- [ ] Performance profiling (60fps garantido)
- [ ] Battery drain optimization
- [ ] Fix bugs P0 (todos)

#### 📱 Mobile Polish (10 SP)
- [ ] UX melhorias críticas
- [ ] Textos/labels revisão português
- [ ] Ícones profissionais (pack completo)
- [ ] Splash screen + logo
- [ ] Cores/tema profissional

#### 📦 APK Release (5 SP)
- [ ] Build release assinado (keystore)
- [ ] TestFlight iOS upload
- [ ] Play Store internal testing
- [ ] QR code distribuição beta

### ✅ ENTREGAS DAVI (30 SP)

#### 📜 CIV ANAC Sandbox (12 SP)
- [ ] XML schema ANAC completo (validado)
- [ ] Geração automática pós-voo
- [ ] N8N Workflow #4: CIV sandbox envio
- [ ] Retry logic exponential backoff
- [ ] Validação resposta ANAC mock
- [ ] PDF CIV geração (Puppeteer)

#### 🔒 Security Produção (8 SP)
- [ ] HTTPS everywhere (force redirect)
- [ ] Roles/permissions check ALL endpoints
- [ ] SQL injection prevention
- [ ] CORS config prod (whitelist)
- [ ] Audit logs (actions críticos)
- [ ] Rate limiting API (100 req/min)

#### 🚀 Deploy Produção (10 SP)
- [ ] Vercel web app (custom domain)
- [ ] Railway N8N + Redis (prod tier)
- [ ] Supabase prod config
- [ ] DNS config (A records, CNAME)
- [ ] SSL cert auto (Let's Encrypt)
- [ ] Env vars prod (secrets)
- [ ] Sentry crashes setup
- [ ] Uptime monitoring (5min check)

### 📊 KPIs Sprint 7
- [ ] CIV XML sandbox gerado corretamente ✅
- [ ] Deploy produção rodando OK ✅
- [ ] APK release assinado disponível ✅
- [ ] Security: HTTPS + roles OK ✅
- [ ] Zero bugs P0 abertos ✅

### 📝 Notas / Bloqueios
```
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
```

**✅ Sprint Review:** ___/___/___ | **Velocity Real:** ___ SP

---

## 📚 SPRINT 8: DOCS + TESTES LOAD (DUPLA)

**📅 Período:** 09/02/2026 (Dom) → 23/02/2026 (Seg) | **2 semanas**  
**👥 Devs:** Bruno + Davi | **📊 Capacidade:** 60 SP (30+30)  
**🎯 Objetivo:** Documentação completa + Testes load + MVP PRONTO

### ✅ ENTREGAS BRUNO (30 SP)

#### 📚 Docs Mobile (15 SP)
- [ ] Manual Instrutor (PDF 10 páginas)
- [ ] Screenshots app (30+ screens)
- [ ] Troubleshooting (10 cenários)
- [ ] FAQ (15 perguntas)
- [ ] Vídeo demo mobile (3 min)

#### 🚗 Validação Final CARRO (15 SP)
- [ ] 5 simulações completas documentadas
- [ ] Validar fluxo ponta-a-ponta (<15 min)
- [ ] Coletar métricas (bateria, latência, etc)
- [ ] Report final bugs encontrados

### ✅ ENTREGAS DAVI (30 SP)

#### 📚 Docs Portais (15 SP)
- [ ] Manual Gestor (PDF 12 páginas)
- [ ] Manual Admin (PDF 8 páginas)
- [ ] Manual Aluno (PDF 6 páginas)
- [ ] API docs (Swagger/OpenAPI)
- [ ] Vídeo onboarding (5 min)

#### 🧪 Testes Load (15 SP)
- [ ] k6 scripts: 50 users simultâneos
- [ ] k6 scripts: 100 users simultâneos
- [ ] Latência API <300ms (p95)
- [ ] WebSocket 20 conexões estável
- [ ] Otimizar queries lentas (indexes)
- [ ] Cache strategy Redis (TTL otimizado)
- [ ] Grafana dashboard final

### 📊 KPIs Sprint 8
- [ ] Docs: 4 manuais PDF prontos ✅
- [ ] Docs: 2 vídeos criados ✅
- [ ] Load tests: 100 users OK ✅
- [ ] Latência API: <300ms ✅
- [ ] Fluxo completo: <15 min ✅

### 📝 Notas / Bloqueios
```
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
```

**✅ Sprint Review:** ___/___/___ | **Velocity Real:** ___ SP

---

## 🎉 MVP PRONTO - CHECKLIST FINAL

**📅 Data GO-LIVE:** 23/02/2026 (Segunda-feira)

### ✅ SISTEMAS FUNCIONAIS

#### 📱 Mobile
- [ ] APK release assinado disponível
- [ ] Offline-first 100% funcional
- [ ] Sixpack 6 instrumentos 60fps
- [ ] Telemetria ESP32 20Hz estável
- [ ] Sync automático WiFi/4G
- [ ] Live tracking 4G enviando
- [ ] Zero crashes P0

#### 🌐 4 Portais Web
- [ ] Portal Admin funcional (deploy prod)
- [ ] Portal Gestor funcional (deploy prod)
- [ ] Portal Instrutor funcional (deploy prod)
- [ ] Portal Aluno funcional (deploy prod)
- [ ] HTTPS everywhere
- [ ] Login 4 perfis OK

#### 🗺️ Live Tracking
- [ ] Admin vê mapa global ao vivo
- [ ] Gestor vê mapa escola ao vivo
- [ ] Telemetria completa 20Hz tempo real
- [ ] WebSocket broadcast funcional

#### 🎬 Replay 2D
- [ ] Instrutor vê replay voos alunos
- [ ] Aluno vê replay próprios voos
- [ ] Timeline sincronizada
- [ ] Gráficos análise funcionais

#### 🖥️ Backend
- [ ] Supabase Auth prod rodando
- [ ] PostgreSQL prod populado
- [ ] API REST 15 endpoints OK
- [ ] WebSocket server estável
- [ ] Redis cache funcionando
- [ ] 4 workflows N8N ativos
- [ ] Monitoring ativo (Sentry + Uptime)

#### 🔌 Hardware
- [ ] 1 ESP32 montado funcional
- [ ] 7 sensores operacionais
- [ ] 5 testes carro validados
- [ ] Manual instalação pronto

#### 📜 CIV
- [ ] CIV XML sandbox funcional
- [ ] Geração automática OK
- [ ] PDF gerado corretamente

#### 📚 Docs
- [ ] 4 manuais PDF prontos
- [ ] 2 vídeos criados
- [ ] FAQ completo
- [ ] API docs disponível

### 🎯 TESTE FINAL PONTA-A-PONTA

**Executar fluxo completo e cronometrar:**

1. [ ] Gestor cadastra aluno/instrutor/aeronave (2 min)
2. [ ] Instrutor faz login app (30 seg)
3. [ ] Instrutor conecta ESP32 WiFi (1 min)
4. [ ] Instrutor faz checklist + fotos (2 min)
5. [ ] Instrutor inicia voo CARRO (0 seg)
6. [ ] Telemetria 20Hz tempo real (verificar sixpack)
7. [ ] Admin vê avião ao vivo mapa (verificar)
8. [ ] Instrutor finaliza voo (30 seg)
9. [ ] Instrutor preenche avaliação FAP (2 min)
10. [ ] Sync automático cloud (1 min)
11. [ ] CIV XML gerado sandbox (30 seg)
12. [ ] Gestor vê voo portal (30 seg)
13. [ ] Instrutor abre replay 2D (1 min)
14. [ ] Aluno vê voo + avaliação (1 min)

**⏱️ TEMPO TOTAL:** _____ minutos (meta: <15 min)

**✅ SUCESSO:** Fluxo completo sem suporte técnico

---

## 📊 VELOCITY TRACKER

| Sprint | Planejado | Realizado | Delta | Notas |
|--------|-----------|-----------|-------|-------|
| 1-2 | 30 SP | ___ SP | ___ | ________________________ |
| 3 | 60 SP | ___ SP | ___ | ________________________ |
| 4 | 60 SP | ___ SP | ___ | ________________________ |
| 5 | 60 SP | ___ SP | ___ | ________________________ |
| 6 | 60 SP | ___ SP | ___ | ________________________ |
| 7 | 60 SP | ___ SP | ___ | ________________________ |
| 8 | 60 SP | ___ SP | ___ | ________________________ |
| **TOTAL** | **390 SP** | **___ SP** | **___** | |

**Velocity Média:** ___ SP/sprint

---

## 🚨 BUGS TRACKER

| # | Prioridade | Descrição | Sprint | Status |
|---|------------|-----------|--------|--------|
| 1 | P0 | __________________ | ___ | [ ] Open [ ] Fixed |
| 2 | P0 | __________________ | ___ | [ ] Open [ ] Fixed |
| 3 | P1 | __________________ | ___ | [ ] Open [ ] Fixed |
| 4 | P1 | __________________ | ___ | [ ] Open [ ] Fixed |
| 5 | P2 | __________________ | ___ | [ ] Open [ ] Fixed |

**Meta:** Zero P0 no GO-LIVE

---

## 📞 RITUAIS

### Daily Async (Slack)
```
Frequência: Todos dias úteis
Formato: 
  ✅ Ontem: [1 linha]
  🎯 Hoje: [1 linha]
  🚨 Bloqueios: [se houver]
```

### Weekly Sync (Sexta 16h - 30 min)
```
Pauta:
  1. Sprint progress X/60 SP
  2. Velocity vs esperado
  3. Bugs P0/P1 abertos
  4. Wins semana
  5. Ajustes próxima semana
```

### Sprint Review (Último dia sprint - 1h)
```
Pauta:
  1. Demo funcionalidades prontas
  2. Completado vs planejado
  3. O que não deu (honest postmortem)
  4. Ajustes backlog
  5. Velocity real registrar
  6. Foco próximo sprint
```

---

**📊 ~112.000 tokens restantes** 🎯