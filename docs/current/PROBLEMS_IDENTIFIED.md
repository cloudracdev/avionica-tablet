# PROBLEMAS IDENTIFICADOS - QFLY

**Status:** Funcional mas com débito técnico significativo

---

## 🔴 PROBLEMAS CRÍTICOS

### 1. SixPackScreen com 643 linhas (God Object)
- 10 responsabilidades diferentes
- 22 variáveis de estado
- Difícil de testar e manter
- **Solução:** Refatorar em 4 classes (150L cada)

### 2. FlightData não usado
- Modelo criado mas código usa Map
- Sem type-safety
- **Solução:** Migrar todos services (2 dias)

### 3. Zero testes
- Sem unit/widget/integration tests
- Medo de refatorar
- **Solução:** 50% coverage inicial (4 dias)

### 4. setState manual
- Rebuild tudo a cada frame (30 FPS)
- Não escala
- **Solução:** Provider/Riverpod (1 semana)

---

## 🟡 PROBLEMAS IMPORTANTES

### 5. Telas mockadas
- Login sem autenticação
- Origem/Destino não salva
- **Solução:** Backend (2 semanas)

### 6. Navegação manual
- Sem router centralizado
- **Solução:** go_router (1 dia)

### 7. Error handling básico
- Sem retry no WebSocket
- Sem validação robusta
- **Solução:** Try-catch + retry logic (2 dias)

### 8. Variômetro no SixPackScreen
- Lógica de negócio na UI
- **Solução:** VariometerCalculator service (4h)

---

## 🎯 PLANO DE AÇÃO

**FASE 1 (1 semana):** Refatorar SixPackScreen + Testes
**FASE 2 (1 semana):** State Management + Error Handling
**FASE 3 (2 semanas):** Backend real
**FASE 4 (1 semana):** Polimento

**TOTAL:** 5-6 semanas para app production-ready

---

**Documento criado em:** 04/11/2025