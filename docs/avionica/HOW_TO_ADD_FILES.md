# COMO ADICIONAR ARQUIVOS .md AO PROJETO

**Tutorial:** Passo-a-passo para organizar a documentação  
**Nível:** Iniciante  
**Tempo:** 10 minutos

---

## 📋 O QUE VOCÊ TEM AGORA

Os arquivos `.md` foram criados em `/mnt/user-data/outputs/`:

```
/mnt/user-data/outputs/
├─ ARCHITECTURE_CURRENT.md        (11 KB)
├─ FILE_GUIDE_CURRENT.md          (11 KB)
├─ FLOW_DIAGRAMS_CURRENT.md       (13 KB)
├─ PROBLEMS_IDENTIFIED.md         (1.5 KB)
├─ README_DOCUMENTACAO.md         (1.2 KB)
├─ AVIONICA_VISION.md             (NOVO!)
├─ AVIONICA_ARCHITECTURE.md       (NOVO!)
├─ AVIONICA_ROADMAP.md            (NOVO!)
└─ AVIONICA_TECH_STACK.md         (NOVO!)
```

---

## 🎯 ONDE COLOCAR ESSES ARQUIVOS?

### OPÇÃO 1: Projeto QFLY Existente (Recomendado)

```
qfly_app/
├─ lib/
│  └─ (código Flutter)
├─ docs/                  ← CRIAR ESTA PASTA
│  ├─ README.md          ← Índice principal
│  ├─ current/           ← Estado atual QFLY
│  │  ├─ ARCHITECTURE_CURRENT.md
│  │  ├─ FILE_GUIDE_CURRENT.md
│  │  ├─ FLOW_DIAGRAMS_CURRENT.md
│  │  └─ PROBLEMS_IDENTIFIED.md
│  └─ avionica/          ← Sistema completo
│     ├─ VISION.md
│     ├─ ARCHITECTURE.md
│     ├─ ROADMAP.md
│     └─ TECH_STACK.md
├─ pubspec.yaml
└─ .gitignore
```

### OPÇÃO 2: Repositório Separado

```
avionica-docs/           ← NOVO REPOSITÓRIO
├─ README.md
├─ qfly/                 ← App atual
│  └─ (docs do QFLY)
└─ avionica/             ← Sistema completo
   └─ (docs do Aviônica)
```

**Recomendo OPÇÃO 1** (tudo junto, mais fácil)

---

## 🛠️ PASSO-A-PASSO: ADICIONAR NO VS CODE

### PASSO 1: Baixar os Arquivos

**No navegador (onde você está com Claude):**

1. Clique em cada link dos arquivos:
   - [AVIONICA_VISION.md](computer:///mnt/user-data/outputs/AVIONICA_VISION.md)
   - [AVIONICA_ARCHITECTURE.md](computer:///mnt/user-data/outputs/AVIONICA_ARCHITECTURE.md)
   - [AVIONICA_ROADMAP.md](computer:///mnt/user-data/outputs/AVIONICA_ROADMAP.md)
   - [AVIONICA_TECH_STACK.md](computer:///mnt/user-data/outputs/AVIONICA_TECH_STACK.md)
   - (E os antigos também)

2. Cada arquivo abrirá → **Botão direito** → **Salvar como...**

3. Salve todos em uma pasta temporária no seu PC  
   Exemplo: `C:\Users\Você\Downloads\avionica-docs\`

---

### PASSO 2: Abrir Projeto no VS Code

**Opção A: Projeto existente**
```bash
cd caminho/para/qfly_app
code .
```

**Opção B: Novo projeto**
```bash
mkdir avionica-docs
cd avionica-docs
code .
```

---

### PASSO 3: Criar Estrutura de Pastas

**No VS Code:**

1. Clique em **"New Folder"** (ícone de pasta com +)
2. Crie a estrutura:

```
docs/
├─ current/
└─ avionica/
```

**OU via terminal no VS Code:**

```bash
mkdir -p docs/current
mkdir -p docs/avionica
```

---

### PASSO 4: Copiar Arquivos para o Projeto

**Método 1: Arrastar e Soltar**

1. Abra a pasta de downloads onde salvou os `.md`
2. Arraste cada arquivo para a pasta correta no VS Code:
   - `ARCHITECTURE_CURRENT.md` → `docs/current/`
   - `AVIONICA_VISION.md` → `docs/avionica/`
   - etc

**Método 2: Copiar via Terminal**

```bash
# Se os arquivos estão em Downloads/avionica-docs/
cp ~/Downloads/avionica-docs/*CURRENT*.md docs/current/
cp ~/Downloads/avionica-docs/AVIONICA*.md docs/avionica/
```

---

### PASSO 5: Criar README.md Principal

**No VS Code, criar `docs/README.md`:**

```markdown
# Documentação Sistema Aviônica

## 📚 Estrutura

- [current/](./current/) - Estado atual do QFLY
- [avionica/](./avionica/) - Sistema completo planejado

## 🎯 Quick Start

1. Leia [avionica/VISION.md](./avionica/VISION.md) para entender o todo
2. Veja [avionica/ROADMAP.md](./avionica/ROADMAP.md) para o plano
3. Consulte [current/](./current/) para ver o código atual

## 🔗 Links Úteis

- [Arquitetura Atual](./current/ARCHITECTURE_CURRENT.md)
- [Arquitetura Futura](./avionica/ARCHITECTURE.md)
- [Tech Stack](./avionica/TECH_STACK.md)
```

---

### PASSO 6: Visualizar Markdown no VS Code

**Opção 1: Preview nativo**
1. Abra um arquivo `.md`
2. Pressione `Ctrl+Shift+V` (Windows/Linux) ou `Cmd+Shift+V` (Mac)
3. Preview abre ao lado

**Opção 2: Preview com Mermaid (para diagramas)**
1. Instale extensão: **"Markdown Preview Mermaid Support"**
2. `Ctrl+Shift+P` → "Markdown: Open Preview"

**Opção 3: Editor + Preview lado a lado**
1. `Ctrl+K V` → abre preview ao lado automaticamente

---

### PASSO 7: Commitar no Git

```bash
# Inicializar git (se novo projeto)
git init

# Adicionar documentação
git add docs/

# Commit
git commit -m "docs: adiciona documentação completa Aviônica"

# Push (se tiver remote)
git push origin main
```

---

## 📖 COMO LER OS MARKDOWN NO GITHUB

Se você fizer push para GitHub:

1. Navegue até `github.com/seu-usuario/repo/tree/main/docs`
2. GitHub renderiza `.md` automaticamente
3. Diagramas Mermaid funcionam nativamente!

**Exemplo de URL:**
```
github.com/vocêdev/avionica/blob/main/docs/avionica/VISION.md
```

---

## 🎨 VISUALIZAR DIAGRAMAS MERMAID

### No VS Code:

**Extensões recomendadas:**
```
1. Markdown Preview Mermaid Support
   - Publisher: Matt Bierner
   
2. Mermaid Markdown Syntax Highlighting
   - Publisher: Mermaid
```

**Instalar:**
1. `Ctrl+Shift+X` (Extensions)
2. Buscar "Mermaid"
3. Install nas 2 extensões acima

### Online:

Se não conseguir no VS Code, use:
- https://mermaid.live
- Cole o código Mermaid
- Veja o diagrama renderizado
- Exporte como PNG/SVG

---

## 🔧 TROUBLESHOOTING

### Problema 1: Arquivos não aparecem no VS Code

**Solução:**
```bash
# Verificar se estão na pasta certa
ls -la docs/

# Reabrir VS Code
code .
```

### Problema 2: Preview Markdown não funciona

**Solução:**
1. Verificar se arquivo tem extensão `.md`
2. Recarregar VS Code: `Ctrl+Shift+P` → "Reload Window"
3. Instalar extensão "Markdown All in One"

### Problema 3: Diagramas Mermaid não renderizam

**Solução:**
1. Instalar extensão específica (ver acima)
2. OU usar https://mermaid.live
3. OU visualizar no GitHub (renderiza nativo)

### Problema 4: Muitos arquivos, confuso

**Solução:**

Criar `docs/NAVIGATION.md`:

```markdown
# Guia de Navegação

## Se você é NOVO:
1. [VISION.md](./avionica/VISION.md)
2. [ROADMAP.md](./avionica/ROADMAP.md)

## Se vai IMPLEMENTAR:
1. [TECH_STACK.md](./avionica/TECH_STACK.md)
2. [ARCHITECTURE.md](./avionica/ARCHITECTURE.md)

## Se vai REFATORAR código atual:
1. [PROBLEMS_IDENTIFIED.md](./current/PROBLEMS_IDENTIFIED.md)
2. [FILE_GUIDE_CURRENT.md](./current/FILE_GUIDE_CURRENT.md)
```

---

## 📱 VISUALIZAR NO CELULAR

### GitHub Mobile:

1. Fazer push dos docs
2. Abrir GitHub app
3. Navegar até pasta `docs/`
4. Arquivos `.md` renderizam perfeitamente!

### Notion/Obsidian:

Pode importar os `.md` para:
- **Notion:** Drag & drop
- **Obsidian:** Copiar pasta `docs/` para vault

---

## 🎯 CHECKLIST FINAL

```
✅ Etapas:
├─ [ ] Baixar todos os arquivos .md
├─ [ ] Criar pasta docs/ no projeto
├─ [ ] Copiar arquivos para subpastas corretas
├─ [ ] Criar README.md principal
├─ [ ] Instalar extensões Markdown no VS Code
├─ [ ] Testar preview (Ctrl+Shift+V)
├─ [ ] Commitar no git
└─ [ ] Push para GitHub (opcional)

✅ Resultado:
├─ Documentação organizada
├─ Fácil de navegar
├─ Diagramas funcionando
└─ Versionada no Git
```

---

## 🚀 PRÓXIMOS PASSOS

Agora que você tem toda documentação:

### 1. **LER TUDO** (1-2 dias)
Invista tempo entendendo a visão completa

### 2. **DECIDIR CAMINHO**
- MVP completo (6 meses)
- Ou incremental (3+3+6)

### 3. **COMEÇAR HARDWARE**
- Comprar ESP32 + sensores
- Montar protótipo

### 4. **REFATORAR QFLY**
- Já tem os docs do que fazer

### 5. **INICIAR NOVO CHAT**
Quando for IMPLEMENTAR (não agora)

---

## 💡 DICAS DE OURO

### Dica 1: Use Obsidian para estudar
- Importa `.md` com links internos
- Cria "graph view" da documentação
- Markdown nativo

### Dica 2: Imprima VISION.md
- Cole na parede
- Mantenha visão do todo

### Dica 3: 1 Arquivo por Dia
- Dia 1: VISION.md
- Dia 2: ROADMAP.md
- Dia 3: ARCHITECTURE.md
- Dia 4: TECH_STACK.md

### Dica 4: Faça Anotações
- Crie `docs/NOTES.md` pessoal
- Dúvidas, decisões, ideias

---

## 🎓 RECURSOS ADICIONAIS

### Markdown:
- https://www.markdownguide.org
- https://github.github.com/gfm/

### Mermaid:
- https://mermaid.js.org/intro/
- https://mermaid.live

### VS Code:
- https://code.visualstudio.com/docs/languages/markdown

---

## ❓ PERGUNTAS FREQUENTES

**Q: Posso editar os `.md`?**  
A: SIM! São seus documentos, evolua conforme aprende

**Q: Git vai versionar `.md`?**  
A: SIM! `.md` são texto, Git rastreia perfeitamente

**Q: Posso converter para PDF?**  
A: SIM! VS Code → Print to PDF ou use Pandoc

**Q: Funciona no Windows?**  
A: SIM! `.md` é universal (Win/Mac/Linux)

**Q: E se perder os arquivos?**  
A: Por isso commit + push! GitHub = backup

---

## 🎉 PRONTO!

Você agora tem:
- ✅ Documentação completa organizada
- ✅ Sabe onde cada arquivo está
- ✅ Consegue ler e editar
- ✅ Versionado no Git
- ✅ Diagramas funcionando

**Próxima conversa:** Quando for IMPLEMENTAR algo específico.

**Por ora:** LEIA, ABSORVA, PLANEJE.

---

**Criado em:** 04/11/2025  
**Versão:** 1.0  
**Atualizado por:** Tutorial hands-on