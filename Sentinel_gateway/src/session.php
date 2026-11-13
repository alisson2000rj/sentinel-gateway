<?php
// ============================================================
// VULNBOX LAB — Gerenciamento de Sessão
// A07: Identification and Authentication Failures
// Demonstra sessão vulnerável vs. corrigida
// ============================================================

require_once __DIR__ . '/config.php';

/**
 * Inicia a sessão de acordo com o modo da aplicação.
 */
function initSession(): void {
    if (isVulnerableMode()) {
        // -------------------------------------------------------
        // VULNERÁVEL — Configurações inseguras de sessão
        // - Sem HttpOnly (cookie acessível via JavaScript)
        // - Sem Secure (transmitido em HTTP)
        // - Sem SameSite (vulnerável a CSRF)
        // - Sem tempo de expiração configurado
        // - ID de sessão NÃO é regenerado após login
        // -------------------------------------------------------
        ini_set('session.cookie_httponly', '0');   // VULNERÁVEL
        ini_set('session.cookie_secure',   '0');   // VULNERÁVEL
        ini_set('session.cookie_samesite', '');    // VULNERÁVEL
        ini_set('session.gc_maxlifetime',  '86400'); // VULNERÁVEL — 24h
        ini_set('session.cookie_lifetime', '86400'); // VULNERÁVEL — persiste muito
        ini_set('session.use_strict_mode', '0');   // VULNERÁVEL — aceita IDs externos/pré-fixados
    } else {
        // -------------------------------------------------------
        // CORRIGIDO — Configurações seguras de sessão
        // - HttpOnly: JavaScript não consegue ler o cookie
        // - Secure: cookie só trafega em HTTPS (em prod)
        // - SameSite=Strict: proteção contra CSRF
        // - Tempo de vida configurável via variável de ambiente
        // -------------------------------------------------------
        ini_set('session.cookie_httponly', '1');         // CORRIGIDO
        ini_set('session.cookie_secure',   '0');         // Em prod: '1' + HTTPS
        ini_set('session.cookie_samesite', 'Strict');    // CORRIGIDO
        ini_set('session.gc_maxlifetime',  SESSION_LIFETIME); // CORRIGIDO
        ini_set('session.cookie_lifetime', '0');         // CORRIGIDO — expira ao fechar browser
        ini_set('session.use_strict_mode', '1');         // CORRIGIDO — rejeita IDs externos
    }

    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }

    // Informa o papel do usuário na sessão para o Sentinel Gateway (WAF)
    if (!empty($_SESSION['logged_in']) && !empty($_SESSION['role'])) {
        header('X-WAF-User-Role: ' . $_SESSION['role']);
    } else {
        header('X-WAF-User-Role: guest');
    }
}

/**
 * Registra o usuário na sessão após autenticação bem-sucedida.
 *
 * @param array $user Dados do usuário vindos do banco
 */
function loginSession(array $user): void {
    if (isVulnerableMode()) {
        // -------------------------------------------------------
        // VULNERÁVEL — Não regenera o ID de sessão após login
        // Permite Session Fixation: atacante pode pré-definir um
        // ID de sessão e, após a vítima autenticar, herdar a sessão.
        // -------------------------------------------------------
        $_SESSION['user_id']   = $user['id'];
        $_SESSION['username']  = $user['username'];
        $_SESSION['role']      = $user['role'];
        $_SESSION['name']      = $user['name'];
        $_SESSION['logged_in'] = true;
        // SEM session_regenerate_id() — VULNERÁVEL
    } else {
        // -------------------------------------------------------
        // CORRIGIDO — Regenera o ID de sessão após login
        // Previne Session Fixation.
        // -------------------------------------------------------
        session_regenerate_id(true); // CORRIGIDO

        $_SESSION['user_id']    = $user['id'];
        $_SESSION['username']   = $user['username'];
        $_SESSION['role']       = $user['role'];
        $_SESSION['name']       = $user['name'];
        $_SESSION['logged_in']  = true;
        $_SESSION['login_time'] = time(); // CORRIGIDO — controle de expiração
        $_SESSION['last_activity'] = time();
    }

    // Comunica imediatamente a função do usuário logado ao WAF
    header('X-WAF-User-Role: ' . $user['role']);
}

/**
 * Destrói a sessão corretamente (logout).
 */
function destroySession(): void {
    $_SESSION = [];

    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(
            session_name(),
            '',
            time() - 42000,
            $params['path'],
            $params['domain'],
            $params['secure'],
            $params['httponly']
        );
    }

    session_destroy();
}

/**
 * Verifica se a sessão expirou (modo corrigido).
 * Redireciona para login se expirada.
 */
function checkSessionTimeout(): void {
    if (isFixedMode() && isset($_SESSION['last_activity'])) {
        $idle = time() - $_SESSION['last_activity'];
        if ($idle > SESSION_LIFETIME) {
            destroySession();
            header('Location: /login.php?reason=timeout');
            exit;
        }
        $_SESSION['last_activity'] = time();
    }
}

/**
 * Verifica se o usuário está autenticado.
 * Redireciona para /login.php se não estiver.
 */
function requireLogin(): void {
    initSession();

    if (isFixedMode()) {
        checkSessionTimeout();
    }

    if (empty($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
        header('Location: /login.php');
        exit;
    }
}

/**
 * Retorna dados do usuário da sessão atual.
 */
function currentUser(): array {
    return [
        'id'       => $_SESSION['user_id']  ?? null,
        'username' => $_SESSION['username'] ?? null,
        'role'     => $_SESSION['role']     ?? null,
        'name'     => $_SESSION['name']     ?? null,
    ];
}
