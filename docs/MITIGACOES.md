# 🟢 Vulnbox Lab — Guia de Mitigações

---

## A01 — Broken Access Control

### Princípio fundamental

> **Autorização deve sempre ser verificada no servidor (backend), nunca apenas na interface do usuário.**

Esconder um link no menu, desabilitar um botão ou usar JavaScript para ocultar elementos **não constitui controle de acesso**. O servidor deve validar cada requisição independentemente.

---

### M01 — Correção de IDOR (Insecure Direct Object Reference)

**Problema:** O servidor retorna recursos baseados apenas no ID fornecido pelo cliente, sem verificar se aquele ID pertence ao usuário autenticado.

**Código vulnerável (`permissions.php`):**
```php
// VULNERÁVEL — não verifica se o recurso pertence ao usuário
function canAccessProfile(int $targetUserId): bool {
    return true; // sempre permite
}
```

**Código corrigido:**
```php
// CORRIGIDO — verifica autenticação e autorização antes de acessar
function canAccessProfile(int $targetUserId): bool {
    $user = currentUser();

    // Usuário pode acessar apenas o próprio perfil
    if ($user['id'] == $targetUserId) {
        return true;
    }

    // Admin e manager podem acessar qualquer perfil (RBAC)
    return currentUserCan('view_any_profile');
}
```

**Diretrizes:**
- Nunca confiar no ID enviado pelo cliente
- Verificar propriedade do recurso no banco de dados
- Aplicar RBAC quando múltiplos papéis precisam de acesso
- Usar identificadores não previsíveis (UUID) em produção

---

### M02 — Correção de Escalada Vertical

**Problema:** Endpoints administrativos não verificam o papel do usuário no servidor.

**Código vulnerável (`admin/users.php`):**
```php
// VULNERÁVEL — sem verificação de papel
// Qualquer autenticado acessa /admin/ digitando a URL
requireLogin(); // apenas verifica se está logado
```

**Código corrigido:**
```php
// CORRIGIDO — verifica papel no servidor
requireAdmin(); // bloqueia se role != 'admin'
```

**Implementação do `requireAdmin()`:**
```php
function requireAdmin(): void {
    $user = currentUser();
    if ($user['role'] !== 'admin') {
        http_response_code(403);
        header('Location: /dashboard.php?error=forbidden');
        exit;
    }
}
```

**Diretrizes:**
- Implementar verificação de papel em cada endpoint sensível
- Validar a autorização também na requisição que altera dados, não apenas ao renderizar a tela
- Nunca depender da ausência de links no menu como controle
- Aplicar o princípio de menor privilégio (Least Privilege)
- Centralizar a lógica de autorização (não duplicar em cada arquivo)

---

### M03 — Prevenção contra Path Traversal e Exposição de Diretórios (Directory Listing)

**Problema:** A aplicação e o servidor web aceitam parâmetros de caminho brutos (como `?id=../../.env` ou `?file=/etc/passwd`) e exibem o conteúdo de pastas quando acessadas sem página inicial (`Index of /src/`).

**Código Vulnerável (`document.php` / `sensitive_access.php`):**
```php
// VULNERÁVEL — permite ler arquivos e diretórios sem sanitização
if (isVulnerableMode()) {
    $target = $_GET['file'] ?? $_GET['id'];
    echo file_get_contents($target); // Lê qualquer arquivo do sistema
}
```

**Código e Configuração Corrigidos:**
```php
// CORRIGIDO — bloqueia requisições com travessia ou acessos a arquivos sensíveis
if (isFixedMode()) {
    http_response_code(403);
    echo "Directory listing is disabled by server policy (Options -Indexes).";
    exit;
}
```

**Diretrizes de Mitigação:**
- **Options -Indexes**: Desativar a listagem automática de diretórios no servidor web (`Options -Indexes` no Apache ou `autoindex off` no Nginx).
- **Sanitização de Caminhos**: Nunca utilizar entradas do usuário em funções de leitura de arquivos (`file_get_contents`, `include`, `readfile`).
- **Validação de ID numérico**: Forçar a conversão explícita para inteiro `(int)$_GET['id']` antes de consultar no banco.
- **WAF na Borda**: Regra `#6` (`PATH_TRAVERSAL` e `SENSITIVE_FILE_ACCESS`) interceptando `.env`, `/src/`, `/database/` e `../`.

---

### M04 — RBAC (Role-Based Access Control)

O laboratório implementa RBAC com três papéis:

| Papel | Permissões |
|-------|-----------|
| `user` | Ver próprio perfil e documentos |
| `manager` | Ver qualquer perfil e documento |
| `admin` | Tudo + área administrativa |

**Implementação no `permissions.php`:**
```php
const ROLE_PERMISSIONS = [
    'admin'   => ['view_any_profile', 'view_any_document', 'admin_users', ...],
    'manager' => ['view_any_profile', 'view_any_document'],
    'user'    => ['view_own_profile', 'view_own_document'],
];
```

---

## A07 — Identification and Authentication Failures

---

### M05 — Senhas com Hash Seguro

**Problema:** Senhas armazenadas em texto puro são expostas em caso de dump do banco.

**Vulnerável:**
```php
// Compara texto puro — VULNERÁVEL
if ($user['password_plain'] !== $password) { ... }
```

**Corrigido:**
```php
// CORRIGIDO — usa bcrypt via password_verify()
if (!password_verify($password, $user['password'])) { ... }
```

**Para gerar o hash:**
```php
$hash = password_hash('minhasenha', PASSWORD_BCRYPT);
// Resultado: $2y$10$... (hash bcrypt)
```

**Diretrizes:**
- Nunca armazenar senhas em texto puro
- Usar `password_hash()` com `PASSWORD_BCRYPT` ou `PASSWORD_ARGON2ID`
- Nunca usar MD5 ou SHA1 para senhas
- Exigir senhas com mínimo de 8 caracteres, letras e números

> **Nota do laboratório:** a coluna `password_plain` permanece no banco para
> permitir a comparação didática no modo vulnerável. Em uma aplicação real,
> ela deve ser removida após migrar as senhas para hashes; alternar o modo não
> elimina esse dado do banco.

---

### M06 — Proteção contra Força Bruta

**Problema:** Sem limitação de tentativas, um atacante pode testar milhões de senhas.

**Corrigido (`auth.php`):**
```php
// CORRIGIDO — conta tentativas e bloqueia a conta
$newFails = $user['failed_attempts'] + 1;
if ($newFails >= MAX_LOGIN_ATTEMPTS) {
    $lockedUntil = (new DateTime())->modify('+15 minutes');
    // UPDATE users SET status='locked', locked_until=? WHERE id=?
}
```

**Verificação de bloqueio:**
```php
if ($user['status'] === 'locked') {
    if (new DateTime() < new DateTime($user['locked_until'])) {
        return false; // conta ainda bloqueada
    }
    // período expirou: desbloqueia automaticamente
}
```

**Diretrizes:**
- Limitar tentativas por usuário e por IP
- Bloqueio temporário (não permanente em ambientes sem suporte humano)
- Alertar o usuário legítimo por e-mail sobre o bloqueio
- Considerar CAPTCHA após N tentativas (complementar, não substituto)

---

### M07 — Gerenciamento Seguro de Sessão

**Problema:** Sessões inseguras permitem Session Fixation e roubo de sessão.

**Regeneração de ID após login:**
```php
// CORRIGIDO — previne Session Fixation
session_regenerate_id(true); // destrói a sessão antiga

$_SESSION['user_id']    = $user['id'];
$_SESSION['login_time'] = time();
$_SESSION['last_activity'] = time();
```

**Atributos seguros do cookie:**
```php
// CORRIGIDO
ini_set('session.cookie_httponly', '1');  // JS não acessa
ini_set('session.cookie_secure',   '0');  // lab local HTTP; em produção usar '1' + HTTPS
ini_set('session.cookie_samesite', 'Strict'); // anti-CSRF
ini_set('session.use_strict_mode', '1');  // rejeita IDs externos
```

**Timeout por inatividade:**
```php
// CORRIGIDO — verifica última atividade
if (time() - $_SESSION['last_activity'] > SESSION_LIFETIME) {
    session_destroy();
    header('Location: /login.php?reason=timeout');
    exit;
}
$_SESSION['last_activity'] = time();
```

**Logout seguro:**
```php
// CORRIGIDO — destrói sessão completamente
$_SESSION = [];
setcookie(session_name(), '', time() - 42000); // expira o cookie
session_destroy();
```

---

## Resumo das Correções

| Vulnerabilidade | Correção Implementada |
|-----------------|-----------------------|
| IDOR Perfil | `canAccessProfile()` verifica propriedade |
| IDOR Documento | `canAccessDocument()` verifica propriedade |
| Escalada Vertical | `requireAdmin()` / `requireRole()` no backend |
| Alteração de status de usuário | POST com token de sessão + autorização de admin no modo corrigido |
| Listagem de `/admin/` | `index.php` protegido + `Options -Indexes` |
| Senha em texto puro | `password_hash()` + `password_verify()` |
| Força bruta | Contador + bloqueio temporário de conta |
| Session Fixation | `session_regenerate_id(true)` após login |
| Cookie inseguro | `HttpOnly`, `SameSite=Strict`, `use_strict_mode` |
| Timeout de sessão | Rastreamento por `last_activity` |
| Logout incompleto | `session_destroy()` + limpeza do cookie |
