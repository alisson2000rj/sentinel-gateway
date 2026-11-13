<?php
// ============================================================
// VULNBOX LAB — Logger / Auditoria
// Registra tentativas de login e eventos de segurança
// ============================================================

require_once __DIR__ . '/database.php';

/**
 * Registra uma tentativa de login na tabela login_attempts.
 *
 * @param string $username
 * @param string $ip
 * @param bool   $success
 */
function logLoginAttempt(string $username, string $ip, bool $success): void {
    try {
        $db   = getDB();
        $stmt = $db->prepare(
            'INSERT INTO login_attempts (username, ip_address, attempt_time, success)
             VALUES (?, ?, NOW(), ?)'
        );
        $stmt->execute([$username, $ip, $success ? 1 : 0]);
    } catch (PDOException $e) {
        // Silencia erros de log para não interromper o fluxo
        error_log('VULNBOX LAB logger error: ' . $e->getMessage());
    }
}

/**
 * Registra um evento de auditoria na tabela audit_logs.
 *
 * @param int|null $userId
 * @param string   $action
 * @param string   $detail
 * @param string   $ip
 */
function logAudit(?int $userId, string $action, string $detail, string $ip): void {
    try {
        $db   = getDB();
        $stmt = $db->prepare(
            'INSERT INTO audit_logs (user_id, action, detail, ip_address, created_at)
             VALUES (?, ?, ?, ?, NOW())'
        );
        $stmt->execute([$userId, $action, $detail, $ip]);
    } catch (PDOException $e) {
        error_log('VULNBOX LAB audit error: ' . $e->getMessage());
    }
}

/**
 * Retorna últimas tentativas de login (para exibição no admin).
 *
 * @param int $limit
 * @return array
 */
function getRecentLoginAttempts(int $limit = 50): array {
    $db   = getDB();
    $stmt = $db->prepare(
        'SELECT * FROM login_attempts ORDER BY attempt_time DESC LIMIT ?'
    );
    $stmt->execute([$limit]);
    return $stmt->fetchAll();
}

/**
 * Retorna logs de auditoria recentes.
 *
 * @param int $limit
 * @return array
 */
function getAuditLogs(int $limit = 50): array {
    $db   = getDB();
    $stmt = $db->prepare(
        'SELECT al.*, u.username
         FROM audit_logs al
         LEFT JOIN users u ON al.user_id = u.id
         ORDER BY al.created_at DESC
         LIMIT ?'
    );
    $stmt->execute([$limit]);
    return $stmt->fetchAll();
}
