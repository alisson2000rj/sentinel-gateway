<?php
// ============================================================
// VULNBOX LAB — Controle de Acesso / RBAC
// A01: Broken Access Control
// Demonstra controle de acesso vulnerável vs. corrigido
// ============================================================

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/session.php';

// ============================================================
// Mapa de permissões por papel (RBAC)
// ============================================================
const ROLE_PERMISSIONS = [
    'admin' => [
        'view_dashboard',
        'view_own_profile',
        'view_any_profile',    // acesso a qualquer perfil
        'view_own_document',
        'view_any_document',   // acesso a qualquer documento
        'admin_users',
        'admin_logs',
        'admin_settings',
    ],
    'manager' => [
        'view_dashboard',
        'view_own_profile',
        'view_any_profile',    // managers podem ver outros perfis
        'view_own_document',
        'view_any_document',
    ],
    'user' => [
        'view_dashboard',
        'view_own_profile',
        'view_own_document',
    ],
];

/**
 * Verifica se o papel possui determinada permissão.
 */
function roleHasPermission(string $role, string $permission): bool {
    return in_array($permission, ROLE_PERMISSIONS[$role] ?? [], true);
}

/**
 * Verifica se o usuário da sessão atual possui a permissão.
 */
function currentUserCan(string $permission): bool {
    $user = currentUser();
    return roleHasPermission($user['role'] ?? '', $permission);
}

// ============================================================
// Verificação de acesso a recursos
// ============================================================

/**
 * Verifica se o usuário pode acessar um perfil específico.
 *
 * VULNERÁVEL vs. CORRIGIDO — A01 / IDOR
 *
 * @param int $targetUserId ID do usuário alvo
 * @return bool
 */
function canAccessProfile(int $targetUserId): bool {
    $user = currentUser();

    if (isVulnerableMode()) {
        // -------------------------------------------------------
        // VULNERÁVEL — não verifica se o recurso pertence ao usuário.
        // Qualquer usuário autenticado pode acessar qualquer perfil
        // apenas alterando o ?id= na URL.
        // Isso é IDOR — Insecure Direct Object Reference.
        // -------------------------------------------------------
        return true; // VULNERÁVEL — sempre permite
    }

    // -------------------------------------------------------
    // CORRIGIDO — verifica autenticação e autorização.
    // O usuário só pode acessar seu próprio perfil,
    // exceto admin e manager que podem ver qualquer um.
    // -------------------------------------------------------
    if ($user['id'] == $targetUserId) {
        return true; // CORRIGIDO — acesso ao próprio perfil
    }

    return currentUserCan('view_any_profile'); // CORRIGIDO — RBAC
}

/**
 * Verifica se o usuário pode acessar um documento específico.
 *
 * VULNERÁVEL vs. CORRIGIDO — A01 / IDOR
 *
 * @param array $document Documento do banco (inclui user_id)
 * @return bool
 */
function canAccessDocument(array $document): bool {
    $user = currentUser();

    if (isVulnerableMode()) {
        // -------------------------------------------------------
        // VULNERÁVEL — não verifica a propriedade do documento.
        // Qualquer usuário autenticado pode ler qualquer documento
        // alterando ?id= na URL.
        // -------------------------------------------------------
        return true; // VULNERÁVEL — sempre permite
    }

    // -------------------------------------------------------
    // CORRIGIDO — verifica se o documento pertence ao usuário
    // ou se ele tem permissão para ver qualquer documento.
    // -------------------------------------------------------
    if ((int)$document['user_id'] === (int)$user['id']) {
        return true; // CORRIGIDO — documento próprio
    }

    return currentUserCan('view_any_document'); // CORRIGIDO — RBAC
}

/**
 * Requer que o usuário tenha determinado papel ou superior.
 * Redireciona para /dashboard.php com aviso se não tiver.
 *
 * VULNERÁVEL vs. CORRIGIDO — A01 / Escalada Vertical
 *
 * @param string ...$roles Papéis permitidos
 */
function requireRole(string ...$roles): void {
    if (isVulnerableMode()) {
        // -------------------------------------------------------
        // VULNERÁVEL — não verifica o papel do usuário.
        // A verificação é apenas visual (o link não aparece no menu),
        // mas o endpoint é acessível diretamente pela URL.
        // Isso demonstra que "esconder o link" NÃO é controle de acesso.
        // -------------------------------------------------------
        return; // VULNERÁVEL — não verifica nada
    }

    // -------------------------------------------------------
    // CORRIGIDO — verifica o papel no servidor.
    // A autorização é sempre validada no backend,
    // independente de o link aparecer ou não na UI.
    // -------------------------------------------------------
    $user = currentUser();
    if (!in_array($user['role'], $roles, true)) {
        http_response_code(403);
        header('Location: /dashboard.php?error=forbidden');
        exit;
    }
}

/**
 * Verifica acesso à área administrativa.
 * Escalada vertical: user tentando acessar /admin/
 */
function requireAdmin(): void {
    requireRole('admin');
}

/**
 * Verifica acesso gerencial.
 */
function requireManagerOrAdmin(): void {
    requireRole('manager', 'admin');
}
