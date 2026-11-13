<?php
// ============================================================
// VULNBOX LAB — Área Administrativa: Usuários
// A01: Broken Access Control — Escalada Vertical de Privilégio
// ============================================================

require_once __DIR__ . '/../../src/config.php';
require_once __DIR__ . '/../../src/session.php';
require_once __DIR__ . '/../../src/permissions.php';
require_once __DIR__ . '/../../src/database.php';
require_once __DIR__ . '/../../src/logger.php';
require_once __DIR__ . '/../../src/auth.php';

requireLogin();
$user = currentUser();

// ============================================================
// CONTROLE DE ACESSO — escalada vertical
// ============================================================

if (isVulnerableMode()) {
    // ----------------------------------------------------------
    // VULNERÁVEL — não verifica o papel do usuário no servidor.
    // O link "/admin/users.php" pode estar oculto no menu
    // para usuários comuns, mas o endpoint é acessível diretamente.
    // Isso demonstra que "segurança por obscuridade" NÃO funciona.
    //
    // Qualquer usuário autenticado (role=user) pode acessar
    // esta página administrativa digitando a URL manualmente.
    // ----------------------------------------------------------
    // SEM verificação de papel — VULNERÁVEL
    $accessGranted = true;
} else {
    // ----------------------------------------------------------
    // CORRIGIDO — verifica o papel no servidor.
    // Apenas admin pode acessar esta área.
    // A verificação ocorre no backend, independente do link
    // aparecer ou não na interface do usuário.
    // ----------------------------------------------------------
    requireAdmin(); // CORRIGIDO — bloqueia e redireciona se não for admin
    $accessGranted = true;
}

// ============================================================
// ALTERAÇÃO DE STATUS — demonstração de controle de acesso
// ============================================================
$db = getDB();

if (empty($_SESSION['user_status_token'])) {
    $_SESSION['user_status_token'] = bin2hex(random_bytes(32));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['toggle_user_status'])) {
    $token = $_POST['token'] ?? '';
    $targetUserId = filter_input(INPUT_POST, 'user_id', FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);

    if (!is_string($token) || !hash_equals($_SESSION['user_status_token'], $token) || !$targetUserId) {
        http_response_code(403);
        exit('Solicitação de alteração de status inválida.');
    }

    // CORRIGIDO — a autorização é conferida no endpoint que altera os dados.
    // VULNERÁVEL — qualquer usuário autenticado que alcance esta URL consegue
    // alterar contas, demonstrando Broken Access Control.
    if (isFixedMode() && $user['role'] !== 'admin') {
        http_response_code(403);
        exit('Apenas administradores podem alterar o status de usuários.');
    }

    $targetStmt = $db->prepare('SELECT username, status FROM users WHERE id = ?');
    $targetStmt->execute([$targetUserId]);
    $targetUser = $targetStmt->fetch();

    if (!$targetUser) {
        $_SESSION['user_status_notice'] = 'Usuário não encontrado.';
    } elseif ($targetUser['status'] === 'locked') {
        // "locked" é reservado ao mecanismo de bloqueio por força bruta.
        $_SESSION['user_status_notice'] = 'Contas bloqueadas por tentativas de login não podem ser alteradas por este controle.';
    } else {
        $newStatus = $targetUser['status'] === 'active' ? 'inactive' : 'active';
        $updateStmt = $db->prepare('UPDATE users SET status = ? WHERE id = ?');
        $updateStmt->execute([$newStatus, $targetUserId]);

        logAudit(
            $user['id'],
            'ADMIN_TOGGLE_USER_STATUS',
            "Alterou o status de {$targetUser['username']} para {$newStatus}",
            getClientIP()
        );
        $_SESSION['user_status_notice'] = "Status de {$targetUser['username']} alterado para {$newStatus}.";
    }

    header('Location: /admin/users.php', true, 303);
    exit;
}

$statusNotice = $_SESSION['user_status_notice'] ?? '';
unset($_SESSION['user_status_notice']);

// Busca usuários
$users = $db->query('SELECT id, username, name, email, role, status, failed_attempts, locked_until, created_at FROM users ORDER BY id')->fetchAll();

logAudit($user['id'], 'ADMIN_VIEW_USERS', "Acessou lista de usuários", getClientIP());
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Admin: Usuários — <?= APP_NAME ?></title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body class="<?= modeClass() ?>">

<?php include __DIR__ . '/../partials/topbar.php'; ?>
<?= modeBanner() ?>

<div class="container">
    <div class="layout">
        <?php include __DIR__ . '/../partials/sidebar.php'; ?>

        <div class="content">

            <?php if (isVulnerableMode()): ?>
            <div class="info-box vuln">
                <strong>🔴 A01 — Escalada Vertical de Privilégio (MODO VULNERÁVEL)</strong>
                <b>Você está logado como:</b> <code><?= htmlspecialchars($user['username']) ?></code>
                (role: <strong><?= $user['role'] ?></strong> | IP Origem: <code><?= htmlspecialchars($_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1') ?></code>)<br>
                <b>Falha:</b> o servidor não verifica se você tem papel de admin para acessar esta área.<br>
                <b>Exploração:</b> acesse <code>/admin/users.php</code> diretamente pela URL, mesmo sem ser admin.<br>
                <b>Demonstração:</b> esconder o link no menu <strong>NÃO é controle de acesso</strong>.<br>
                <b>Impacto:</b> usuário comum vê, e potencialmente modifica, dados administrativos.
            </div>
            <?php else: ?>
            <div class="info-box fixed">
                <strong>🟢 A01 — Escalada Vertical Corrigida</strong>
                O servidor verificou que você tem papel <strong>admin</strong> antes de exibir esta página.
                Usuários com role=user ou role=manager sem permissão admin recebem 403.
            </div>
            <?php endif; ?>

            <div class="card">
                <h2>👥 Gerenciamento de Usuários</h2>

                <?php if ($user['role'] !== 'admin' && isVulnerableMode()): ?>
                <div class="alert alert-error">
                    ⚠️ <strong>VULNERABILIDADE EXPLORADA:</strong>
                    Você (<strong><?= htmlspecialchars($user['role']) ?></strong> | IP Origem: <code><?= htmlspecialchars($_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1') ?></code>) está vendo uma área exclusiva de admin.
                </div>
                <?php endif; ?>

                <?php if ($statusNotice): ?>
                <div class="alert alert-warn"><?= htmlspecialchars($statusNotice) ?></div>
                <?php endif; ?>

                <table>
                    <thead>
                        <tr>
                            <th>ID</th><th>Usuário</th><th>Nome</th><th>E-mail</th>
                            <th>Role</th><th>Status</th><th>Falhas</th><th>Bloqueado até</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($users as $u): ?>
                        <tr>
                            <td><?= $u['id'] ?></td>
                            <td><?= htmlspecialchars($u['username']) ?></td>
                            <td><?= htmlspecialchars($u['name']) ?></td>
                            <td><?= htmlspecialchars($u['email']) ?></td>
                            <td>
                                <?= match($u['role']) {
                                    'admin'   => '<span class="badge badge-admin">admin</span>',
                                    'manager' => '<span class="badge badge-manager">manager</span>',
                                    default   => '<span class="badge badge-user">user</span>',
                                } ?>
                            </td>
                            <td>
                                <?php if (in_array($u['status'], ['active', 'inactive'], true)): ?>
                                <form method="post" action="/admin/users.php" class="status-toggle-form">
                                    <input type="hidden" name="toggle_user_status" value="1">
                                    <input type="hidden" name="user_id" value="<?= $u['id'] ?>">
                                    <input type="hidden" name="token" value="<?= htmlspecialchars($_SESSION['user_status_token'], ENT_QUOTES, 'UTF-8') ?>">
                                    <button type="submit"
                                            class="badge status-toggle <?= $u['status'] === 'active' ? 'badge-fixed' : 'badge-inactive' ?>"
                                            title="Clique para <?= $u['status'] === 'active' ? 'desativar' : 'ativar' ?> este usuário">
                                        <?= htmlspecialchars($u['status']) ?>
                                    </button>
                                </form>
                                <?php else: ?>
                                <span class="badge badge-vuln" title="Bloqueio por força bruta">locked</span>
                                <?php endif; ?>
                            </td>
                            <td><?= $u['failed_attempts'] ?></td>
                            <td><?= $u['locked_until'] ? htmlspecialchars($u['locked_until']) : '—' ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

            <div class="info-box">
                <strong>💡 Como demonstrar escalada vertical:</strong>
                1. Faça login como <code>user1 / 123456</code> (role=user)<br>
                2. No <strong>Modo Vulnerável</strong>: acesse <code>/admin/users.php</code> diretamente pela URL<br>
                3. Clique no status <code>active</code> de qualquer conta e observe que ele muda para <code>inactive</code><br>
                4. No <strong>Modo Corrigido</strong>: somente o admin alcança e pode alterar esta página
            </div>
        </div>
    </div>
</div>
</body>
</html>
