# 🛩️ QFLY/AVIÔNICA - VISÃO DE PRODUTO

**📅 Data:** Novembro 2025  
**👥 Público:** Marketing, RH, Financeiro, Investidores  
**🎯 Objetivo:** Explicar o produto sem jargões técnicos

---

## 📖 O QUE É O AVIÔNICA?

Uma plataforma completa que **transforma** a forma como as escolas de aviação ensinam e avaliam seus alunos.

Imagine que hoje, quando um aluno aprende a voar, **tudo** é baseado na **opinião do instrutor**. É como fazer prova na escola e só receber "foi bom" ou "foi ruim" — sem nota, sem dados, sem provas.

**O Aviônica muda isso completamente.**

---

## 🔴 O PROBLEMA QUE RESOLVEMOS

### Dores Atuais das Escolas de Aviação

```mermaid
graph LR
    A["😟 Aluno<br/>Inseguro"] --> B["❓ Avaliação<br/>Subjetiva"]
    B --> C["💸 Desistência<br/>Alta"]
    C --> D["📉 Prejuízo<br/>Escola"]
    
    style A fill:#e74c3c,color:#fff
    style B fill:#e67e22,color:#fff
    style C fill:#c0392b,color:#fff
    style D fill:#95a5a6,color:#fff
```

**Principais problemas:**

1. 🤔 **"Será que estou voando bem?"**  
   → Aluno não tem certeza do próprio desempenho

2. 📝 **Avaliação 100% subjetiva**  
   → Instrutor escreve "voo satisfatório" sem dados reais

3. 🔥 **Conflitos frequentes**  
   → Aluno discorda da avaliação, não tem como provar nada

4. 📄 **Papelada manual**  
   → CIV (caderneta de voo) em papel, pode perder, rasgar, molhar

5. ⏰ **Burocracia ANAC**  
   → Enviar documentos manualmente para órgão regulador

6. 💰 **Desistências custam caro**  
   → 30-40% dos alunos desistem por frustração

---

## ✨ A SOLUÇÃO: 3 COMPONENTES SIMPLES

### Visão Geral do Sistema

```mermaid
graph TB
    subgraph AVIAO["✈️ NO AVIÃO"]
        A["📦 Caixa Sensores<br/>────────<br/>7 equipamentos<br/>Mede tudo em<br/>tempo real"]
    end
    
    subgraph TABLET["📱 NO TABLET"]
        B["📲 App Instrutor<br/>────────<br/>Vê instrumentos<br/>Avalia aluno<br/>Tira fotos"]
    end
    
    subgraph NUVEM["☁️ NA NUVEM"]
        C["🖥️ 4 Sites<br/>────────<br/>Admin<br/>Gestor<br/>Instrutor<br/>Aluno"]
    end
    
    A -->|"WiFi<br/>Durante voo"| B
    B -->|"Internet<br/>Após pousar"| C
    
    style A fill:#e74c3c,color:#fff
    style B fill:#3498db,color:#fff
    style C fill:#2ecc71,color:#fff
```

---

## 🎯 COMO FUNCIONA NA PRÁTICA

### Jornada Completa de um Voo

```mermaid
flowchart TD
    START["🌅 ANTES DO VOO"] --> A1["📋 Instrutor abre app<br/>Faz checklist digital"]
    
    A1 --> A2["📸 Tira fotos do avião<br/>Documentação"]
    
    A2 --> VOO["✈️ DURANTE O VOO"]
    
    VOO --> B1["📊 CAIXA mede TUDO<br/>Altitude, velocidade,<br/>direção, inclinação..."]
    
    B1 --> B2["📱 Tablet mostra<br/>instrumentos digitais<br/>Instrutor acompanha"]
    
    B2 --> POUSO["🛬 APÓS O POUSO"]
    
    POUSO --> C1["⭐ Instrutor avalia<br/>6 categorias<br/>Com DADOS REAIS"]
    
    C1 --> C2["☁️ Sobe tudo pra nuvem<br/>Voo + Fotos + Avaliação"]
    
    C2 --> C3["📋 Sistema envia<br/>automaticamente pra ANAC"]
    
    C3 --> END["✅ CONCLUÍDO<br/>Aluno vê tudo online"]
    
    style START fill:#3498db,color:#fff
    style VOO fill:#e74c3c,color:#fff
    style POUSO fill:#f39c12,color:#fff
    style END fill:#2ecc71,color:#fff
```

---

## 📦 COMPONENTE 1: CAIXA NO AVIÃO

**O que é?**  
Uma CAIXA eletrônica pequena (menor que uma caixa de celular) que fica no avião e **mede tudo** durante o voo.

**O que ela mede?**

| Sensor | O que faz |
|--------|-----------|
| 🗺️ GPS | Posição exata do avião |
| 📏 Altitude | Altura em relação ao solo |
| 🧭 Bússola | Direção que está indo |
| ⚡ Acelerômetro | Subidas, descidas, curvas |
| 🔄 Giroscópio | Inclinação do avião |
| 🌡️ Temperatura | Temperatura externa |

**Benefício:**  
→ **Dados REAIS** de como o aluno está voando  
→ Não é mais "achismo"

---

## 📱 COMPONENTE 2: APP NO TABLET

**O que é?**  
Um aplicativo no tablet do instrutor que funciona **mesmo sem internet** (offline).

**O que o instrutor faz no app:**

```mermaid
graph LR
    A["📋 Checklist<br/>Pré-voo"] --> B["📊 Vê instrumentos<br/>em tempo real"]
    B --> C["📸 Tira fotos<br/>do voo"]
    C --> D["⭐ Avalia aluno<br/>com dados"]
    D --> E["☁️ Sincroniza<br/>após pousar"]
    
    style A fill:#3498db,color:#fff
    style B fill:#2ecc71,color:#fff
    style C fill:#f39c12,color:#fff
    style D fill:#9b59b6,color:#fff
    style E fill:#1abc9c,color:#fff
```

**Telas principais:**

1. **📊 Painel de Instrumentos ("Sixpack")**  
   → 6 instrumentos digitais mostrando altitude, velocidade, direção...  
   → Instrutor vê tudo em tempo real

2. **✅ Checklist Digital**  
   → Verificações antes do voo (combustível, freios, etc)  
   → Marca tudo digitalmente

3. **⭐ Avaliação do Aluno**  
   → 6 categorias baseadas no manual da ANAC  
   → Sistema sugere notas baseado nos dados reais

4. **📸 Fotos**  
   → Documenta o estado do avião  
   → Fica salvo junto com o voo

---

## 🌐 COMPONENTE 3: SITES NA INTERNET

**O que é?**  
4 sites diferentes, cada um para um tipo de pessoa:

### 1️⃣ Site do ADMINISTRADOR (Dono do Sistema)

**Quem usa:** Equipe do Aviônica  

**O que vê:**
- 📊 Todas as escolas usando o sistema
- 🗺️ Mapa global: todos os aviões voando AO VIVO
- 📈 Estatísticas gerais: quantos voos, quantas horas...
- ⚙️ Configurações do sistema

---

### 2️⃣ Site do GESTOR (Dono da Escola)

**Quem usa:** Diretor/Gerente do aeroclube  

**O que faz:**
- 👥 Cadastra alunos e instrutores
- ✈️ Cadastra aviões
- 📅 Vê agenda de voos
- 📊 Relatórios: quantas horas voadas...
- 📈 Acompanha desempenho da escola

**Benefício:**  
→ Gestão profissional da escola  
→ Decisões baseadas em dados reais

---

### 3️⃣ Site do INSTRUTOR

**Quem usa:** Instrutor de voo  

**O que vê:**
- 📋 Lista de todos os seus alunos
- 📊 Progresso de cada aluno (quantas horas fez, quais manobras domina)
- 🗺️ **Replay do voo:** ver o caminho que o avião fez no mapa
- 📈 Gráficos de performance (altitude, velocidade ao longo do tempo)
- 📄 CIV Digital já pronto para ANAC

**Diferencial único:**  
→ 🎬 **Replay Interativo:** clicar em qualquer momento do voo e ver TUDO que estava acontecendo naquele segundo

---

### 4️⃣ Site do ALUNO

**Quem usa:** Aluno aprendendo a voar  

**O que vê:**
- ✈️ Todos os meus voos
- ⭐ Minhas avaliações
- 📈 Meu progresso (falta X horas para tirar brevê)
- 📄 Minha CIV Digital (caderneta oficial)
- 📁 Meus documentos (exames médicos, certificados)

**Benefício:**  
→ Transparência total  
→ Aluno vê seu próprio desenvolvimento  
→ Reduz ansiedade e desistências

---

## 🎁 BENEFÍCIOS POR PERFIL

### Para o ALUNO

```mermaid
graph LR
    A["😟 Antes:<br/>Inseguro"] --> B["✨ Aviônica"]
    B --> C["😊 Depois:<br/>Confiante"]
    
    style A fill:#e74c3c,color:#fff
    style B fill:#3498db,color:#fff
    style C fill:#2ecc71,color:#fff
```

- ✅ **Transparência:** Vê dados reais do voo
- ✅ **Progresso claro:** Sabe exatamente o que falta aprender
- ✅ **Motivação:** Acompanha evolução
- ✅ **Menos conflito:** Avaliação baseada em dados, não opinião
- ✅ **Praticidade:** Tudo digital, acessa de qualquer lugar

---

### Para o INSTRUTOR

```mermaid
graph LR
    A["📝 Antes:<br/>Papelada"] --> B["✨ Aviônica"]
    B --> C["🚀 Depois:<br/>Eficiente"]
    
    style A fill:#e74c3c,color:#fff
    style B fill:#3498db,color:#fff
    style C fill:#2ecc71,color:#fff
```

- ✅ **Menos burocracia:** Sem papel, tudo no app
- ✅ **Avaliação justa:** Dados reais apoiam a nota
- ✅ **Menos discussões:** Aluno vê os dados, aceita melhor
- ✅ **Profissionalismo:** Ferramenta moderna e séria
- ✅ **Foco no ensino:** Mais tempo para instruir, menos para papelada

---

### Para a ESCOLA (Gestor)

```mermaid
graph LR
    A["📉 Antes:<br/>Sem controle"] --> B["✨ Aviônica"]
    B --> C["📈 Depois:<br/>Profissional"]
    
    style A fill:#e74c3c,color:#fff
    style B fill:#3498db,color:#fff
    style C fill:#2ecc71,color:#fff
```

- ✅ **Gestão profissional:** Dados de tudo que acontece
- ✅ **Menos desistências:** Alunos satisfeitos continuam
- ✅ **Compliance ANAC:** Automático, sem risco de multa
- ✅ **Marketing:** Diferencial competitivo ("somos high-tech")
- ✅ **Receita maior:** Alunos completam curso, indicam amigos

---

## 🏆 DIFERENCIAIS COMPETITIVOS

### O Que Nos Torna ÚNICOS

| Concorrentes<br/>(SAGA, Alis, Plane It) | 🚀 AVIÔNICA |
|------------------------------------------|-------------|
| ❌ Só software (sem hardware) | ✅ **Hardware próprio no avião** |
| ❌ Avaliação manual/texto | ✅ **Dados reais de sensores** |
| ❌ Sem telemetria | ✅ **20x por segundo medindo tudo** |
| ❌ Sem replay | ✅ **Replay interativo no mapa** |
| ❌ Portal aluno básico | ✅ **Portal completo com progresso** |
| ❌ CIV manual | ✅ **CIV automático para ANAC** |
| ❌ Sem acompanhamento em voo | ✅ **Live tracking (GPS ao vivo)** |

### Nossa Proposta de Valor

```mermaid
graph TB
    A["💎 VALOR ÚNICO"] --> B["📊 Dados Reais"]
    A --> C["🎯 Avaliação Objetiva"]
    A --> D["🤖 Automação ANAC"]
    A --> E["🗺️ Replay Interativo"]
    
    style A fill:#f39c12,color:#fff
    style B fill:#3498db,color:#fff
    style C fill:#2ecc71,color:#fff
    style D fill:#9b59b6,color:#fff
    style E fill:#e74c3c,color:#fff
```

**Resumo em uma frase:**  
> *"Somos os únicos que colocam SENSORES REAIS no avião para avaliar o aluno com DADOS, não opiniões."*

---

## 💰 MODELO DE NEGÓCIO

### Como Vamos Ganhar Dinheiro?

```mermaid
graph LR
    A["🏫 Escola de Aviação"] --> B["💰 Assina mensalmente"]
    B --> C["☁️ Usa plataforma"]
    C --> D["📦 Compra hardware"]
    
    style A fill:#3498db,color:#fff
    style B fill:#2ecc71,color:#fff
    style C fill:#9b59b6,color:#fff
    style D fill:#e74c3c,color:#fff
```

### 3 Fontes de Receita

#### 1️⃣ **ASSINATURA MENSAL (SaaS)**
- 📱 Acesso aos apps e sites
- ☁️ Armazenamento de dados
- 🔄 Atualizações automáticas
- 🛟 Suporte técnico

**Preço:** R$ 299 - R$ 1.200/mês  
(Depende do tamanho da escola)

---

#### 2️⃣ **VENDA DE HARDWARE**
- 📦 CAIXA de sensores
- Escola compra 1 por avião

**Preço:** R$ 1.200 - R$ 2.400/unidade  
(Pagamento único por CAIXA)

---

#### 3️⃣ **SETUP INICIAL**
- 👨‍🏫 Treinamento da equipe
- ⚙️ Instalação do hardware
- 🎓 Onboarding completo

**Preço:** R$ 2.000 - R$ 10.000  
(Pagamento único por escola)

---

### Exemplo Real: Escola com 3 Aviões

| Item | Valor |
|------|-------|
| **Setup inicial** | R$ 5.000 (uma vez) |
| **Hardware 3 CAIXAs** | R$ 4.800 (uma vez) |
| **Assinatura mensal** | R$ 600/mês |
| | |
| **Investimento inicial escola** | **R$ 9.800** |
| **Custo mensal** | **R$ 600** |

**Para a escola, se tiver 30 alunos:**  
→ Cobra R$ 20 de "taxa tecnologia" por aluno  
→ R$ 20 × 30 = **R$ 600/mês**  
→ **Sistema se paga sozinho!**

---

## 📊 MERCADO E OPORTUNIDADE

### Números do Brasil

```yaml
Escolas de aviação homologadas: 94
Alunos ativos por ano: ~15.000
Instrutores certificados: ~2.500
Ticket médio hora de voo: R$ 450

Problema: 30-40% dos alunos DESISTEM
Motivo principal: Frustração com avaliações subjetivas
```

### Potencial de Receita (3 Anos)

```mermaid
graph LR
    A["📅 Ano 1<br/>────<br/>1 escola<br/>R$ 7k/mês"] --> B["📅 Ano 2<br/>────<br/>5 escolas<br/>R$ 35k/mês"]
    B --> C["📅 Ano 3<br/>────<br/>15 escolas<br/>R$ 105k/mês"]
    
    style A fill:#3498db,color:#fff
    style B fill:#2ecc71,color:#fff
    style C fill:#f39c12,color:#fff
```

**Conservador (apenas 15% das escolas em 5 anos):**  
→ 15 escolas × R$ 7.000/mês = **R$ 105.000/mês**  
→ **R$ 1.260.000/ano** de receita recorrente

**Otimista (50% das escolas):**  
→ 47 escolas × R$ 7.000/mês = **R$ 329.000/mês**  
→ **R$ 3.948.000/ano** de receita recorrente

---

### Expansão Internacional

**Mercado Mundial:**
- 🇺🇸 EUA: 3.000+ escolas (100x maior)
- 🇪🇺 Europa: 1.500+ escolas
- 🇲🇽 América Latina: 500+ escolas

**Potencial:** Mercado global é **100x maior** que o Brasil

---

## 🎯 ESTRATÉGIA DE LANÇAMENTO

### Fase 1: VALIDAÇÃO (6 meses)
```mermaid
graph LR
    A["🔬 MVP"] --> B["🏫 1 escola piloto"]
    B --> C["✈️ 50 voos reais"]
    C --> D["✅ Validado"]
    
    style A fill:#3498db,color:#fff
    style B fill:#2ecc71,color:#fff
    style C fill:#f39c12,color:#fff
    style D fill:#9b59b6,color:#fff
```

**Meta:** Provar que funciona em ambiente real

---

### Fase 2: CRESCIMENTO (12 meses)
```
✅ 3-5 escolas
✅ 150-250 alunos
✅ Case studies de sucesso
✅ Marketing digital
```

---

### Fase 3: ESCALA (24 meses)
```
✅ 10-15 escolas
✅ 500-750 alunos
✅ Equipe de vendas
✅ Expansão regional
```

---

### Fase 4: EXPANSÃO (36+ meses)
```
✅ 50+ escolas
✅ Expansão internacional
✅ Parcerias estratégicas
✅ Domínio de mercado
```

---

## 🎁 BENEFÍCIOS TANGÍVEIS PARA A ESCOLA

### Redução de Custos

| Item | Antes | Depois | Economia |
|------|-------|--------|----------|
| **Tempo administrativo** | 10h/semana | 2h/semana | **80%** |
| **Papel/impressão** | R$ 500/mês | R$ 50/mês | **90%** |
| **Taxa desistência** | 35% | 15% | **57%** |
| **Multas ANAC** | R$ 5k/ano | R$ 0/ano | **100%** |

---

### Aumento de Receita

**Cenário Real: Escola com 50 alunos/ano**

**ANTES:**
- 35% desistem = **18 alunos completam**
- 18 × R$ 35.000 (curso PP) = **R$ 630.000/ano**

**DEPOIS (com Aviônica):**
- 15% desistem = **43 alunos completam**
- 43 × R$ 35.000 = **R$ 1.505.000/ano**

**GANHO:** R$ 875.000/ano a mais! 💰

**Custo Aviônica:** R$ 7.200/ano (R$ 600/mês)

**ROI:** **121x** (retorno de 12.100%!)

---

## ✅ RESUMO EXECUTIVO

### O Que é o Aviônica em 3 Pontos

1. **📦 Hardware no Avião**  
   → CAIXA com 7 sensores mede TUDO durante o voo

2. **📱 App Offline no Tablet**  
   → Instrutor vê instrumentos, avalia e sincroniza depois

3. **🌐 4 Sites na Nuvem**  
   → Admin, Gestor, Instrutor e Aluno acessam de qualquer lugar

---

### Por Que Somos Diferentes?

```mermaid
graph TD
    A["🎯 AVIÔNICA"] --> B["📊 Dados REAIS<br/>de sensores"]
    A --> C["🎬 Replay interativo<br/>do voo"]
    A --> D["🤖 CIV automático<br/>para ANAC"]
    A --> E["📈 Reduz desistências<br/>em 57%"]
    
    style A fill:#f39c12,color:#fff
    style B fill:#3498db,color:#fff
    style C fill:#2ecc71,color:#fff
    style D fill:#9b59b6,color:#fff
    style E fill:#e74c3c,color:#fff
```

---

### Por Que Agora?

1. ✅ **ANAC exige CIV Digital** (desde 2022)
2. ✅ **Escolas precisam se modernizar** (pós-pandemia)
3. ✅ **Geração Z exige transparência** (alunos jovens)
4. ✅ **Hardware barato** (sensores custam centavos hoje)
5. ✅ **Mercado validado** (concorrentes crescendo, mas sem nossa tech)

---

## 🎬 CONCLUSÃO

### A Grande Visão

```mermaid
graph TB
    START["🛩️ HOJE"] --> A["📍 Brasil<br/>15.000 alunos"]
    A --> B["🌎 Latam<br/>50.000 alunos"]
    B --> C["🌍 Global<br/>500.000 alunos"]
    C --> END["🏆 LÍDER MUNDIAL<br/>Aviação digital"]
    
    style START fill:#3498db,color:#fff
    style A fill:#2ecc71,color:#fff
    style B fill:#f39c12,color:#fff
    style C fill:#9b59b6,color:#fff
    style END fill:#e74c3c,color:#fff
```

### Por Que Vamos Vencer?

1. **🎯 Problema real:** Escolas perdem 35% dos alunos
2. **💎 Solução única:** Somos os únicos com hardware próprio
3. **📊 Dados objetivos:** Acabam conflitos aluno vs instrutor
4. **🤖 Automação ANAC:** Compliance obrigatório resolvido
5. **💰 ROI comprovado:** Escola ganha 121x mais do que gasta
6. **🚀 Timing perfeito:** Regulamentação forçando digitalização

---

### Uma Frase Para Lembrar

> **"Transformamos avaliação subjetiva em dados objetivos,  
> reduzindo desistências e aumentando a receita das escolas."**

---

**🛩️ Aviônica: O futuro da aviação digital já chegou.**

---

*Documento criado para audiências não-técnicas | Versão 1.0 | Novembro 2025*