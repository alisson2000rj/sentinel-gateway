<?php
// ============================================================
// VULNBOX LAB — Dashboard
// ============================================================

require_once __DIR__ . '/../src/config.php';
require_once __DIR__ . '/../src/session.php';
require_once __DIR__ . '/../src/permissions.php';
require_once __DIR__ . '/../src/database.php';

requireLogin();
$user = currentUser();

// Busca contagens para exibição
$db = getDB();
$docCount = $db->query("SELECT COUNT(*) FROM documents")->fetchColumn();
$userCount = $db->query("SELECT COUNT(*) FROM users")->fetchColumn();
$attemptCount = $db->query("SELECT COUNT(*) FROM login_attempts WHERE success=0")->fetchColumn();

$errorMsg = '';
if (isset($_GET['error']) && $_GET['error'] === 'forbidden') {
    $errorMsg = 'Acesso negado. Você não tem permissão para acessar essa área.';
}

$roleBadge = match($user['role']) {
    'admin'   => '<span class="badge badge-admin">ADMIN</span>',
    'manager' => '<span class="badge badge-manager">MANAGER</span>',
    default   => '<span class="badge badge-user">USER</span>',
};
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard — <?= APP_NAME ?></title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body class="<?= modeClass() ?>">

<?php include __DIR__ . '/partials/topbar.php'; ?>

<?= modeBanner() ?>

<div class="container">
    <?php if ($errorMsg): ?>
        <div class="alert alert-error">🚫 <?= htmlspecialchars($errorMsg) ?></div>
    <?php endif; ?>

    <div class="layout">
        <?php include __DIR__ . '/partials/sidebar.php'; ?>

        <div class="content">
            <div class="card">
                <h2>🏠 Dashboard — Sistema Administrativo</h2>

                <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px;margin-bottom:20px;">
                    <div class="card" style="margin:0;background:#f0f4ff;border-left:4px solid #2980b9;">
                        <div style="font-size:2rem;font-weight:700;color:#2980b9;"><?= $userCount ?></div>
                        <div style="color:#555;">Usuários</div>
                    </div>
                    <div class="card" style="margin:0;background:#f0fff4;border-left:4px solid #27ae60;">
                        <div style="font-size:2rem;font-weight:700;color:#27ae60;"><?= $docCount ?></div>
                        <div style="color:#555;">Documentos</div>
                    </div>
                    <div class="card" style="margin:0;background:#fff4f0;border-left:4px solid #e74c3c;">
                        <div style="font-size:2rem;font-weight:700;color:#e74c3c;"><?= $attemptCount ?></div>
                        <div style="color:#555;">Tentativas Falhas</div>
                    </div>
                </div>

                <table>
                    <tr><th style="width:160px;">Campo</th><th>Valor</th></tr>
                    <tr><td>Usuário</td><td><strong><?= htmlspecialchars($user['username']) ?></strong></td></tr>
                    <tr><td>Nome</td><td><?= htmlspecialchars($user['name']) ?></td></tr>
                    <tr><td>Papel / Role</td><td><?= $roleBadge ?> <span class="badge" style="background:#21262d;color:#58a6ff;border:1px solid #30363d;font-family:monospace;margin-left:4px;">IP: <?= htmlspecialchars($_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1') ?></span></td></tr>
                    <tr><td>IP de Origem</td><td><code><?= htmlspecialchars($_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1') ?></code></td></tr>
                    <tr><td>Session ID (PHPSESSID)</td><td><code style="word-break:break-all;"><?= htmlspecialchars(session_id()) ?></code></td></tr>
                    <tr><td>ID do Usuário</td><td><?= $user['id'] ?></td></tr>
                    <tr><td>Modo do Lab</td><td><?= modeBadge() ?></td></tr>
                </table>
            </div>

            <!-- ====================================================
                 EXERCÍCIOS DO LABORATÓRIO
                 ==================================================== -->
            <div class="card">
                <h2>🧪 Exercícios de Laboratório</h2>

                <div class="info-box">
                    <strong>Como usar este laboratório</strong>
                    Explore cada endpoint abaixo. Observe o comportamento no <strong>Modo Vulnerável</strong>
                    e compare com o <strong>Modo Corrigido</strong>. Clique no banner no topo para
                    alternar <code>APP_MODE</code> automaticamente.
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>Exercício</th>
                            <th>Endpoint</th>
                            <th>Vulnerabilidade</th>
                            <th>Ação</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>IDOR — Perfil</td>
                            <td><code>/profile.php?id=1</code></td>
                            <td><span class="badge badge-vuln">A01</span></td>
                            <td><a href="/profile.php?id=1" class="btn btn-sm btn-primary">Testar</a></td>
                        </tr>
                        <tr>
                            <td>IDOR — Documento</td>
                            <td><code>/document.php?id=1</code></td>
                            <td><span class="badge badge-vuln">A01</span></td>
                            <td><a href="/document.php?id=1" class="btn btn-sm btn-primary">Testar</a></td>
                        </tr>
                        <tr>
                            <td>Escalada Vertical</td>
                            <td><code>/admin/users.php</code></td>
                            <td><span class="badge badge-vuln">A01</span></td>
                            <td><a href="/admin/users.php" class="btn btn-sm btn-primary">Testar</a></td>
                        </tr>
                        <tr>
                            <td>Força Bruta</td>
                            <td><code>/login.php</code></td>
                            <td><span class="badge badge-vuln">A07</span></td>
                            <td><a href="/login.php" class="btn btn-sm btn-primary">Testar</a></td>
                        </tr>
                        <tr>
                            <td>Sessão Insegura</td>
                            <td><code>/security.php</code></td>
                            <td><span class="badge badge-vuln">A07</span></td>
                            <td><a href="/security.php" class="btn btn-sm btn-primary">Ver</a></td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <?php if (isVulnerableMode()): ?>
            <div class="info-box vuln">
                <strong>🔴 MODO VULNERÁVEL ATIVO</strong>
                As vulnerabilidades A01 e A07 estão ativas. Explore os endpoints acima.
                Para comparar com as correções, clique no banner e alterne para <code>APP_MODE=fixed</code>
                e execute <code>docker compose restart web</code>.
            </div>
            <?php else: ?>
            <div class="info-box fixed">
                <strong>🟢 MODO CORRIGIDO ATIVO</strong>
                As mitigações estão aplicadas. Os endpoints estão protegidos contra A01 e A07.
                Para voltar ao modo vulnerável, clique no banner e alterne para <code>APP_MODE=vulnerable</code>.
            </div>
            <?php endif; ?>
        </div>
    </div>
</div>

</body>
</html>
