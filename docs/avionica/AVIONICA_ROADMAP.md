# ROADMAP & MVP - Sistema Aviônica

**Estratégia:** Desenvolvimento Iterativo em Fases  
**Objetivo:** Lançar MVP em 6 meses, sistema completo em 24 meses

---

## 🎯 DEFINIÇÃO DE MVP (Minimum Viable Product)

### O que DEVE estar no MVP:

```
✅ HARDWARE
   └─ SPU funcional (versão 1.0)
      ├─ GPS + IMU + Barômetro
      ├─ WiFi (4G opcional)
      └─ JSON over WebSocket

✅ APP TABLET
   └─ Sixpack completo
   └─ Plano de voo básico
   └─ Debriefing simples
   └─ Offline-first

✅ BACKEND
   └─ API REST básica
   └─ Auth JWT
   └─ PostgreSQL
   └─ Armazenamento telemetria

✅ WEB APP
   └─ Login + Dashboard
   └─ Monitoramento 1 aeronave
   └─ Histórico de voos
   └─ Relatórios básicos

❌ NÃO NO MVP
   ✗ EAD (Moodle)
   ✗ E-commerce
   ✗ Integração DETRAN
   ✗ Áudio/Vídeo
   ✗ Multi-aeronave simultâneo
```

### MVP = 30% do Sistema Completo

**Foco:** Provar que funciona com 1 aeroclube piloto.

---

## 📅 ROADMAP DETALHADO

### FASE 0: PLANEJAMENTO (1 MÊS) ✅ VOCÊ ESTÁ AQUI

**Objetivo:** Documentação completa antes de codar

**Entregas:**
- ✅ Visão geral
- ✅ Arquitetura técnica
- ✅ Roadmap
- ✅ Especificações de cada módulo
- ✅ Estimativas de tempo/custo
- ✅ Stack tecnológico definido

**Time:** 1 pessoa (você + Claude)  
**Status:** EM ANDAMENTO

---

### FASE 1: MVP HARDWARE (2 MESES)

**Sprint 1.1: SPU Protótipo (3 semanas)**
- Escolher Arduino/ESP32 definitivo
- Integrar sensores (GPS, IMU, Baro)
- Firmware básico (coleta + JSON)
- Teste em bancada

**Sprint 1.2: Comunicação (3 semanas)**
- WebSocket client
- WiFi AP mode
- Protocolo de dados definido
- Teste de streaming

**Sprint 1.3: Case + Instalação (2 semanas)**
- Design case 3D
- Documentação de instalação
- Teste em aeronave real (1º voo)

**Entrega:**
- SPU v1.0 funcional
- Instalado em 1 aeronave
- Streaming telemetria funcionando

**Time:**
- 1 embedded dev (C++)
- 1 eletrônico (PCB)

---

### FASE 2: MVP APP TABLET (2 MESES)

**Sprint 2.1: Setup + Sixpack (3 semanas)**
```
Reutilizar QFLY atual:
├─ Refatorar sixpack_screen (já documentado)
├─ Conectar ao SPU via WebSocket
└─ Testar com dados reais
```

**Sprint 2.2: Plano de Voo (3 semanas)**
- Tela de criação de voo
- Form: origem, destino, rota
- Integração com sixpack
- Salvar localmente (Hive)

**Sprint 2.3: Debriefing (2 semanas)**
- Tela de avaliação
- Estatísticas do voo
- Notas + comentários
- Enviar para backend

**Entrega:**
- App Tablet v1.0 (MVP)
- Testado por 1 instrutor real
- Dados salvos local + cloud

**Time:**
- 2 Flutter devs (você + 1)

---

### FASE 3: MVP BACKEND (1.5 MÊS)

**Sprint 3.1: Setup + Auth (2 semanas)**
- Setup Node.js + Express
- PostgreSQL schema
- JWT auth
- Deploy AWS/Heroku

**Sprint 3.2: API Voos (2 semanas)**
- CRUD voos
- Telemetry endpoint (bulk insert)
- WebSocket real-time (opcional MVP)

**Sprint 3.3: API Usuários (2 semanas)**
- CRUD alunos/instrutores
- Histórico de voos
- Estatísticas básicas

**Entrega:**
- Backend MVP funcionando
- API documentada (Swagger)
- Deploy em produção

**Time:**
- 1 backend dev (Node.js)
- 1 DevOps (part-time)

---

### FASE 4: MVP WEB APP (1.5 MÊS)

**Sprint 4.1: Setup + Auth (1 semana)**
- Next.js project
- Login/Register
- Layout base

**Sprint 4.2: Dashboard (2 semanas)**
- Mapa com 1 aeronave
- Sixpack display (reutilizar Painters Flutter → Web)
- Lista de voos

**Sprint 4.3: Gestão Básica (3 semanas)**
- CRUD alunos/instrutores
- Agenda de voos
- Relatórios simples

**Entrega:**
- Web App MVP
- Usado por gestor do aeroclube
- Deploy em produção

**Time:**
- 2 frontend devs (React/Next.js)

---

### FASE 5: TESTES & LANÇAMENTO MVP (1 MÊS)

**Atividades:**
- Testes integrados (E2E)
- Correção de bugs críticos
- Documentação usuário
- Treinamento aeroclube piloto
- Lançamento oficial MVP

**Entrega:**
- Sistema MVP completo
- 1 aeroclube usando em produção
- Feedback coletado

**Time:** Todos

---

## 📊 RESUMO FASE MVP

```
TOTAL MVP: 6 MESES

┌────────────────────────────────────────────┐
│  Mês 1: Planejamento                       │
│  Mês 2-3: Hardware SPU                     │
│  Mês 3-4: App Tablet                       │
│  Mês 4-5: Backend                          │
│  Mês 5-6: Web App                          │
│  Mês 6: Testes + Lançamento                │
└────────────────────────────────────────────┘

TIME NECESSÁRIO (MVP):
├─ 1 Embedded dev (2 meses)
├─ 2 Flutter devs (2 meses)
├─ 1 Backend dev (1.5 mês)
├─ 2 Frontend devs (1.5 mês)
└─ 1 DevOps (part-time)

CUSTO ESTIMADO: R$ 180k - R$ 250k
```

---

## 🚀 PÓS-MVP: SISTEMA COMPLETO (18 MESES)

### FASE 6: HARDWARE V2 (3 MESES)
- Áudio + Vídeo
- 4G integrado
- PCB profissional
- Case final
- Certificação ANAC

### FASE 7: EAD (4 MESES)
- Setup Moodle
- Plugin integração
- Reconhecimento facial
- 10 cursos criados
- Mobile app Moodle

### FASE 8: E-COMMERCE (2 MESES)
- WooCommerce + Moodle
- Gateway pagamento
- Carrinho + Checkout
- Sistema de créditos

### FASE 9: GESTÃO AVANÇADA (3 MESES)
- Gestão financeira completa
- Relatórios regulatórios
- Multi-aeroclube
- Dashboard avançado
- BI/Analytics

### FASE 10: INTEGRAÇÃO DETRAN (3 MESES)
- API DETRAN (se disponível)
- Exames teóricos remoto
- Agendamento prático
- FreeCFC (app Uber-like)

### FASE 11: ESCALABILIDADE (3 MESES)
- Microserviços completo
- Kubernetes
- Monitoramento avançado
- Performance tuning
- Multi-região

---

## 📊 RESUMO COMPLETO

```
FASE 0-5:  MVP (6 meses)         → 1 aeroclube
FASE 6-11: Completo (18 meses)   → Escala nacional

TOTAL: 24 MESES (2 ANOS)

TIME FINAL NECESSÁRIO:
├─ 2 Embedded devs
├─ 4 Flutter devs
├─ 3 Backend devs
├─ 4 Frontend devs
├─ 2 DevOps
├─ 1 QA
├─ 1 Product Manager
└─ 1 Designer

CUSTO TOTAL ESTIMADO: R$ 1.5M - R$ 2M
```

---

## 🎯 ESTRATÉGIA DE VALIDAÇÃO

### MVP (6 meses):
**Validar:** Tecnologia funciona?
**Com:** 1 aeroclube piloto (50-100 alunos)
**Métrica:** 80% dos voos registrados com sucesso

### V1.0 (12 meses):
**Validar:** Produto-mercado fit?
**Com:** 5-10 aeroclubes (500-1000 alunos)
**Métrica:** NPS > 50, Churn < 10%

### V2.0 (24 meses):
**Validar:** Escala?
**Com:** 50+ aeroclubes (5000+ alunos)
**Métrica:** Break-even, CAC < LTV

---

## 💰 MODELO DE RECEITA (Gradual)

### MVP (Meses 0-6):
```
Receita: R$ 0 (desenvolvimento)
Custo: R$ 200k
Funding: Investimento seed
```

### V1.0 (Meses 7-12):
```
Receita: 
├─ 10 aeroclubes × R$ 10k (hardware) = R$ 100k
└─ 10 × R$ 500/mês × 6 meses (SaaS) = R$ 30k
Total: R$ 130k

Custo: R$ 300k (time expandido)
Burn rate: -R$ 170k
```

### V2.0 (Meses 13-24):
```
Receita:
├─ 50 aeroclubes × R$ 10k = R$ 500k
├─ 50 × R$ 500/mês × 12 = R$ 300k
└─ E-commerce comissão = R$ 50k
Total: R$ 850k

Custo: R$ 800k
Lucro: +R$ 50k (break-even!)
```

---

## 🎯 DECISÃO: POR ONDE COMEÇAR?

### OPÇÃO A: MVP COMPLETO (6 MESES)
**Prós:**
- ✅ Valida tudo junto
- ✅ Impressiona investidores
- ✅ Sistema funcional end-to-end

**Contras:**
- ❌ 6 meses sem receita
- ❌ Time grande necessário
- ❌ Risco alto (e se não funcionar?)

### OPÇÃO B: INCREMENTOS (3+3+6 MESES)
**Etapa 1 (3 meses):** Hardware + App Tablet  
**Etapa 2 (3 meses):** Backend + Web básico  
**Etapa 3 (6 meses):** Refinamento + Escala  

**Prós:**
- ✅ Validação mais rápida (3 meses)
- ✅ Time menor inicial
- ✅ Pode pivotar cedo

**Contras:**
- ⚠️ Menos impressionante
- ⚠️ Integração depois pode ser difícil

---

## 🎯 RECOMENDAÇÃO FINAL

### START: FASE 1 (HARDWARE) IMEDIATAMENTE

**Por quê?**
1. Hardware é o **diferencial** (ninguém tem)
2. Hardware demora mais (supply chain)
3. App Tablet (QFLY) já está 70% pronto
4. Backend/Web são commodities (rápidos)

**Plano:**
```
PARALELO (3 MESES):
├─ Track 1: Hardware SPU (você + embedded dev)
└─ Track 2: Refatorar QFLY (você)

MÊS 4-6:
└─ Backend + Web (contratar devs)

MÊS 6:
└─ MVP COMPLETO!
```

---

## ✅ PRÓXIMOS PASSOS IMEDIATOS

### ESTA SEMANA:
1. ✅ Finalizar documentação (você está aqui)
2. ⬜ Decidir: MVP completo ou incremental?
3. ⬜ Definir budget disponível
4. ⬜ Começar busca de embedded dev

### MÊS 1:
1. ⬜ Comprar componentes SPU (R$ 2k)
2. ⬜ Montar protótipo v0.1
3. ⬜ Refatorar sixpack_screen
4. ⬜ Definir protocolo de dados

### MÊS 2-3:
1. ⬜ SPU funcional em bancada
2. ⬜ App conectado ao SPU
3. ⬜ Primeiro voo teste

---

**Criado em:** 04/11/2025  
**Versão:** 1.0