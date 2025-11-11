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
        T["🗼 Torre Controle<br/>────────<br/>Tracking<br/>tempo real"]
    end
    
    A -->|"WiFi<br/>Durante voo"| B
    A -.->|"Internet*<br/>Tempo real"| T
    B -->|"Internet<br/>Após pousar"| C
    
    style A fill:#e74c3c,color:#fff
    style B fill:#3498db,color:#fff
    style C fill:#2ecc71,color:#fff
    style T fill:#f39c12,color:#fff
```

*Transmissão para torre quando internet disponível

---

## 🎯 COMO FUNCIONA NA PRÁTICA

### Jornada Completa de um Voo

```mermaid
flowchart TD
    START["🌅 ANTES DO VOO"] --> A1["📋 Instrutor abre app<br/>Faz checklist digital"]
    
    A1 --> A2["📸 Tira fotos do avião<br/>Documentação"]
    
    A2 --> VOO["✈️ DURANTE O VOO"]
    
    VOO --> B1["📊 CAIXA mede TUDO<br/>Altitude, velocidade,<br/>direção, inclinação..."]
    
    B1 --> B1B["📡 Transmite para TORRE<br/>em tempo real<br/>(se internet disponível)"]
    
    B1B --> B2["📱 Tablet mostra<br/>instrumentos digitais<br/>Instrutor acompanha"]
    
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
- ✅ **Crescimento sustentável:** Mais alunos completam curso e indicam amigos

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
5. **🚀 Timing perfeito:** Regulamentação forçando digitalização
6. **✨ Impacto comprovável:** Redução significativa de desistências

---

### Uma Frase Para Lembrar

> **"Transformamos avaliação subjetiva em dados objetivos,  
> reduzindo desistências e aumentando a satisfação das escolas."**

---

**🛩️ Aviônica: O futuro da aviação digital já chegou.**

---

*Documento criado para audiências não-técnicas | Versão 1.0 | Novembro 2025*