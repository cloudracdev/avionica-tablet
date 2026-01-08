# 🛡️ QPATROL
## Sistema Inteligente de Monitoramento e Gestão de Viaturas Policiais

---

> **⚠️ DOCUMENTO CONFIDENCIAL**
> 
> Esta proposta foi elaborada a partir de informações estratégicas fornecidas pelo **Comandante de Tecnologia da Polícia Militar do Rio Grande do Norte, Clausan Liano,** transmitidas por intermédio de **Bruno Raniere**.
> 
> Solicitamos **ética e sigilo absoluto** no tratamento dessas informações, considerando seu caráter sensível e estratégico para a segurança pública do estado.

---

## 📋 Sumário Executivo

O **QPATROL** é uma solução completa de monitoramento inteligente de viaturas policiais que combina hardware embarcado, inteligência artificial e interface mobile/web para revolucionar a gestão de frotas policiais e a prevenção de crimes.

### Alinhamento Estratégico com a Quadritech

| Produto | Segmento | Sinergia |
|---------|----------|----------|
| **QFLY** | Aviação | Telemetria de aeronaves |
| **QCLASS** | Educação | Gestão de salas de aula |
| **QDRIVE** | Automotivo | Telemetria veicular |
| **QPATROL** | Segurança Pública | Gestão de viaturas policiais |

O **QPATROL** utiliza a **mesma arquitetura técnica do QFLY Aviônica** — tablets Android dedicados com GPS, 4G e aplicativo exclusivo — adaptada para o contexto de segurança pública.

---

## 🎯 Problema a Resolver

### Cenário Atual

- **Falta de visibilidade**: Comandantes não sabem onde estão suas viaturas em tempo real
- **Resposta lenta**: Dificuldade em alocar a viatura mais próxima para ocorrências
- **Gestão reativa**: Crimes são tratados após ocorrerem, sem prevenção inteligente
- **Comunicação ineficiente**: Solicitações de reforço dependem de rádio/telefone
- **Áreas descobertas**: Concentração de viaturas em algumas regiões, deixando outras vulneráveis

### Impacto

- Aumento do tempo de resposta a emergências
- Ineficiência na distribuição de recursos policiais
- Falta de dados para planejamento estratégico
- Dificuldade de coordenação entre unidades

---

## 💡 Solução QPATROL

### Arquitetura do Sistema

```
┌─────────────────────────────────────────────────────────────────────┐
│                          QPATROL                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────────┐  │
│  │   VIATURA    │    │    CLOUD     │    │    COMANDO           │  │
│  │              │    │              │    │                      │  │
│  │  [Tablet]    │───▶│  [Backend]   │───▶│  [Dashboard Web]     │  │
│  │  Android     │    │  N8N + API   │    │  [Painel Comandante] │  │
│  │  GPS + 4G    │◀───│  PostgreSQL  │◀───│  [Central Operações] │  │
│  │  Kiosk Mode  │    │  IA          │    │                      │  │
│  └──────────────┘    └──────────────┘    └──────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📱 Hardware: Tablet Dedicado

### Conceito

Assim como o **QFLY Aviônica** utiliza tablets dedicados nas aeronaves, o **QPATROL** utiliza tablets Android fixados nas viaturas, configurados em **Kiosk Mode** (modo quiosque), onde o dispositivo inicia automaticamente no aplicativo QPATROL sem possibilidade de acesso a outras funções.

### Especificações Recomendadas

| Modelo | Tela | RAM | Armazenamento | GPS | 4G | Preço Estimado |
|--------|------|-----|---------------|-----|-----|----------------|
| **Samsung Galaxy Tab A9 4G** | 8.7" | 4GB | 64GB | ✅ | ✅ | R$ 1.200 - 1.400 |
| **Lenovo Tab M9 4G** | 9" | 4GB | 64GB | ✅ | ✅ | R$ 900 - 1.100 |
| **Multilaser M10 4G** | 10" | 4GB | 64GB | ✅ | ✅ | R$ 800 - 1.000 |
| **Positivo Tab Q10 4G** | 10" | 4GB | 64GB | ✅ | ✅ | R$ 700 - 900 |

### Configuração Kiosk Mode (MDM)

O tablet será configurado com **MDM (Mobile Device Management)** — software de gerenciamento remoto que permite:

- ✅ Iniciar automaticamente no app QPATROL ao ligar
- ✅ Bloquear acesso a configurações do sistema
- ✅ Impedir instalação/desinstalação de apps
- ✅ Desabilitar botões de navegação
- ✅ Gerenciamento remoto pela central
- ✅ Atualizações automáticas do aplicativo
- ✅ Wipe remoto em caso de roubo

**Custo MDM**: R$ 5-15/dispositivo/mês (Scalefusion, TinyMDM, ou similar)

### Instalação na Viatura

- **Suporte veicular**: R$ 50-100 (fixação no painel)
- **Carregador 12V**: R$ 30-50 (alimentação contínua)
- **Película + Case**: R$ 50-80 (proteção)

---

## 🖥️ Software: Módulos do Sistema

### 1. App da Viatura (Flutter/Android)

**Funcionalidades:**

- 📍 Envio contínuo de localização GPS
- 🗺️ Mapa em tempo real com outras viaturas
- 🚨 Recebimento de alertas e ordens de deslocamento
- 🆘 Botão de pedido de reforço
- 📋 Registro de ocorrências
- 💬 Chat com central de comando
- 🔔 Notificações push de realocação

### 2. Dashboard de Comando (Flutter Web)

**Funcionalidades:**

- 🗺️ Mapa interativo com todas as viaturas
- 🔥 Heatmap de crimes por região/horário
- 📊 Painel de KPIs e métricas
- 🎯 Sistema de realocação de viaturas
- 📡 Monitoramento de áreas descobertas
- 📈 Relatórios de produtividade
- 🔔 Central de alertas e notificações

### 3. Painel do Comandante (Flutter Web)

**Funcionalidades:**

- 🖥️ Visão executiva da frota via navegador
- ✋ Realocação de viaturas com um clique
- 🚨 Recebimento de alertas críticos
- 📊 Indicadores e métricas resumidas
- 💬 Comunicação direta com viaturas
- 📱 Responsivo para acesso em qualquer dispositivo

### 4. Motor de Inteligência Artificial

**Módulos de IA (Inteligência Artificial):**

| Módulo | Função | Benefício |
|--------|--------|-----------|
| **Mapa de Calor** | Análise de ocorrências por local/horário | Visualização de zonas de risco |
| **Cobertura** | Detecção de áreas sem viatura | Alertas de vulnerabilidade |
| **Posicionamento** | Sugestão de realocação | Otimização da distribuição |
| **Predição** | Previsão de crimes por padrões | Ação preventiva |

---

## 🔄 Funcionalidade Exclusiva: Comunicação em Tempo Real

### Pedido de Reforço Inteligente

Quando um policial precisa de apoio:

1. **Toca no botão "REFORÇO"** no tablet
2. **Sistema identifica automaticamente** a viatura mais próxima disponível
3. **Envia notificação push** para o tablet da viatura selecionada
4. **Exibe no mapa** a localização exata do colega que precisa de ajuda
5. **Calcula e mostra a rota** mais rápida até o local

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Viatura A  │────▶│   Backend   │────▶│  Identifica │────▶│  Viatura B  │
│  Pede ajuda │     │  Recebe     │     │  mais perto │     │  Recebe     │
│             │     │             │     │  disponível │     │  alerta     │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │  Tablet B   │
                                        │  mostra     │
                                        │  localização│
                                        │  de A em    │
                                        │  tempo real │
                                        └─────────────┘
```

### Realocação pelo Comando

O comandante pode reposicionar qualquer viatura diretamente pelo painel web:

1. **Seleciona a viatura** no mapa
2. **Define novo ponto de patrulha** ou área
3. **Sistema envia ordem** para o tablet da viatura
4. **Tablet exibe nova rota** com destino atualizado
5. **Comandante acompanha** o deslocamento em tempo real

---

## 💰 Investimento Detalhado

### Custos de Hardware (Por Viatura)

| Item | Custo Unitário |
|------|----------------|
| Tablet Android 4G (Samsung Tab A9 ou similar) | R$ 1.200 |
| Suporte veicular + instalação | R$ 100 |
| Carregador 12V | R$ 50 |
| Película + case de proteção | R$ 80 |
| **Total Hardware/Viatura** | **R$ 1.430** |

### Custos Mensais (Por Viatura)

| Item | Custo Mensal |
|------|--------------|
| Chip 4G (plano M2M dados) | R$ 25 |
| MDM (gerenciamento remoto) | R$ 10 |
| **Total Mensal/Viatura** | **R$ 35** |

### Custos de Infraestrutura (Mensal)

| Item | Custo Mensal |
|------|--------------|
| Servidor Cloud (VPS 8GB RAM) | R$ 200 |
| Banco de dados PostgreSQL | R$ 100 |
| Backup e redundância | R$ 50 |
| **Total Infraestrutura** | **R$ 350** |

### Desenvolvimento de Software

| Fase | Horas | Valor/Hora | Total |
|------|-------|------------|-------|
| Mês 1: Backend + API + Arquitetura | 180h | R$ 25 | R$ 4.500 |
| Mês 2: App Viatura (Flutter) | 180h | R$ 25 | R$ 4.500 |
| Mês 3: Dashboard Comando + Painel Comandante (Web) | 180h | R$ 25 | R$ 4.500 |
| Mês 4: IA + Integração + Testes + Deploy | 180h | R$ 25 | R$ 4.500 |
| **Total Desenvolvimento** | **720h** | **R$ 25** | **R$ 18.000** |

---

## 📊 Simulação de Custos por Frota

### Cenário: 50 Viaturas

| Categoria | Cálculo | Valor |
|-----------|---------|-------|
| Hardware inicial | 50 × R$ 1.430 | R$ 71.500 |
| Desenvolvimento | - | R$ 18.000 |
| **INVESTIMENTO INICIAL** | - | **R$ 89.500** |
| Custo mensal viaturas | 50 × R$ 35 | R$ 1.750 |
| Infraestrutura mensal | - | R$ 350 |
| **CUSTO MENSAL** | - | **R$ 2.100** |
| **CUSTO ANUAL (após implantação)** | 12 × R$ 2.100 | **R$ 25.200** |

### Cenário: 100 Viaturas

| Categoria | Cálculo | Valor |
|-----------|---------|-------|
| Hardware inicial | 100 × R$ 1.430 | R$ 143.000 |
| Desenvolvimento | - | R$ 18.000 |
| **INVESTIMENTO INICIAL** | - | **R$ 161.000** |
| Custo mensal viaturas | 100 × R$ 35 | R$ 3.500 |
| Infraestrutura mensal | - | R$ 350 |
| **CUSTO MENSAL** | - | **R$ 3.850** |
| **CUSTO ANUAL (após implantação)** | 12 × R$ 3.850 | **R$ 46.200** |

### Cenário: 200 Viaturas

| Categoria | Cálculo | Valor |
|-----------|---------|-------|
| Hardware inicial | 200 × R$ 1.430 | R$ 286.000 |
| Desenvolvimento | - | R$ 18.000 |
| **INVESTIMENTO INICIAL** | - | **R$ 304.000** |
| Custo mensal viaturas | 200 × R$ 35 | R$ 7.000 |
| Infraestrutura mensal | - | R$ 500 |
| **CUSTO MENSAL** | - | **R$ 7.500** |
| **CUSTO ANUAL (após implantação)** | 12 × R$ 7.500 | **R$ 90.000** |

---

## 📈 Modelo de Receita (Comercialização)

### Precificação SaaS

| Plano | Funcionalidades | Preço/Viatura/Mês |
|-------|-----------------|-------------------|
| **Básico** | Rastreamento + Histórico 30 dias + Dashboard | R$ 80 |
| **Profissional** | Básico + Mapa de calor + Alertas + Realocação | R$ 120 |
| **Enterprise** | Profissional + IA Preditiva + API + Suporte 24/7 | R$ 180 |

### Projeção de Receita (Ano 1)

| Clientes | Viaturas | Plano | Receita Mensal | Receita Anual |
|----------|----------|-------|----------------|---------------|
| 1 PM estadual | 200 | Enterprise | R$ 36.000 | R$ 432.000 |
| 3 Guardas Municipais | 150 | Profissional | R$ 18.000 | R$ 216.000 |
| 5 Prefeituras (frota) | 100 | Básico | R$ 8.000 | R$ 96.000 |
| **TOTAL** | **450** | - | **R$ 62.000** | **R$ 744.000** |

### Margem de Lucro Estimada

| Item | Valor Mensal |
|------|--------------|
| Receita (450 viaturas) | R$ 62.000 |
| (-) Custos operacionais | R$ 20.000 |
| (-) Infraestrutura | R$ 2.000 |
| (-) Suporte/Atendimento | R$ 8.000 |
| **Lucro Bruto** | **R$ 32.000** |
| **Margem** | **51,6%** |

### Projeção de Crescimento (5 Anos)

| Ano | Viaturas | Receita Anual | Lucro Anual |
|-----|----------|---------------|-------------|
| 1 | 450 | R$ 744.000 | R$ 384.000 |
| 2 | 900 | R$ 1.488.000 | R$ 768.000 |
| 3 | 1.500 | R$ 2.480.000 | R$ 1.280.000 |
| 4 | 2.200 | R$ 3.640.000 | R$ 1.880.000 |
| 5 | 3.000 | R$ 4.960.000 | R$ 2.560.000 |

---

## 🚀 Cronograma de Desenvolvimento (4 Meses)

### Mês 1: Fundação (180h)

| Semana | Entrega |
|--------|---------|
| 1 | Arquitetura do sistema + Setup infraestrutura |
| 2 | Modelagem banco de dados + API REST base |
| 3 | Sistema de autenticação + Gestão de viaturas |
| 4 | WebSocket para tempo real + Testes backend |

**Entregável:** Backend funcional com API documentada

---

### Mês 2: App da Viatura (180h)

| Semana | Entrega |
|--------|---------|
| 5 | Setup Flutter + Tela de login + GPS tracking |
| 6 | Mapa em tempo real + Visualização de colegas |
| 7 | Sistema de reforço + Notificações push |
| 8 | Chat + Registro de ocorrências + Testes |

**Entregável:** App da viatura completo e funcional

---

### Mês 3: Central de Comando (180h)

| Semana | Entrega |
|--------|---------|
| 9 | Dashboard Web: Mapa interativo + Lista viaturas |
| 10 | Sistema de realocação + Alertas de cobertura |
| 11 | Painel do Comandante (Web) + Visão executiva |
| 12 | Relatórios + Histórico + Exportação de dados |

**Entregável:** Dashboard Web + Painel do Comandante (Web)

---

### Mês 4: Inteligência e Finalização (180h)

| Semana | Entrega |
|--------|---------|
| 13 | Módulo Mapa de Calor + Análise de ocorrências |
| 14 | IA de cobertura + Sugestão de posicionamento |
| 15 | Integração completa + Testes end-to-end |
| 16 | Deploy produção + Documentação + Treinamento |

**Entregável:** Sistema completo em produção

---

## 🏢 Proposta de Desenvolvimento

### Equipe Responsável

**Racdev Tecnologia**
- **Bruno Raniere** - Líder Técnico / Arquiteto de Software
- Equipe de desenvolvimento Flutter e Backend

### Modelo de Contratação

| Item | Valor |
|------|-------|
| Valor hora | R$ 25,00 |
| Horas por mês | 180h |
| Prazo | 4 meses |
| Horas totais | 720h |
| **Valor total do projeto** | **R$ 18.000** |

### Garantias

- ✅ **Desenvolvimento em paralelo ao QFLY Aviônica** (sem impacto no projeto atual)
- ✅ Mesma stack tecnológica (Flutter + N8N + PostgreSQL)
- ✅ Código fonte proprietário da Quadritech (Verificar ética com Comandante da Polícia Militar Clausan Liano)
- ✅ Documentação técnica completa

---

## ✅ Diferenciais Competitivos

| Aspecto | QPATROL | Concorrentes |
|---------|---------|--------------|
| **Custo por viatura** | R$ 1.430 (único) + R$ 35/mês | R$ 300-500/mês |
| **Hardware** | Tablet comercial | Dispositivos proprietários |
| **IA Preditiva** | ✅ Incluída | ❌ ou custo adicional |
| **Realocação em tempo real** | ✅ Integrada | ❌ Manual |
| **Comunicação entre viaturas** | ✅ Chat + Localização | ❌ Apenas rádio |
| **Pedido de reforço inteligente** | ✅ Automático | ❌ Inexistente |
| **Código fonte** | ✅ Proprietário | ❌ Licenciado |
| **Customização** | ✅ Total | ❌ Limitada |

---

## 🎯 Resumo Executivo para Decisão

| Métrica | Valor |
|---------|-------|
| **Desenvolvimento (720h × R$25)** | R$ 18.000 |
| **Investimento inicial (100 viaturas)** | R$ 161.000 |
| **Custo mensal de operação** | R$ 3.850 |
| **Receita potencial mensal (450 viaturas)** | R$ 62.000 |
| **Lucro mensal estimado** | R$ 32.000 |
| **Margem de lucro** | 51,6% |
| **Payback** | 5 meses |
| **Receita anual (Ano 5)** | R$ 4.960.000 |

---

## 📞 Próximos Passos

1. **Aprovação da proposta** pelo CEO Clevan Costa
2. **Reunião técnica** para refinamento de requisitos com a PM/RN
3. **Assinatura de contrato** com a Racdev
4. **Kick-off do projeto** e início do Mês 1
5. **Piloto** com 10 viaturas ao final do mês 4
6. **Escala** para frota completa

---

> **Documento elaborado por:**
> 
> **Bruno Raniere**
> Racdev Tecnologia
> 
> **Para:** Clevan Costa, CEO - Quadritech
> 
> **Data:** Novembro/2025
> 
> ---
> 
> *Este sistema pode ser desenvolvido em paralelo ao QFLY pela Racdev por Bruno Raniere e equipe, no valor de R$ 25,00/hora, sem atrapalhar em nada o desenvolvimento do QFLY Aviônica.*