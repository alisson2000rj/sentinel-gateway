<?php
// ============================================================
// VULNBOX LAB — Área Administrativa: Logs
// A01: Escalada Vertical — endpoint admin
// ============================================================

require_once __DIR__ . '/../../src/config.php';
require_once __DIR__ . '/../../src/session.php';
require_once __DIR__ . '/../../src/permissions.php';
require_once __DIR__ . '/../../src/database.php';
require_once __DIR__ . '/../../src/logger.php';
require_once __DIR__ . '/../../src/auth.php';

requireLogin();
$user = currentUser();

if (isVulnerableMode()) {
    // VULNERÁVEL — sem verificação de papel
} else {
    requireAdmin(); // CORRIGIDO
}

$attempts = getRecentLoginAttempts(100);
$audits   = getAuditLogs(100);

logAudit($user['id'], 'ADMIN_VIEW_LOGS', "Acessou logs de auditoria", getClientIP());
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Admin: Logs — <?= APP_NAME ?></title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body class="<?= modeClass() ?>">

<?php include __DIR__ . '/../partials/topbar.php'; ?>
<?= modeBanner() ?>

<div class="container">
    <div class="layout">
        <?php include __DIR__ . '/../partials/sidebar.php'; ?>
        <div class="content">

            <?php if (isVulnerableMode() && $user['role'] !== 'admin'): ?>
            <div class="alert alert-error">
                ⚠️ <strong>VULNERABILIDADE EXPLORADA:</strong>
                Você (<strong><?= htmlspecialchars($user['role']) ?></strong> | IP Origem: <code><?= htmlspecialchars($_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1') ?></code>) está visualizando logs administrativos confidenciais.
            </div>
            <?php endif; ?>

            <div class="card">
                <h2>🔐 Tentativas de Login (últimas 100)</h2>
                <table>
                    <thead><tr><th>ID</th><th>Usuário</th><th>IP</th><th>Data/Hora</th><th>Resultado</th></tr></thead>
                    <tbody>
                        <?php foreach ($attempts as $a): ?>
                        <tr>
                            <td><?= $a['id'] ?></td>
                            <td><?= htmlspecialchars($a['username']) ?></td>
                            <td><?= htmlspecialchars($a['ip_address']) ?></td>
                            <td><?= htmlspecialchars($a['attempt_time']) ?></td>
                            <td><?= $a['success']
                                ? '<span class="success-cell">✅ Sucesso</span>'
                                : '<span class="fail-cell">❌ Falha</span>' ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

            <div class="card">
                <h2>📋 Auditoria de Eventos (últimos 100)</h2>
                <table>
                    <thead><tr><th>ID</th><th>Usuário</th><th>Ação</th><th>Detalhe</th><th>IP</th><th>Data/Hora</th></tr></thead>
                    <tbody>
                        <?php foreach ($audits as $a): ?>
                        <tr>
                            <td><?= $a['id'] ?></td>
                            <td><?= htmlspecialchars($a['username'] ?? 'N/A') ?></td>
                            <td><?= htmlspecialchars($a['action']) ?></td>
                            <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;"><?= htmlspecialchars($a['detail'] ?? '') ?></td>
                            <td><?= htmlspecialchars($a['ip_address']) ?></td>
                            <td><?= htmlspecialchars($a['created_at']) ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

        </div>
    </div>
</div>
</body>
</html>
