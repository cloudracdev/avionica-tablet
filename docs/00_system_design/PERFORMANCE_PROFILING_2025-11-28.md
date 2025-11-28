# 📊 Performance Profiling - QFLY Aviônica

**Data:** 2025-11-28  
**Device:** Samsung SM-T295 (tablet entry-level Android)  
**Modo:** `flutter run --profile`

---

## 🎯 Resultados

### Inicialização (Login Screen)

| Métrica | Valor | Status |
|---------|-------|--------|
| FPS Médio | 11 FPS | ⚠️ Esperado (init pesado) |
| Frame Time | Até 27ms | ⚠️ Acima do ideal |
| Causa | Supabase + Hive + dotenv init | Normal |

### Navegação (Pós-Login)

| Métrica | Valor | Status |
|---------|-------|--------|
| FPS Médio | **53 FPS** | ✅ BOM |
| Build Time | 1.6ms | ✅ Ótimo |
| Paint Time | 1.9ms | ✅ Ótimo |
| Raster Time | 3.7ms | ✅ Ótimo |
| Jank | Nenhum | ✅ |

---

## ✅ Conclusão

🟢 **APROVADO PARA MVP**

- Navegação fluida (53 FPS)
- Sem jank detectado
- Frame time < 16ms
- Tablet entry-level = resultado excelente

---

## 📋 Melhorias Futuras (Backlog)

| Prioridade | Otimização | Impacto Estimado |
|------------|------------|------------------|
| Baixa | `const` widgets | +3 FPS |
| Baixa | Splash screen init | UX melhor |
| Média | Lazy loading telas | Init +10 FPS |
| Média | `Consumer` específico | +2 FPS |

**Status:** Não necessário para MVP

---

## 🔧 Como Reproduzir
```bash
flutter run --profile -d <device_id>
```

Abrir DevTools URL exibida no console e analisar Flutter Frames.
