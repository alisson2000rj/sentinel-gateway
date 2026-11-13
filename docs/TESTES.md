# 🧪 Vulnbox Lab — Roteiro de Testes e Demonstração

> Este roteiro orienta a execução dos testes de segurança no laboratório **Vulnbox Lab**, cobrindo tanto as correções no nível da **Aplicação Web** (`APP_MODE`) quanto a proteção no nível da **Rede / WAF** com o **Sentinel Gateway**.

---

## 🏗️ ARQUITETURA DE SEGURANÇA E DEFESA EM PROFUNDIDADE

O laboratório possui **duas camadas de defesa independentes**:

1. **Camada de Rede (Sentinel Gateway / WAF OpenResty)**:
   - Acessível em `http://localhost:8080` e pelo container `kali-attacker`.
   - Controlado em `http://localhost:8080/_gateway/` (Modos: **🟢 Ativado** vs **🟠 Desativado**).
   - Inspeciona o tráfego e bloqueia ataques na borda com `HTTP 403` / `HTTP 429`.

2. **Camada de Aplicação (`owasp-lab-vunlbox-lab`)**:
   - Alternada no banner superior da página web (Modos: **🔴 Vulnerável** vs **🟢 Corrigido**).
   - Aplica validações nativas em código PHP, sessões e banco de dados.

---

## 🚀 CONFIGURAÇÃO INICIAL

```bash
# Inicializar todo o ambiente (Gateway, Web, MySQL e Kali)
docker compose up -d --build

# Aguarde ~15 segundos para inicialização dos serviços
# Acesse o Gateway pelo navegador: http://localhost:8080
# Acesse o Painel de Controle do Gateway: http://localhost:8080/_gateway/
```

---

## 🐉 EXECUTANDO ATAQUES AUTOMATIZADOS (KALI ATTACKER)

Você pode rodar todos os testes de invasão diretamente do container Kali:

```bash
# Executar a suíte completa de ataques da máquina hospedeira:
docker exec kali-attacker bash /attacks/run_all.sh

# Ou acessar o terminal interativo do Kali:
docker exec -it kali-attacker bash
./run_all.sh
```

---

## 🧪 TESTE 01 — Autenticação Básica (A07)

### Objetivo
Verificar o processo de login e identificar vazamento de informações de autenticação.

### Passos
1. Acesse `http://localhost:8080/login.php`
2. Tente logar com credenciais inexistentes: `naoexiste / xpto123`
3. Observe a mensagem de erro retornada.
4. Tente logar com credenciais válidas: `user1 / 123456`

### Matriz de Comportamento

| Modo App (`APP_MODE`) | Estado Gateway | Comportamento |
|-----------------------|----------------|---------------|
| 🔴 Vulnerável | 🟠 WAF Desativado | Revela se usuário existe; sem limites |
| 🔴 Vulnerável | 🟢 WAF Ativado | Gateway inspeciona a requisição; banner ativo |
| 🟢 Corrigido | 🟢 WAF Ativado | Mensagem genérica; limite de 5 tentativas nativo + WAF |

---

## 🧪 TESTE 02 — Força Bruta no Login (A07)

### Objetivo
Demonstrar a proteção contra ataques de dicionário e força bruta.

### Passos
1. Na máquina Kali, execute o ataque com a wordlist de 100 senhas:
   ```bash
   docker exec -it kali-attacker bash /attacks/brute_force.sh user1 /attacks/wordlist.txt
   ```
2. Ou via navegador, tente errar a senha do `user1` repetidamente.

### Matriz de Comportamento

| Modo App | Estado Gateway | Comportamento |
|----------|----------------|---------------|
| 🔴 Vulnerável | 🟠 WAF Desativado | **VULNERÁVEL**: Atacante testa centenas de senhas sem bloqueio |
| 🔴 Vulnerável | 🟢 WAF Ativado | **PROTEGIDO PELO GATEWAY**: WAF bloqueia com **HTTP 429** na 4ª tentativa (limite: 3 tentativas) |
| 🟢 Corrigido | 🟠 WAF Desativado | **PROTEGIDO PELA APP**: Aplicação bloqueia a conta por 15 minutos na 5ª tentativa |
| 🟢 Corrigido | 🟢 WAF Ativado | **DEFESA EM PROFUNDIDADE**: WAF bloqueia na borda antes de sobrecarregar a aplicação |

---

## 🧪 TESTE 03 — IDOR em Perfis e Documentos (A01)

### Objetivo
Demonstrar acesso não autorizado a dados e documentos de outros usuários (Escalada Horizontal).

### Passos
1. Faça login como `user1 / 123456`
2. Acesse `/profile.php?id=3` (perfil do user1) e mude a URL para `/profile.php?id=1` (admin)
3. Acesse `/document.php?id=5` (documento do user1) e mude para `/document.php?id=1` (documento confidencial admin)
4. Pelo Kali, execute a enumeração IDOR:
   ```bash
   docker exec kali-attacker bash /attacks/idor_profile.sh
   docker exec kali-attacker bash /attacks/idor_document.sh
   ```

### Matriz de Comportamento

| Modo App | Estado Gateway | Comportamento |
|----------|----------------|---------------|
| 🔴 Vulnerável | 🟠 WAF Desativado | **VULNERÁVEL**: Dados e documentos do Admin expostos ao `user1` |
| 🔴 Vulnerável | 🟢 WAF Ativado | **PROTEGIDO PELO GATEWAY**: WAF detecta enumeração de IDs e bloqueia com **HTTP 403** |
| 🟢 Corrigido | — | **PROTEGIDO PELA APP**: Código PHP valida permissões do usuário e nega acesso (`HTTP 403`) |

---

## 🧪 TESTE 04 — Escalada Vertical de Privilégio (A01)

### Objetivo
Demonstrar que ocultar links no menu não impede o acesso direto a rotas administrativas `/admin/*`.

### Passos
1. Faça login como `user1 / 123456` (usuário comum, `role=user`).
2. Acesse diretamente na barra de endereço:
   - `http://localhost:8080/admin/users.php`
   - `http://localhost:8080/admin/logs.php`
3. Pelo Kali, execute o ataque de escalada vertical:
   ```bash
   docker exec kali-attacker bash /attacks/admin_escalation.sh
   ```

### Matriz de Comportamento

| Modo App | Estado Gateway | Comportamento |
|----------|----------------|---------------|
| 🔴 Vulnerável | 🟠 WAF Desativado | **VULNERÁVEL**: Usuário comum acessa o painel de usuários e logs |
| 🔴 Vulnerável | 🟢 WAF Ativado | **PROTEGIDO PELO GATEWAY**: WAF valida o papel da sessão e bloqueia com **HTTP 403** |
| 🟢 Corrigido | — | **PROTEGIDO PELA APP**: PHP redireciona usuário não-admin com erro 403 |

---

## 🧪 TESTE 05 — Path Traversal e Arquivos Sensíveis (A01)

### Objetivo
Demonstrar tentativa de acesso não autorizado a arquivos de código/sistema (`.env`, `/src/`, `/database/`).

### Passos
1. Pelo Kali ou navegador, tente acessar:
   - `http://localhost:8080/.env`
   - `http://localhost:8080/src/config.php`
   - `http://localhost:8080/document.php?id=../../.env`
2. Pelo Kali, execute o script:
   ```bash
   docker exec kali-attacker bash /attacks/path_traversal.sh
   ```

### Matriz de Comportamento

| Modo App | Estado Gateway | Comportamento |
|----------|----------------|---------------|
| 🔴 Vulnerável | 🟠 WAF Desativado | **VULNERÁVEL**: Arquivos `.env`, `/src/config.php`, `/database/init.sql` expostos com HTTP 200; pastas `/src/` e `/database/` exibem página `Index of` (Directory Listing) |
| 🔴 Vulnerável | 🟢 WAF Ativado | **PROTEGIDO PELO GATEWAY**: WAF detecta travessia e acesso sensível, bloqueando com **HTTP 403** (`PATH_TRAVERSAL` / `SENSITIVE_FILE_ACCESS`) |
| 🟢 Corrigido | 🟠 WAF Desativado | **PROTEGIDO PELA APP**: Aplicação bloqueia acesso a arquivos sensíveis e desativa a listagem de diretórios com **HTTP 403** (`Options -Indexes`) |
| 🟢 Corrigido | 🟢 WAF Ativado | **DEFESA EM PROFUNDIDADE**: WAF bloqueia na borda com HTTP 403 e a aplicação backend também nega o acesso |

---

## 🧪 TESTE 06 — Gerenciamento de Sessão (A07)

### Objetivo
Demonstrar vulnerabilidades de fixação de sessão (Session Fixation) e atributos de segurança de cookies.

### Passos
1. Abra DevTools (F12) → Application → Cookies → `localhost`
2. Compare o valor de `PHPSESSID` **antes** e **depois** do login.
3. Observe os atributos `HttpOnly`, `SameSite` do cookie.
4. Pelo Kali, execute:
   ```bash
   docker exec kali-attacker bash /attacks/session_fixation.sh
   ```

### Matriz de Comportamento

| Modo App | Session ID no Login | HttpOnly | SameSite |
|----------|---------------------|----------|----------|
| 🔴 Vulnerável | **Não muda** (Session Fixation) | `false` | (Vazio) |
| 🟢 Corrigido | **Regenerado** (`session_regenerate_id`) | `true` | `Strict` |

---

## 🧪 TESTE 07 — Política de Senha Fraca no WAF (A07)

### Objetivo
Demonstrar a validação e rejeição de senhas vulneráveis (tamanho curto, dicionário comum e falta de complexidade) diretamente na borda pelo WAF.

### Passos
1. Certifique-se de que a regra `WEAK_PASSWORD_POLICY` está ativa no painel do gateway (`http://localhost:8080/_gateway/`).
2. Tente submeter o formulário de login com uma senha fraca via cURL no Kali ou navegador:
   - **Senha curta (<8 caracteres):**
     `curl -i -X POST http://localhost:8080/login.php -d "username=user1&password=123"`
     *(Resultado: HTTP 400 Bad Request — Senha muito curta)*
   - **Senha em dicionário vulnerável (`admin123`):**
     `curl -i -X POST http://localhost:8080/login.php -d "username=admin&password=admin123"`
     *(Resultado: HTTP 400 Bad Request — Senha em lista de senhas fracas)*
   - **Senha sem números (`passwordtest`):**
     `curl -i -X POST http://localhost:8080/login.php -d "username=user1&password=passwordtest"`
     *(Resultado: HTTP 400 Bad Request — Sem complexidade)*

### Matriz de Comportamento

| Modo App | Regra `WEAK_PASSWORD_POLICY` | Comportamento |
|----------|------------------------------|---------------|
| Qualquer | 🔴 Desativada | Senha fraca é submetida à aplicação PHP |
| Qualquer | 🟢 Ativada | **PROTEGIDO PELO GATEWAY**: WAF rejeita a submissão com **HTTP 400** na borda |

---

## 📊 CHECKLIST DE VERIFICAÇÃO FINAL E MATRIZ DE TESTES

| Vulnerabilidade | OWASP | App Vulnerável + WAF Off | App Vulnerável + WAF On | App Corrigida + WAF On |
|-----------------|-------|--------------------------|-------------------------|------------------------|
| **Força Bruta** | A07 | 🔴 Vulnerável (Ilimitado) | 🛡️ Bloqueado pelo Gateway (429) | 🟢 Protegido na App e no Gateway |
| **Política de Senha Fraca** | A07 | 🔴 Senha vulnerável aceita | 🛡️ Bloqueado pelo Gateway (400) | 🟢 Protegido no Gateway e na App |
| **IDOR Perfil / Doc** | A01 | 🔴 Vulnerável (Acesso Total) | 🛡️ Bloqueado pelo Gateway (403) | 🟢 Protegido na App e no Gateway |
| **Escalada Vertical** | A01 | 🔴 Vulnerável (Acesso /admin) | 🛡️ Bloqueado pelo Gateway (403) | 🟢 Protegido na App e no Gateway |
| **Path Traversal & Directory Listing** | A01 | 🔴 Vulnerável (`Index of` / Exposição) | 🛡️ Bloqueado pelo Gateway (403) | 🟢 Protegido na App e no Gateway |
| **Session Fixation** | A07 | 🔴 Vulnerável (ID Fixo) | 🔴 Inspecionado | 🟢 ID de Sessão Regenerado |
