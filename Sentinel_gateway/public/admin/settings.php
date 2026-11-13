<?php
// ============================================================
// VULNBOX LAB — Área Administrativa: Configurações
// A01: Escalada Vertical
// ============================================================

require_once __DIR__ . '/../../src/config.php';
require_once __DIR__ . '/../../src/session.php';
require_once __DIR__ . '/../../src/permissions.php';
require_once __DIR__ . '/../../src/logger.php';
require_once __DIR__ . '/../../src/auth.php';

requireLogin();
$user = currentUser();

if (isVulnerableMode()) {
    // VULNERÁVEL — sem verificação
} else {
    requireAdmin(); // CORRIGIDO
}

logAudit($user['id'], 'ADMIN_VIEW_SETTINGS', "Acessou configurações", getClientIP());
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Admin: Configurações — <?= APP_NAME ?></title>
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
                Você (<strong><?= htmlspecialchars($user['role']) ?></strong> | IP Origem: <code><?= htmlspecialchars($_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1') ?></code>) está acessando configurações administrativas.
            </div>
            <?php endif; ?>

            <div class="card">
                <h2>⚙️ Configurações do Sistema</h2>
                <div class="info-box warn">
                    Esta página exibe configurações sensíveis do sistema.
                    No modo vulnerável, qualquer usuário autenticado pode acessá-la.
                </div>
                <table>
                    <tr><th style="width:240px;">Parâmetro</th><th>Valor</th></tr>
                    <tr><td>Modo da Aplicação</td><td><code><?= APP_MODE ?></code></td></tr>
                    <tr><td>Max Tentativas Login</td><td><?= MAX_LOGIN_ATTEMPTS ?></td></tr>
                    <tr><td>Bloqueio (minutos)</td><td><?= LOCKOUT_MINUTES ?></td></tr>
                    <tr><td>Timeout de Sessão</td><td><?= SESSION_LIFETIME ?>s (<?= SESSION_LIFETIME/60 ?> min)</td></tr>
                    <tr><td>Banco de Dados</td><td><?= DB_NAME ?> @ <?= DB_HOST ?></td></tr>
                    <tr><td>Versão PHP</td><td><?= PHP_VERSION ?></td></tr>
                </table>
            </div>

            <div class="info-box">
                <strong>💡 Demonstração de Escalada Vertical:</strong>
                Esta página é um exemplo de recurso que deveria ser exclusivo para administradores.
                No modo vulnerável, o simples fato de digitar a URL na barra de endereços concede acesso.
            </div>
        </div>
    </div>
</div>
</body>
</html>
