<?php
// ============================================================
// VULNBOX LAB — Autenticação
// A07: Identification and Authentication Failures
// Demonstra autenticação vulnerável vs. corrigida
// ============================================================

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/database.php';
require_once __DIR__ . '/logger.php';

/**
 * Tenta autenticar um usuário.
 *
 * @param string $username
 * @param string $password
 * @param string $ip       IP do cliente
 * @return array|false     Dados do usuário ou false em falha
 */
function authenticateUser(string $username, string $password, string $ip): array|false {
    $db = getDB();

    if (isVulnerableMode()) {
        return authenticateVulnerable($db, $username, $password, $ip);
    } else {
        return authenticateFixed($db, $username, $password, $ip);
    }
}

// ============================================================
// VULNERÁVEL — A07
// ============================================================

/**
 * VULNERÁVEL — Autenticação sem proteção contra força bruta.
 *
 * Falhas implementadas:
 * 1. Compara senha em texto puro (sem hash)
 * 2. Não limita tentativas de login
 * 3. Não bloqueia conta após falhas repetidas
 * 4. Mensagem de erro revela se o usuário existe
 */
function authenticateVulnerable(PDO $db, string $username, string $password, string $ip): array|false {
    // VULNERÁVEL — busca usuário pelo username
    $stmt = $db->prepare('SELECT * FROM users WHERE username = ? AND status = "active"');
    $stmt->execute([$username]);
    $user = $stmt->fetch();

    // VULNERÁVEL — registra a tentativa (mas não bloqueia)
    logLoginAttempt($username, $ip, $user !== false);

    if (!$user) {
        // VULNERÁVEL — revela que o usuário não existe
        return false;
    }

    // VULNERÁVEL — compara a senha em texto puro armazenada em password_plain
    // Em vez de usar password_verify() com hash bcrypt
    if ($user['password_plain'] !== $password) {
        // VULNERÁVEL — sem contador de tentativas falhas
        return false;
    }

    // VULNERÁVEL — não verifica se a conta está bloqueada
    return $user;
}

// ============================================================
// CORRIGIDO — A07
// ============================================================

/**
 * CORRIGIDO — Autenticação com proteção contra força bruta.
 *
 * Correções implementadas:
 * 1. Verifica senha com password_verify() (hash bcrypt)
 * 2. Conta tentativas falhas
 * 3. Bloqueia conta após MAX_LOGIN_ATTEMPTS falhas
 * 4. Mensagem de erro genérica (não revela se usuário existe)
 * 5. Registra auditoria de autenticação
 */
function authenticateFixed(PDO $db, string $username, string $password, string $ip): array|false {
    // CORRIGIDO — busca o usuário
    $stmt = $db->prepare('SELECT * FROM users WHERE username = ?');
    $stmt->execute([$username]);
    $user = $stmt->fetch();

    // CORRIGIDO — verificar bloqueio de conta ANTES de validar senha
    if ($user && $user['status'] === 'locked') {
        if ($user['locked_until'] && new DateTime() < new DateTime($user['locked_until'])) {
            logLoginAttempt($username, $ip, false);
            logAudit($user['id'], 'LOGIN_BLOCKED', "Tentativa durante bloqueio", $ip);
            return false; // CORRIGIDO — conta bloqueada
        } else {
            // Período de bloqueio expirou — desbloqueia
            $unlock = $db->prepare('UPDATE users SET status="active", failed_attempts=0, locked_until=NULL WHERE id=?');
            $unlock->execute([$user['id']]);
            $user['status']          = 'active';
            $user['failed_attempts'] = 0;
        }
    }

    // CORRIGIDO — registra tentativa
    $success = $user && (password_verify($password, $user['password']));
    logLoginAttempt($username, $ip, $success);

    if (!$user || !$success) {
        // CORRIGIDO — incrementa contador de falhas se o usuário existir
        if ($user) {
            $newFails = $user['failed_attempts'] + 1;
            if ($newFails >= MAX_LOGIN_ATTEMPTS) {
                // CORRIGIDO — bloqueia a conta
                $lockedUntil = (new DateTime())->modify('+' . LOCKOUT_MINUTES . ' minutes')->format('Y-m-d H:i:s');
                $stmt2 = $db->prepare('UPDATE users SET failed_attempts=?, status="locked", locked_until=? WHERE id=?');
                $stmt2->execute([$newFails, $lockedUntil, $user['id']]);
                logAudit($user['id'], 'ACCOUNT_LOCKED', "Bloqueada após $newFails tentativas", $ip);
            } else {
                $stmt2 = $db->prepare('UPDATE users SET failed_attempts=? WHERE id=?');
                $stmt2->execute([$newFails, $user['id']]);
            }
        }
        // CORRIGIDO — mensagem genérica, não revela se usuário existe
        return false;
    }

    // CORRIGIDO — reset de tentativas falhas após login bem-sucedido
    $stmt3 = $db->prepare('UPDATE users SET failed_attempts=0, locked_until=NULL WHERE id=?');
    $stmt3->execute([$user['id']]);

    logAudit($user['id'], 'LOGIN_SUCCESS', "Login bem-sucedido", $ip);

    return $user;
}

/**
 * Retorna o IP real do cliente (considera proxies simples).
 */
function getClientIP(): string {
    if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        return explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0];
    }
    return $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
}
