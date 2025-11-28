# 🔌 API BACKEND - N8N Workflows

**Versão:** 1.0  
**Data:** 28/11/2025  
**Status:** 4 Workflows Ativos

---

## 📊 VISÃO GERAL
```
┌─────────────────────────────────────────────────────────────┐
│                    N8N WORKFLOWS                             │
│                    4 Endpoints Ativos                        │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
   ┌──────────┐         ┌──────────┐         ┌──────────┐
   │ sync-voo │         │  hobbs   │         │   CIV    │
   │  mobile  │         │ updater  │         │ generator│
   └──────────┘         └──────────┘         └──────────┘
                                                   │
                                             ┌─────┴─────┐
                                             ▼           ▼
                                        ┌────────┐ ┌────────┐
                                        │  CIV   │ │  CIV   │
                                        │ gerar  │ │  view  │
                                        └────────┘ └────────┘
```

---

## 🔗 ENDPOINTS

| # | Workflow | Método | Endpoint | Descrição |
|---|----------|--------|----------|-----------|
| 1 | sync-voo-mobile | POST | `/webhook/sync-voo` | Sincroniza voo do tablet |
| 2 | Hobbs-Updater | POST | `/webhook/hobbs-update` | Atualiza horímetro aeronave |
| 3 | CIV-PDF-Generator | POST | `/webhook/civ-generate` | Gera HTML do CIV |
| 4 | CIV-Visualizar | GET | `/webhook/civ-view` | Visualiza CIV em HTML |

---

## 1️⃣ SYNC-VOO-MOBILE

### Descrição
Recebe dados do voo do tablet e insere no Supabase.

### Request
```http
POST /webhook/sync-voo
Content-Type: application/json

{
  "aeroclube_id": "uuid",
  "instrutor_id": "uuid",
  "aeronave_id": "uuid",
  "aluno_id": "uuid",
  "status": "finalizado"
}
```

### Response
```json
{
  "success": true
}
```

### Fluxo
```
Webhook → Create voo → Log Success → Respond
```

### Tabelas
- `voos` (INSERT)
- `workflow_logs` (INSERT)

---

## 2️⃣ HOBBS-UPDATER

### Descrição
Atualiza horímetro da aeronave após voo finalizado. Gera alerta se < 10h para manutenção.

### Request
```http
POST /webhook/hobbs-update
Content-Type: application/json

{
  "voo_id": "uuid"
}
```

### Response (sem alerta)
```json
{
  "success": true,
  "alerta_manutencao": false
}
```

### Response (com alerta)
```json
{
  "success": true,
  "alerta_manutencao": true
}
```

### Fluxo
```
Webhook
    │
    ▼
Get voo (voos)
    │
    ▼
Get aeronave (aeronaves)
    │
    ▼
Update hobbs_atual
    │
    ▼
If (proxima_inspecao - hobbs_atual <= 10)
    │
    ├─► TRUE: Create notificação → Log Warning → Respond (alerta=true)
    │
    └─► FALSE: Log Success → Respond (alerta=false)
```

### Tabelas
- `voos` (SELECT)
- `aeronaves` (SELECT, UPDATE)
- `notificacoes` (INSERT - se alerta)
- `workflow_logs` (INSERT)

### Cálculo Hobbs
```javascript
hobbs_atual + (hobbs_fim - hobbs_inicio)
```

---

## 3️⃣ CIV-PDF-GENERATOR

### Descrição
Gera documento CIV (Caderneta Individual de Voo) em HTML formatado.

### Request
```http
POST /webhook/civ-generate
Content-Type: application/json

{
  "voo_id": "uuid"
}
```

### Response
```json
{
  "success": true,
  "pdf_url": "https://supabase.co/storage/.../civ_xxx.html",
  "voo_id": "uuid"
}
```

### Fluxo
```
Webhook
    │
    ▼
Get voo (voos)
    │
    ▼
Get instrutor (usuarios)
    │
    ▼
Get aluno (usuarios)
    │
    ▼
Get aeronave (aeronaves)
    │
    ▼
Get CIV (voos_civ)
    │
    ▼
Gerar HTML (código JS)
    │
    ▼
Update voos_civ (html_content, pdf_url)
    │
    ▼
Log Success → Respond
```

### Tabelas
- `voos` (SELECT)
- `usuarios` (SELECT x2)
- `aeronaves` (SELECT)
- `voos_civ` (SELECT, UPDATE)
- `workflow_logs` (INSERT)

### HTML Gerado
Documento completo com:
- Dados do voo (data, origem, destino)
- Tripulação (instrutor, aluno, CANAC)
- Tempos (diurno, noturno, IFR, navegação)
- Botão imprimir/PDF
- Estilo profissional CSS

---

## 4️⃣ CIV-VISUALIZAR

### Descrição
Retorna HTML do CIV para visualização no browser.

### Request
```http
GET /webhook/civ-view?voo_id=uuid
```

### Response
```html
<!DOCTYPE html>
<html>
  <!-- HTML completo do CIV -->
</html>
```

### Headers Response
```
Content-Type: text/html; charset=utf-8
```

### Fluxo
```
Webhook → Get CIV → Log Success → Respond HTML
```

### Tabelas
- `voos_civ` (SELECT - html_content)
- `workflow_logs` (INSERT)

---

## 📊 TABELAS UTILIZADAS

| Tabela | Workflows | Operações |
|--------|-----------|-----------|
| `voos` | 1, 2, 3 | SELECT, INSERT |
| `aeronaves` | 2, 3 | SELECT, UPDATE |
| `usuarios` | 3 | SELECT |
| `voos_civ` | 3, 4 | SELECT, UPDATE |
| `notificacoes` | 2 | INSERT |
| `workflow_logs` | 1, 2, 3, 4 | INSERT |

---

## 🔐 AUTENTICAÇÃO

| Item | Valor |
|------|-------|
| Tipo | Supabase API Key |
| Credential ID | MRc0RkQIuoW6UPS6 |
| Nome | Supabase account |

---

## 📝 LOGS

Todos workflows logam em `workflow_logs`:
```json
{
  "workflow_name": "nome-do-workflow",
  "status": "success" | "warning" | "error",
  "message": "Descrição do evento",
  "voo_id": "uuid",
  "aeroclube_id": "uuid",
  "payload": "{...}"
}
```

---

## 🚀 URLs PRODUÇÃO
```
Base URL: https://[seu-n8n-domain]/webhook/

Endpoints:
- POST /webhook/sync-voo
- POST /webhook/hobbs-update
- POST /webhook/civ-generate
- GET  /webhook/civ-view?voo_id=xxx
```

---

## 📋 EXEMPLO USO (cURL)

### Sync Voo
```bash
curl -X POST https://n8n.exemplo.com/webhook/sync-voo \
  -H "Content-Type: application/json" \
  -d '{
    "aeroclube_id": "uuid",
    "instrutor_id": "uuid",
    "aeronave_id": "uuid",
    "aluno_id": "uuid",
    "status": "finalizado"
  }'
```

### Gerar CIV
```bash
curl -X POST https://n8n.exemplo.com/webhook/civ-generate \
  -H "Content-Type: application/json" \
  -d '{"voo_id": "uuid"}'
```

### Visualizar CIV
```bash
curl "https://n8n.exemplo.com/webhook/civ-view?voo_id=uuid"
```

---

**Última atualização:** 28/11/2025
