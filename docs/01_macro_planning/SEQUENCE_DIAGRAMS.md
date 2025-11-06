# 🔄 DIAGRAMAS DE SEQUÊNCIA - AVIÔNICA MVP

**📅 Data:** 06/11/2025  
**🎯 Propósito:** Fluxos macro de interação entre componentes  
**👥 Audiência:** Desenvolvedores, QA, Product

---

## 📋 ÍNDICE DE FLUXOS

1. ✈️ **Fluxo Completo de Voo** (end-to-end)
2. 🔐 **Autenticação e Setup**
3. 📊 **Live Tracking 4G**
4. 📋 **CIV Digital ANAC**
5. 🗺️ **Replay 2D Telemetria**
6. ⚡ **Sincronização Offline → Online**

---

## 1️⃣ FLUXO COMPLETO DE VOO (END-TO-END)

```mermaid
sequenceDiagram
    actor I as 👨‍✈️ Instrutor
    participant T as 📱 Tablet
    participant E as ⚙️ ESP32
    participant L as 💾 Local SQLite
    participant B as ☁️ Backend
    participant W as 🖥️ Web Admin
    participant A as 📋 ANAC

    Note over I,A: 🛫 PRÉ-VOO (Offline)
    
    I->>T: Abrir app
    T->>T: Verificar WiFi/4G
    T->>L: Carregar cache local
    
    I->>T: Selecionar aluno + aeronave
    I->>T: Plano de voo (upload PDF)
    T->>L: Salvar metadata
    
    I->>T: Conectar ESP32
    T->>E: Scan WiFi "CODIGO-qfly-AP"
    E-->>T: WebSocket connect 192.168.4.1:81
    
    T->>E: Aguardar calibração
    E-->>T: {"status": "ready"}
    
    I->>T: Iniciar voo
    T->>L: INSERT voos (status em_andamento)
    
    Note over I,A: ✈️ DURANTE VOO (Offline + 4G Live)
    
    loop Telemetria 20Hz (50ms)
        E->>T: JSON packet (700 bytes)
        T->>T: Atualizar sixpack UI
        T->>L: INSERT telemetria (batch 100)
        
        alt 4G Disponível
            T->>B: POST /live-tracking
            B->>W: WebSocket broadcast
            W->>W: Atualizar mapa live
        end
    end
    
    I->>T: Checklist digital
    T->>L: Salvar checklist JSON
    
    I->>T: Fotos (até 4)
    T->>L: Salvar JPEG (200KB cada)
    
    Note over I,A: 🛬 PÓS-VOO (Offline)
    
    I->>T: Finalizar voo
    T->>E: Disconnect WebSocket
    E-->>T: Close connection
    
    T->>T: Calcular estatísticas
    T->>L: UPDATE voos (duracao, stats)
    
    I->>T: Avaliação FAP (8 items)
    I->>T: Notas + observações
    T->>L: INSERT avaliacoes_fap
    
    I->>T: Assinatura digital (canvas)
    T->>L: Salvar signature PNG
    
    T->>L: UPDATE voos (status finalizado)
    
    Note over I,A: 🔄 SINCRONIZAÇÃO (WiFi/4G)
    
    alt WiFi/4G Conectado
        T->>B: POST /voos/sync (multipart)
        activate B
        
        B->>B: Validar JWT + RLS
        B->>B: INSERT PostgreSQL
        B->>B: Upload S3 (fotos + PDF)
        
        B->>B: Trigger N8N workflow
        deactivate B
        
        B-->>T: {"status": "synced", "voo_id": "uuid"}
        T->>L: UPDATE voos (synced: true)
        
        Note over B,A: 📋 CIV DIGITAL AUTOMÁTICO
        
        B->>B: N8N: Gerar XML CIV
        B->>B: Assinar ICP-Brasil
        B->>A: POST XML assinado
        
        alt ANAC Sucesso
            A-->>B: {"protocolo": "ABC123"}
            B->>B: UPDATE civ_digital (status enviado)
            B->>I: 📧 Email confirmação
        else ANAC Erro
            A-->>B: {"erro": "validation_failed"}
            B->>B: INSERT logs_erro
            B->>I: ⚠️ Email falha
        end
    end
    
    Note over I,A: 🖥️ VISUALIZAÇÃO WEB
    
    I->>W: Login portal instrutor
    W->>B: GET /voos?instrutor_id=X
    B-->>W: JSON voos + telemetria
    
    I->>W: Abrir replay voo
    W->>B: GET /voos/:id/telemetria
    B-->>W: JSON 72k pontos (comprimido)
    
    W->>W: Renderizar Leaflet 2D
    W->>W: Animação timeline
    W->>W: Gráficos altitude/vel/heading
```

---

## 2️⃣ AUTENTICAÇÃO E SETUP INICIAL

```mermaid
sequenceDiagram
    actor U as 👤 Usuário
    participant T as 📱 App
    participant S as 🔐 Supabase Auth
    participant P as 💾 PostgreSQL
    participant C as 💨 Cache Local

    Note over U,C: 🔑 LOGIN PRIMEIRA VEZ
    
    U->>T: Email + Senha
    T->>S: POST /auth/sign-in
    
    S->>S: Verificar credenciais
    S->>P: SELECT usuarios WHERE email=X
    
    alt Credenciais Válidas
        S->>S: Gerar JWT (RS256)
        S->>S: Gerar Refresh Token
        S-->>T: {"access_token": "...", "expires_in": 900}
        
        T->>T: Salvar tokens secure storage
        T->>P: GET /usuarios/me
        P-->>T: JSON perfil completo
        
        T->>C: Cache perfil (Hive)
        T->>C: Cache aeroclube data
        
        T->>P: GET /alunos?aeroclube_id=X
        T->>P: GET /aeronaves?aeroclube_id=X
        T->>P: GET /missoes
        
        T->>C: Cache dados offline (100MB)
        T-->>U: 🎉 Dashboard principal
        
    else Credenciais Inválidas
        S-->>T: {"error": "Invalid credentials"}
        T-->>U: ❌ Email ou senha incorretos
    end
    
    Note over U,C: 🔄 LOGIN SUBSEQUENTE (Offline-First)
    
    U->>T: Abrir app
    T->>T: Verificar access_token
    
    alt Token Válido (< 15min)
        T->>C: Carregar cache
        T-->>U: ✅ Dashboard (offline)
        
        alt Internet Disponível
            T->>P: GET /sync/updates
            P-->>T: Delta changes
            T->>C: Atualizar cache
        end
        
    else Token Expirado
        T->>T: Verificar refresh_token
        
        alt Refresh Válido (< 7d)
            T->>S: POST /auth/refresh
            S-->>T: {"access_token": "...", "expires_in": 900}
            T-->>U: ✅ Dashboard
            
        else Refresh Expirado
            T->>T: Limpar tokens
            T-->>U: 🔒 Tela login
        end
    end
    
    Note over U,C: 🛡️ PERMISSÕES (RLS)
    
    U->>T: Tentar acessar recurso
    T->>P: GET /voos/:id
    
    P->>P: Executar RLS policy
    P->>P: auth.uid() = instrutor_id?
    
    alt Permissão OK
        P-->>T: 200 JSON data
        T-->>U: ✅ Exibir voo
    else Permissão NEGADA
        P-->>T: 403 Forbidden
        T-->>U: ❌ Acesso negado
    end
```

---

## 3️⃣ LIVE TRACKING 4G (TEMPO REAL)

```mermaid
sequenceDiagram
    participant E as ⚙️ ESP32
    participant T as 📱 Tablet
    participant R as ⚡ Redis
    participant B as ☁️ Backend
    participant W1 as 🖥️ Web Admin
    participant W2 as 🖥️ Web Gestor

    Note over E,W2: ✈️ VOO EM ANDAMENTO
    
    loop Telemetria 20Hz
        E->>T: JSON packet
        T->>T: Atualizar sixpack
        
        alt 4G Conectado
            T->>B: POST /live-tracking
            activate B
            
            B->>B: Validar JWT
            B->>B: Extrair posição GPS
            
            B->>R: SET voo:uuid {"lat":X,"lng":Y,"alt":Z}
            B->>R: EXPIRE 60s
            B->>R: PUBLISH channel:live {"voo_id":"..."}
            
            deactivate B
            B-->>T: 204 No Content
        end
    end
    
    Note over E,W2: 🖥️ ADMIN MONITORANDO
    
    W1->>B: GET /live-tracking (subscribe)
    B->>B: WebSocket upgrade
    B->>R: SUBSCRIBE channel:live
    
    loop Broadcast Tempo Real
        R->>B: Message: {"voo_id":"..."}
        B->>R: GET voo:uuid
        R-->>B: JSON position
        
        B->>B: Transform data
        B->>W1: WebSocket send (JSON)
        W1->>W1: Atualizar mapa global
    end
    
    Note over E,W2: 🏢 GESTOR MONITORANDO (Apenas Aeroclube)
    
    W2->>B: GET /live-tracking?aeroclube_id=X
    B->>B: RLS filter (apenas seu aeroclube)
    B->>R: SUBSCRIBE channel:aeroclube:X
    
    R->>B: Message: {"voo_id":"..."}
    
    alt Voo pertence ao aeroclube
        B->>W2: WebSocket send
        W2->>W2: Atualizar mapa aeroclube
    else Voo de outro aeroclube
        B->>B: Ignorar (RLS)
    end
    
    Note over E,W2: 🛬 VOO FINALIZADO
    
    T->>B: POST /voos/finalizar
    B->>R: DEL voo:uuid
    B->>R: PUBLISH channel:live {"action":"remove"}
    
    B->>W1: WebSocket send (remove marker)
    W1->>W1: Remover do mapa
    
    B->>W2: WebSocket send (remove marker)
    W2->>W2: Remover do mapa
```

---

## 4️⃣ CIV DIGITAL ANAC (AUTOMÁTICO)

```mermaid
sequenceDiagram
    participant T as 📱 Tablet
    participant B as ☁️ Backend
    participant N as ⚡ N8N
    participant P as 💾 PostgreSQL
    participant A as 📋 ANAC API
    participant I as 📧 Instrutor

    Note over T,I: 🔄 TRIGGER PÓS-SYNC
    
    T->>B: POST /voos/sync
    activate B
    B->>P: INSERT voos + telemetria
    B->>P: INSERT webhook_queue
    deactivate B
    
    B-->>T: 200 Synced
    
    Note over T,I: ⚡ N8N WORKFLOW (Async)
    
    P->>N: Trigger: new_voo_webhook
    activate N
    
    N->>P: SELECT voos WHERE id=X (JOIN aluno, instrutor)
    P-->>N: JSON voo completo
    
    N->>N: Validar dados obrigatórios
    
    alt Dados Completos
        
        Note over N,A: 📄 GERAR XML CIV
        
        N->>N: Template XML ANAC
        N->>N: Preencher campos
        N->>N: Calcular totalizadores
        N->>N: Adicionar telemetria agregada
        
        Note over N,A: ✍️ ASSINAR ICP-BRASIL
        
        N->>N: Carregar certificado digital
        N->>N: Assinar XML (RSA-SHA256)
        N->>N: Validar assinatura
        
        N->>P: INSERT civ_digital (xml_assinado)
        
        Note over N,A: 📤 ENVIAR ANAC
        
        N->>A: POST /ws/civ/enviar (XML assinado)
        activate A
        
        A->>A: Validar XML schema
        A->>A: Validar assinatura
        A->>A: Validar CANAC instrutor
        A->>A: Validar CANAC aluno
        A->>A: Processar voo
        
        alt ANAC Sucesso ✅
            A-->>N: 200 {"protocolo":"ABC123","status":"processado"}
            deactivate A
            
            N->>P: UPDATE civ_digital (status enviado, protocolo ABC123)
            
            N->>I: 📧 Email: CIV Enviado com Sucesso
            N->>I: 📱 SMS: CIV ABC123 processado
            
        else ANAC Erro ❌
            A-->>N: 400 {"erro":"validation_failed","detalhes":"..."}
            deactivate A
            
            N->>P: UPDATE civ_digital (status erro, erro_msg detalhes)
            N->>P: INSERT logs_anac_erro
            
            N->>I: 📧 Email: Erro ao Enviar CIV
            N->>I: ⚠️ SMS: CIV falhou - verificar portal
            
            Note over N,I: 🔁 RETRY AUTOMÁTICO
            
            N->>N: Sleep 5 minutos
            N->>N: Retry attempt 2/3
            N->>A: POST /ws/civ/enviar (retry)
            
            alt Retry Sucesso
                A-->>N: 200 OK
                N->>P: UPDATE civ_digital (status enviado)
                N->>I: 📧 Email: CIV Enviado (retry)
            else Retry Falhou
                A-->>N: 400 Error
                N->>P: UPDATE civ_digital (tentativas=3, requires_manual=true)
                N->>I: 🚨 Email: Ação Manual Necessária
            end
        end
        
    else Dados Incompletos
        N->>P: INSERT logs_validacao_erro
        N->>I: ⚠️ Email: CIV não enviado - dados faltando
    end
    
    deactivate N
    
    Note over T,I: 🖥️ INSTRUTOR VERIFICA PORTAL
    
    I->>B: GET /civ-digital?voo_id=X
    B->>P: SELECT civ_digital
    P-->>B: JSON status CIV
    B-->>I: Exibir status + protocolo ANAC
```

---

## 5️⃣ REPLAY 2D TELEMETRIA (WEB)

```mermaid
sequenceDiagram
    actor U as 👤 Usuário
    participant W as 🖥️ Web App
    participant B as ☁️ Backend
    participant P as 💾 PostgreSQL
    participant C as 🗺️ Leaflet

    Note over U,C: 📊 CARREGAR VOO
    
    U->>W: Click "Ver Replay" voo
    W->>B: GET /voos/:id
    
    B->>B: Verificar JWT + RLS
    B->>P: SELECT voos WHERE id=X
    P-->>B: JSON metadata voo
    B-->>W: 200 JSON
    
    W->>W: Exibir info voo (duração, aluno, etc)
    
    Note over U,C: 🗺️ CARREGAR TELEMETRIA
    
    W->>B: GET /voos/:id/telemetria
    activate B
    
    B->>P: SELECT * FROM telemetria WHERE voo_id=X ORDER BY timestamp
    P-->>B: 72.000 registros (1h @ 20Hz)
    
    B->>B: Comprimir GZIP
    B->>B: Simplificar trajetória (Douglas-Peucker)
    B->>B: Reduzir para 1.000 pontos (visualização)
    
    deactivate B
    B-->>W: JSON comprimido (~500KB)
    
    W->>W: Descomprimir JSON
    W->>W: Preparar dados timeline
    
    Note over U,C: 🗺️ RENDERIZAR MAPA
    
    W->>C: Inicializar Leaflet
    C->>C: Carregar tiles OpenStreetMap
    
    W->>C: Adicionar polyline (trajetória)
    C->>C: Desenhar linha azul
    
    W->>C: Adicionar markers (início/fim)
    C->>C: Desenhar pins
    
    W->>C: Fit bounds (centralizar)
    C->>C: Zoom automático
    
    Note over U,C: ▶️ PLAYBACK ANIMADO
    
    U->>W: Click Play
    
    loop Animação 60fps
        W->>W: t = timestamp atual
        W->>W: Buscar telemetria[t]
        
        W->>C: Atualizar marker posição
        C->>C: Mover ícone avião
        
        W->>W: Atualizar gráficos
        W->>W: Altitude: 1.200m
        W->>W: Velocidade: 120 km/h
        W->>W: Heading: 270° (W)
        
        W->>W: Sleep 16ms (60fps)
    end
    
    Note over U,C: 🎮 CONTROLES INTERATIVOS
    
    U->>W: Pause
    W->>W: Parar loop animação
    
    U->>W: Seek timeline (drag)
    W->>W: Jump to timestamp
    W->>C: Atualizar posição
    
    U->>W: Speed 2x
    W->>W: Sleep 8ms (120fps simulado)
    
    U->>W: Click ponto trajetória
    W->>W: Exibir tooltip
    W->>W: "12:34:56 | 1.200m | 120km/h | +2.5°/s"
    
    Note over U,C: 📊 ANÁLISE AVANÇADA
    
    U->>W: Ativar heatmap altitude
    W->>C: Colorir polyline (verde<baixo, vermelho>alto)
    
    U->>W: Ativar análise velocidade
    W->>W: Calcular avg, min, max
    W->>W: Exibir estatísticas
    
    U->>W: Exportar dados
    W->>B: GET /voos/:id/telemetria?format=csv
    B-->>W: CSV 72k linhas
    W->>W: Download telemetria.csv
```

---

## 6️⃣ SINCRONIZAÇÃO OFFLINE → ONLINE

```mermaid
sequenceDiagram
    participant T as 📱 Tablet
    participant L as 💾 SQLite Local
    participant N as 📡 Network
    participant B as ☁️ Backend
    participant P as 💾 PostgreSQL

    Note over T,P: 📴 MODO OFFLINE (Durante Voo)
    
    loop Operações Offline
        T->>L: INSERT voos (status local)
        T->>L: INSERT telemetria (batch 100)
        T->>L: INSERT checklist
        T->>L: SAVE fotos filesystem
        T->>L: INSERT avaliacoes_fap
        
        T->>L: UPDATE voos (synced=false)
    end
    
    Note over T,P: 🔍 DETECTAR CONECTIVIDADE
    
    T->>N: Ping conectividade
    
    alt WiFi/4G Disponível
        N-->>T: ✅ Online
        
        T->>T: Verificar access_token
        
        alt Token Válido
            Note over T,P: 🔄 SINCRONIZAÇÃO INTELIGENTE
            
            T->>L: SELECT * FROM voos WHERE synced=false
            L-->>T: 3 voos pendentes
            
            loop Para cada voo pendente
                T->>L: SELECT voo + telemetria + fotos
                L-->>T: JSON completo (~3.8MB)
                
                T->>T: Preparar multipart/form-data
                T->>T: Anexar fotos JPEG
                T->>T: Anexar JSON telemetria (GZIP)
                
                T->>B: POST /voos/sync (multipart)
                activate B
                
                B->>B: Verificar JWT + RLS
                B->>B: Validar schema JSON
                
                B->>P: BEGIN TRANSACTION
                
                B->>P: INSERT INTO voos
                P-->>B: voo_id (UUID)
                
                B->>P: INSERT INTO telemetria (bulk 72k rows)
                B->>P: INSERT INTO avaliacoes_fap
                B->>P: INSERT INTO checklist
                
                B->>B: Upload fotos → S3
                B->>P: INSERT INTO fotos (S3 URLs)
                
                B->>P: COMMIT TRANSACTION
                
                deactivate B
                B-->>T: 200 {"voo_id":"uuid","status":"synced"}
                
                T->>L: UPDATE voos SET synced=true WHERE id=X
                T->>L: DELETE telemetria WHERE voo_id=X (liberar espaço)
                
                T->>T: ✅ Voo 1/3 sincronizado
            end
            
            T->>T: 🎉 Todos voos sincronizados
            
        else Token Expirado
            T->>B: POST /auth/refresh
            B-->>T: Novo access_token
            T->>T: Retry sync
        end
        
    else Sem Conectividade
        N-->>T: ❌ Offline
        T->>T: Aguardar conectividade
        T->>T: Retry em 60s
    end
    
    Note over T,P: ⚠️ TRATAMENTO DE ERROS
    
    alt Erro 409 (Conflito)
        B-->>T: 409 {"error":"duplicate_voo"}
        T->>L: UPDATE voos SET synced=true (já existe backend)
        
    else Erro 413 (Payload Grande)
        B-->>T: 413 {"error":"payload_too_large"}
        T->>T: Comprimir telemetria GZIP nível 9
        T->>T: Redimensionar fotos 50%
        T->>T: Retry upload
        
    else Erro 500 (Server Error)
        B-->>T: 500 {"error":"internal_error"}
        T->>T: Log erro local
        T->>T: Retry em 5min (backoff exponencial)
        T->>T: Máx 5 tentativas
    end
    
    Note over T,P: 🧹 LIMPEZA LOCAL
    
    T->>L: SELECT * FROM voos WHERE synced=true AND created_at < 30 days
    L-->>T: 50 voos antigos
    
    T->>T: Confirmar com usuário
    T->>L: DELETE FROM telemetria WHERE voo_id IN (...)
    T->>L: DELETE FROM voos WHERE id IN (...)
    
    T->>T: 💾 Liberado 190MB
```

---

## 🎯 MÉTRICAS DE PERFORMANCE

| Fluxo | Latência Target | Success Rate | Observações |
|-------|-----------------|--------------|-------------|
| **ESP32 → Tablet** | <50ms | >99% | WebSocket 20Hz |
| **Tablet → Backend** | <200ms | >95% | Sync assíncrono |
| **Live Tracking** | <100ms | >98% | Redis Pub/Sub |
| **CIV ANAC** | <5s | >99.5% | Retry automático 3x |
| **Replay Load** | <2s | >99% | Compressão GZIP |
| **Auth Login** | <500ms | >99.9% | Supabase Auth |

---

## ⚠️ PONTOS DE ATENÇÃO

### 🔴 Críticos
- ❗ **Perda pacotes ESP32**: Ignorar, não reenviar (não afetar UX)
- ❗ **WiFi loss mid-flight**: Log evento, continuar gravação
- ❗ **Bateria tablet**: Monitorar, alertar <20%
- ❗ **Storage cheio**: Limpar voos antigos sincronizados

### 🟡 Importantes
- ⚠️ **ANAC timeout**: Retry 3x, escalar manual
- ⚠️ **4G intermitente**: Buffer local, sync quando estável
- ⚠️ **Token expirado**: Refresh automático transparente

### 🟢 Otimizações
- ✅ **Telemetria bulk insert**: 100 registros/batch
- ✅ **Compressão GZIP**: 70% redução payload
- ✅ **Redis TTL**: 60s live tracking (garbage collect auto)

---

## 🔗 INTEGRAÇÕES EXTERNAS

```mermaid
graph LR
    A[📱 App] -->|HTTPS| B[☁️ Backend]
    B -->|XML SOAP| C[📋 ANAC]
    B -->|REST API| D[📧 SendGrid]
    B -->|REST API| E[📱 Twilio]
    B -->|SDK| F[💾 S3/Storage]
    
    style A fill:#3498db,color:#fff
    style B fill:#2ecc71,color:#fff
    style C fill:#e74c3c,color:#fff
    style D fill:#f39c12,color:#fff
    style E fill:#9b59b6,color:#fff
    style F fill:#1abc9c,color:#fff
```

---

## ✅ CHECKLIST IMPLEMENTAÇÃO

### Fluxo Voo Completo
- [ ] WebSocket ESP32 ↔ Tablet
- [ ] Gravação local SQLite
- [ ] Live tracking 4G
- [ ] Sincronização offline
- [ ] Avaliação FAP
- [ ] Fotos checklist

### CIV Digital
- [ ] Template XML ANAC
- [ ] Assinatura ICP-Brasil
- [ ] Envio SOAP API
- [ ] Retry automático
- [ ] Email notificações

### Replay 2D
- [ ] Leaflet map
- [ ] Polyline trajetória
- [ ] Playback animado
- [ ] Gráficos tempo real
- [ ] Export CSV

---

**✅ DIAGRAMAS COMPLETOS**  
**📊 Tokens restantes:** ~157.000  
**⏭️ Próximo:** Conteúdo Apresentação