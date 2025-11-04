# VISÃO GERAL COMPLETA - Sistema Aviônica

**Produto:** Sistema Completo de Gestão de Instrução Aeronáutica  
**Cliente:** Escolas de Pilotagem (Aeroclubes)  
**Empresa:** Quadritech  
**Data:** 04/11/2025

---

## 📋 ÍNDICE

1. [Problema](#problema)
2. [Solução](#solução)
3. [Escopo Completo](#escopo-completo)
4. [Stakeholders](#stakeholders)
5. [Módulos do Sistema](#módulos-do-sistema)
6. [Diferenciais](#diferenciais)
7. [Impacto](#impacto)

---

## 🔴 PROBLEMA

### Dificuldades das Escolas de Pilotagem:

1. **❌ Dificuldade em localizar a real posição da aeronave em instrução**
2. **❌ Falta do registro dos indicadores dos instrumentos da aeronave**
3. **❌ Ausência de visualização dos valores instantâneos dos instrumentos**
4. **❌ Falta de integração automática do plano de voo com o voo realizado**
5. **❌ Ausência de indicadores de performance objetivos do aluno**
6. **❌ Ausência do áudio e vídeos internos da aeronave em instrução**

### Consequências:

- ⚠️ Avaliações subjetivas
- ⚠️ Falta de evidências de treinamento
- ⚠️ Baixa credibilidade
- ⚠️ Segurança comprometida
- ⚠️ Gestão ineficiente

---

## ✅ SOLUÇÃO

### Sistema Integrado com 4 Camadas:

```
┌─────────────────────────────────────────────┐
│  HARDWARE (Avião)                           │
│  - SPU (Sensor Processing Unit)            │
│  - CPU Aviônica (ARM Cortex M4)            │
│  - Sensores: GPS, IMU, Barômetro, etc      │
│  - Câmeras + Áudio                         │
└─────────────────┬───────────────────────────┘
                  │ 4G/WiFi/GPRS
                  ▼
┌─────────────────────────────────────────────┐
│  TABLET (Instrutor)                         │
│  - App Flutter (Sixpack + Instrumentos)    │
│  - Visualização real-time                  │
│  - Plano de voo integrado                  │
│  - Avaliação + Debriefing                  │
└─────────────────┬───────────────────────────┘
                  │ WiFi/Internet
                  ▼
┌─────────────────────────────────────────────┐
│  BACKEND CLOUD                              │
│  - Armazenamento (PostgreSQL)              │
│  - API REST                                 │
│  - Processamento de dados                  │
│  - Sincronização                           │
└─────────────────┬───────────────────────────┘
                  │ Internet
                  ▼
┌─────────────────────────────────────────────┐
│  WEB APP (Aeroclube)                        │
│  - Central de Monitoramento                │
│  - Gestão Acadêmica                        │
│  - EAD (Moodle)                            │
│  - E-commerce                              │
│  - Relatórios                              │
└─────────────────────────────────────────────┘
```

---

## 🎯 ESCOPO COMPLETO

### O Sistema Aviônica É MUITO MAIOR que o QFLY atual:

| Módulo | QFLY Atual | Sistema Completo |
|--------|-----------|------------------|
| **Hardware** | ❌ Simulado | ✅ SPU real em aviões |
| **App Tablet** | ✅ Sixpack | ✅ Sixpack + Gestão voo |
| **Backend** | ❌ Mockado | ✅ Cloud completo |
| **Web App** | ❌ Inexistente | ✅ Central aeroclube |
| **EAD** | ❌ Inexistente | ✅ Moodle integrado |
| **E-commerce** | ❌ Inexistente | ✅ Vendas de cursos |
| **Gestão** | ❌ Inexistente | ✅ Acadêmica + Financeira |
| **Exames** | ❌ Inexistente | ✅ Teórico + Prático |
| **DETRAN** | ❌ Inexistente | ✅ Integração |

**QFLY é 10% do Sistema Aviônica!**

---

## 👥 STAKEHOLDERS

### 1. Alunos (Pilotos em Formação)
**Necessidades:**
- Acompanhar progresso
- Ver histórico de voos
- Receber feedback objetivo
- Acessar material EAD
- Agendar aulas

### 2. Instrutores
**Necessidades:**
- Monitorar aluno em tempo real
- Avaliar com dados objetivos
- Fazer debriefing com evidências
- Gerenciar agenda
- Aplicar exames

### 3. Aeroclubes (Gestores)
**Necessidades:**
- Visão geral de todas aeronaves
- Gestão acadêmica completa
- Controle financeiro
- Relatórios regulatórios
- Compliance ANAC/DETRAN

### 4. ANAC (Regulador)
**Necessidades:**
- Auditoria de treinamentos
- Comprovação de horas
- Dados de segurança

### 5. DETRAN
**Necessidades:**
- Integração de exames
- Validação de competências

---

## 🧩 MÓDULOS DO SISTEMA

### 1. **Hardware SPU (Sensor Processing Unit)**

**Componentes:**
- CPU ARM Cortex M4 64MHz
- GPS (localização)
- Magnetômetro (bússola)
- Giroscópio (pitch, roll, yaw)
- Acelerômetro (forças G)
- Barômetro (altitude, pressão)
- Sintetizador de áudio
- Câmera de vídeo
- Comunicação: 4G, WiFi, Bluetooth

**Dados Coletados:**
```
- GPS: lat, lng, altitude
- Bússola: heading (0-360°)
- Horizonte: pitch, roll (-90 a +90°, -180 a +180°)
- Velocidade: airspeed (pitot), groundspeed (GPS)
- Variômetro: taxa subida/descida (m/s)
- Telemetria: RPM, temperatura, combustível, bateria
- Áudio: comunicação rádio
- Vídeo: cockpit interno
```

**Taxa de Amostragem:**
- Instrumentos críticos: 1 Hz (1x/segundo)
- Telemetria: 0.1 Hz (1x/10 segundos)

---

### 2. **App Tablet (Instrutor)**

**Tecnologia:** Flutter  
**Plataformas:** Android, iOS

**Funcionalidades:**

**A. Instrumentos em Tempo Real (QFLY)**
- Horizonte Artificial
- Coordenador de Curva
- Altímetro
- Velocímetro
- Bússola
- Variômetro

**B. Gestão de Voo**
- Plano de voo (origem, destino, alternativa, rota)
- Integração plano vs realizado
- Estatísticas (max/min de todos parâmetros)
- Cronômetro de voo

**C. Avaliação**
- Debriefing estruturado
- Notas por competência
- Comentários do instrutor
- Replay do voo

**D. Comunicação**
- Conexão WiFi/Bluetooth com SPU
- Sincronização cloud via 4G
- Offline-first (continua funcionando sem internet)

---

### 3. **Backend Cloud**

**Tecnologia:** Node.js + PostgreSQL + AWS/Firebase  
**Arquitetura:** Microserviços REST API

**Serviços:**

**A. API de Voos**
```
POST   /flights         - Criar voo
GET    /flights/:id     - Detalhes voo
GET    /flights         - Listar voos
PATCH  /flights/:id     - Atualizar voo
DELETE /flights/:id     - Deletar voo
```

**B. API de Telemetria**
```
POST   /telemetry       - Enviar dados (bulk)
GET    /telemetry/:flightId - Recuperar dados
```

**C. API de Alunos**
```
CRUD completo de alunos
GET /students/:id/history - Histórico
GET /students/:id/stats   - Estatísticas
```

**D. API de Instrutores**
```
CRUD completo de instrutores
GET /instructors/:id/flights - Voos ministrados
```

**E. API de Avaliações**
```
POST   /evaluations     - Criar avaliação
GET    /evaluations/:id - Recuperar avaliação
```

**F. WebSocket Real-Time**
```
ws://api.avionica.com/flights/:id/stream
- Streaming de telemetria ao vivo
```

---

### 4. **Web App (Aeroclube)**

**Tecnologia:** React + Next.js  
**Acesso:** Navegador (Responsive)

**Módulos:**

**A. Central de Monitoramento**
- Mapa com todas aeronaves ao vivo
- Painel sixpack de cada aeronave
- Radar estilo ATC
- Alertas de segurança

**B. Gestão Acadêmica**
- Cadastro alunos/instrutores/aeronaves
- Plano de aulas (ementa)
- Agenda de voos
- Histórico de treinamentos
- Relatórios regulatórios

**C. Gestão Financeira**
- Sistema de créditos
- Faturamento
- Controle de pagamentos
- Relatórios contábeis

**D. EAD (Moodle Integrado)**
- Aulas teóricas online
- Vídeos, PDFs, Slides
- Identificação facial (IA)
- Certificados automáticos

**E. E-commerce**
- Catálogo de cursos
- Carrinho de compras
- Pagamento online
- Matrícula automatizada

**F. Exames**
- Banco de questões ANAC
- Exame teórico remoto (com IA)
- Agendamento exame prático
- Integração DETRAN/ANAC

**G. Relatórios**
- Horas de voo por aluno
- Performance de instrutores
- Utilização de aeronaves
- Indicadores acadêmicos

---

### 5. **EAD (Moodle)**

**Plataforma:** Moodle LMS  
**Integração:** API REST

**Funcionalidades:**
- Cursos teóricos completos
- Trilhas de aprendizado
- Avaliações online
- Reconhecimento facial (anti-fraude)
- Certificação ANAC
- Mobile app

**Cursos Oferecidos:**
- Piloto Privado (PP)
- Piloto Comercial (PC)
- IFR (Instrumentos)
- MLTE (Multi-motor)
- Inglês ICAO
- Jet Training

---

### 6. **E-commerce**

**Plataforma:** WooCommerce + Moodle  
**Plugin:** LearnWoo

**Funcionalidades:**
- Venda de cursos online
- Pacotes (teórico + prático)
- Créditos de horas de voo
- Carrinho de compras
- Gateway pagamento (Stripe, PagSeguro)
- Matrícula automática após pagamento

---

### 7. **Integração DETRAN**

**Objetivo:** Facilitar processo de CNH

**Fluxos:**

**A. Exame Teórico**
- Aplicado pela escola (com supervisão IA)
- Enviado para DETRAN
- Validação automática

**B. Exame Prático**
- Agendado no DETRAN
- Aluno usa "FreeCFC" (app tipo Uber)
- Taxa paga + uso do carro

**C. Emissão CNH**
- Aprovação enviada automaticamente
- DETRAN processa

---

## 🚀 DIFERENCIAIS

### Vs Concorrência:

| Feature | Aviônica | Outros |
|---------|----------|--------|
| **Hardware Próprio** | ✅ SPU desenvolvido | ❌ Genérico |
| **Sixpack Digital** | ✅ Flutter | ⚠️ Web básico |
| **Áudio + Vídeo** | ✅ Sim | ❌ Não |
| **EAD Integrado** | ✅ Moodle | ❌ Separado |
| **E-commerce** | ✅ Sim | ❌ Não |
| **DETRAN** | ✅ Integrado | ❌ Manual |
| **Cloud Real-time** | ✅ WebSocket | ⚠️ Pooling |
| **Offline-first** | ✅ App funciona | ❌ Depende rede |

---

## 💰 MODELO DE NEGÓCIO

### Receitas:

**1. Venda de Hardware (SPU)**
- R$ 8.000 - R$ 15.000 por aeronave
- Margem: 40%

**2. Licença SaaS (Mensal)**
- R$ 500/mês por aeronave
- Inclui: cloud, app, atualizações

**3. E-commerce (Comissão)**
- 10-15% sobre vendas de cursos

**4. Serviços**
- Instalação: R$ 2.000
- Treinamento: R$ 1.500
- Suporte premium: R$ 800/mês

### Mercado:

- 300+ aeroclubes no Brasil
- ~1.500 aeronaves de instrução
- TAM: R$ 15-20 milhões

---

## 📊 IMPACTO

### Para Alunos:
- ✅ Feedback objetivo e transparente
- ✅ Progresso mensurável
- ✅ Histórico completo
- ✅ EAD flexível

### Para Instrutores:
- ✅ Avaliação baseada em dados
- ✅ Menos tempo administrativo
- ✅ Evidências de ensino

### Para Aeroclubes:
- ✅ Gestão profissionalizada
- ✅ Compliance automático
- ✅ Receita adicional (e-commerce)
- ✅ Credibilidade aumentada

### Para ANAC:
- ✅ Auditoria facilitada
- ✅ Dados de segurança
- ✅ Rastreabilidade completa

---

## 🎯 VISÃO DE LONGO PRAZO

### Fase 1 (Ano 1): Aviação
- Escolas de pilotagem
- Aeroclubes
- Instrutores independentes

### Fase 2 (Ano 2): Expansão
- Escolas de helicóptero
- Táxi aéreo (treinamento)
- Aviação agrícola

### Fase 3 (Ano 3): Internacional
- América Latina
- África (mercado em crescimento)
- Europa (nicho)

### Fase 4 (Ano 4+): Outros Setores
- Autoescolas terrestres
- Escolas náuticas
- Operadores de drones

---

## 📐 COMPARAÇÃO DE ESCOPO

```
┌─────────────────────────────────────────────────────┐
│                 QFLY (Atual)                        │
│  - App Flutter (sixpack)                            │
│  - ESP32 simulado                                   │
│  - Total: ~6.500 linhas                            │
│  - Tempo dev: 2 meses                               │
└─────────────────────────────────────────────────────┘
                     ↓ É 10% DO ↓
┌─────────────────────────────────────────────────────┐
│           SISTEMA AVIÔNICA COMPLETO                 │
│  1. Hardware SPU (embedded C++)                     │
│  2. App Tablet (Flutter) - 20k linhas               │
│  3. Backend Cloud (Node.js) - 30k linhas            │
│  4. Web App (React) - 40k linhas                    │
│  5. EAD Moodle (PHP) - 10k linhas custom            │
│  6. E-commerce (WooCommerce) - 5k linhas            │
│  7. Integração DETRAN (API) - 3k linhas             │
│  - Total: ~108.000 linhas                           │
│  - Tempo dev: 18-24 meses (time completo)           │
└─────────────────────────────────────────────────────┘
```

---

## 🎯 CONCLUSÃO

**Sistema Aviônica não é apenas um app.**

É uma **plataforma completa end-to-end** que:
- ✅ Digitaliza 100% do processo de formação de pilotos
- ✅ Integra hardware, software, cloud, EAD, e-commerce
- ✅ Resolve problemas reais de escolas de pilotagem
- ✅ Gera múltiplas fontes de receita
- ✅ Escalável para outros mercados

**QFLY é o primeiro passo — a ponta do iceberg.**

---

**Próximos documentos:**
- AVIONICA_ARCHITECTURE.md - Arquitetura técnica
- AVIONICA_MODULES.md - Detalhamento módulos
- AVIONICA_ROADMAP.md - Plano de execução

**Criado em:** 04/11/2025  
**Versão:** 1.0